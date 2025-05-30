/* -----------------------------------------------------------------
 * Programmer(s): Slaven Peles @ LLNL
 * -----------------------------------------------------------------
 * Based on work by Allan Taylor, Alan Hindmarsh and
 *                Radu Serban @ LLNL
 * -----------------------------------------------------------------
 * Example problem for IDA: 2D heat equation, serial, GMRES.
 *
 * This example solves a discretized 2D heat equation problem.
 * This version uses the Krylov solver Spgmr.
 *
 * The DAE system solved is a spatial discretization of the PDE
 *          du/dt = d^2u/dx^2 + d^2u/dy^2
 * on the unit square. The boundary condition is u = 0 on all edges.
 * Initial conditions are given by u = 16 x (1 - x) y (1 - y). The
 * PDE is treated with central differences on a uniform M x M grid.
 * The values of u at the interior points satisfy ODEs, and
 * equations u = 0 at the boundaries are appended, to form a DAE
 * system of size N = M^2. Here M = 10.
 *
 * The system is solved with IDA using the Krylov linear solver
 * SPGMR. The preconditioner uses the diagonal elements of the
 * Jacobian only. Routines for preconditioning, required by
 * SPGMR, are supplied here. The constraints u >= 0 are posed
 * for all components. Output is taken at t = 0, .01, .02, .04,
 * ..., 10.24. Two cases are run -- with the Gram-Schmidt type
 * being Modified in the first case, and Classical in the second.
 * The second run uses IDAReInit.
 * -----------------------------------------------------------------*/

#include <ida/ida.h> /* prototypes for IDA methods            */
#include <math.h>
#include <nvector/nvector_cuda.h> /* access to CUDA N_Vector               */
#include <stdio.h>
#include <stdlib.h>
#include <sundials/sundials_types.h> /* definition of type sunrealtype           */
#include <sunlinsol/sunlinsol_spgmr.h> /* access to spgmr SUNLinearSolver       */

/* Problem Constants */

#define NOUT  11
#define MGRID 10
#define NEQ   MGRID* MGRID
#define ZERO  SUN_RCONST(0.0)
#define ONE   SUN_RCONST(1.0)
#define TWO   SUN_RCONST(2.0)
#define FOUR  SUN_RCONST(4.0)

/* User data type */

struct _UserData
{
  sunindextype mm;  /* number of grid points in one dimension */
  sunindextype neq; /* number of equations */
  sunrealtype dx;
  sunrealtype coeff;
  N_Vector pp; /* vector of prec. diag. elements */
};

typedef _UserData* UserData;

/* Prototypes for functions called by IDA */

int resHeat(sunrealtype tres, N_Vector uu, N_Vector up, N_Vector resval,
            void* user_data);

int PsetupHeat(sunrealtype tt, N_Vector uu, N_Vector up, N_Vector rr,
               sunrealtype c_j, void* prec_data);

int PsolveHeat(sunrealtype tt, N_Vector uu, N_Vector up, N_Vector rr,
               N_Vector rvec, N_Vector zvec, sunrealtype c_j, sunrealtype delta,
               void* prec_data);

/* Prototypes for private functions */

static int SetInitialProfile(UserData data, N_Vector uu, N_Vector up,
                             N_Vector res);
static void PrintHeader(sunrealtype rtol, sunrealtype atol);
static void PrintOutput(void* mem, sunrealtype t, N_Vector uu);
static int check_flag(void* flagvalue, const char* funcname, int opt);

/*
 *--------------------------------------------------------------------
 * CUDA Kernels
 *--------------------------------------------------------------------
 */

__global__ void resHeatKernel(const sunrealtype* uu, const sunrealtype* up,
                              sunrealtype* rr, sunindextype mm, sunrealtype coeff)
{
  sunindextype i, j, tid;

  /* Loop over all grid points. */
  tid = blockDim.x * blockIdx.x + threadIdx.x;

  if (tid < mm * mm)
  {
    i = tid % mm;
    j = tid / mm;

    if (j == 0 || j == mm - 1 || i == 0 || i == mm - 1)
    {
      /* Initialize rr to uu, to take care of boundary equations. */
      rr[tid] = uu[tid];
    }
    else
    {
      /* Loop over interior points; set res = up - (central difference). */
      sunrealtype dif1 = uu[tid - 1] + uu[tid + 1] - TWO * uu[tid];
      sunrealtype dif2 = uu[tid - mm] + uu[tid + mm] - TWO * uu[tid];
      rr[tid]          = up[tid] - coeff * (dif1 + dif2);
    }
  }
}

__global__ void PsetupHeatKernel(sunrealtype* ppv, sunindextype mm,
                                 sunrealtype c_j, sunrealtype coeff)
{
  sunindextype i, j, tid;

  /* Loop over all grid points. */
  tid = blockDim.x * blockIdx.x + threadIdx.x;

  if (tid < mm * mm)
  {
    i = tid % mm;
    j = tid / mm;

    if (j == 0 || j == mm - 1 || i == 0 || i == mm - 1)
    {
      /* Set ppv to one, to take care of boundary equations. */
      ppv[tid] = ONE;
    }
    else
    {
      /* Loop over interior points; ppv_i = 1/J_ii */
      ppv[tid] = ONE / (c_j + FOUR * coeff);
    }
  }
}

__global__ void setInitHeatKernel(sunrealtype* up, sunindextype mm)
{
  sunindextype i, j, tid;

  /* Loop over all grid points. */
  tid = blockDim.x * blockIdx.x + threadIdx.x;

  if (tid < mm * mm)
  {
    i = tid % mm;
    j = tid / mm;

    if (j == 0 || j == mm - 1 || i == 0 || i == mm - 1) { up[tid] = ZERO; }
  }
}

/*
 *--------------------------------------------------------------------
 * MAIN PROGRAM
 *--------------------------------------------------------------------
 */

int main(int argc, char* argv[])
{
  void* mem;
  UserData data;
  N_Vector uu, up, constraints, res;
  int ier, iout;
  sunrealtype rtol, atol, t0, t1, tout, tret;
  long int netf, ncfn, ncfl;
  SUNLinearSolver LS;
  SUNContext ctx;

  mem  = NULL;
  data = NULL;
  uu = up = constraints = res = NULL;
  LS                          = NULL;

  /* Create the SUNDIALS context object for this simulation */

  ier = SUNContext_Create(SUN_COMM_NULL, &ctx);
  if (check_flag(&ier, "SUNContext_Create", 1)) { return 1; }

  /* Assign parameters in the user data structure. */

  data     = (UserData)malloc(sizeof *data);
  data->pp = NULL;
  if (check_flag((void*)data, "malloc", 2)) { return (1); }

  data->mm    = MGRID;
  data->neq   = data->mm * data->mm;
  data->dx    = ONE / (data->mm - ONE);
  data->coeff = ONE / (data->dx * data->dx);

  /* Allocate N-vectors and the user data structure objects. */

  uu = N_VNew_Cuda(data->neq, ctx);
  if (check_flag((void*)uu, "N_VNew_Serial", 0)) { return (1); }

  up = N_VClone(uu);
  if (check_flag((void*)up, "N_VClone", 0)) { return (1); }

  res = N_VClone(uu);
  if (check_flag((void*)res, "N_VClone", 0)) { return (1); }

  constraints = N_VClone(uu);
  if (check_flag((void*)constraints, "N_VClone", 0)) { return (1); }

  data->pp = N_VClone(uu);
  if (check_flag((void*)data->pp, "N_VClone", 0)) { return (1); }

  /* Initialize uu, up. */

  SetInitialProfile(data, uu, up, res);

  /* Set constraints to all 1's for nonnegative solution values. */

  N_VConst(ONE, constraints);

  /* Assign various parameters. */

  t0   = ZERO;
  t1   = SUN_RCONST(0.01);
  rtol = ZERO;
  atol = SUN_RCONST(1.0e-3);

  /* Call IDACreate and IDAMalloc to initialize solution */

  mem = IDACreate(ctx);
  if (check_flag((void*)mem, "IDACreate", 0)) { return (1); }

  ier = IDASetUserData(mem, data);
  if (check_flag(&ier, "IDASetUserData", 1)) { return (1); }

  ier = IDASetConstraints(mem, constraints);
  if (check_flag(&ier, "IDASetConstraints", 1)) { return (1); }
  N_VDestroy(constraints);

  ier = IDAInit(mem, resHeat, t0, uu, up);
  if (check_flag(&ier, "IDAInit", 1)) { return (1); }

  ier = IDASStolerances(mem, rtol, atol);
  if (check_flag(&ier, "IDASStolerances", 1)) { return (1); }

  /* Create the linear solver SUNSPGMR with left preconditioning
     and the default Krylov dimension */
  LS = SUNLinSol_SPGMR(uu, SUN_PREC_LEFT, 0, ctx);
  if (check_flag((void*)LS, "SUNLinSol_SPGMR", 0)) { return (1); }

  /* IDA recommends allowing up to 5 restarts (default is 0) */
  ier = SUNLinSol_SPGMRSetMaxRestarts(LS, 5);
  if (check_flag(&ier, "SUNLinSol_SPGMRSetMaxRestarts", 1)) { return (1); }

  /* Attach the linear solver */
  ier = IDASetLinearSolver(mem, LS, NULL);
  if (check_flag(&ier, "IDASetLinearSolver", 1)) { return (1); }

  /* Set the preconditioner solve and setup functions */
  ier = IDASetPreconditioner(mem, PsetupHeat, PsolveHeat);
  if (check_flag(&ier, "IDASetPreconditioner", 1)) { return (1); }

  /* Print output heading. */
  PrintHeader(rtol, atol);

  /*
   * -------------------------------------------------------------------------
   * CASE I
   * -------------------------------------------------------------------------
   */

  /* Print case number, output table heading, and initial line of table. */

  printf("\n\nCase 1: gsytpe = SUN_MODIFIED_GS\n");
  printf("\n   Output Summary (umax = max-norm of solution) \n\n");
  printf(
    "  time     umax       k  nst  nni  nje   nre   nreLS    h      npe nps\n");
  printf(
    "----------------------------------------------------------------------\n");

  /* Loop over output times, call IDASolve, and print results. */

  for (tout = t1, iout = 1; iout <= NOUT; iout++, tout *= TWO)
  {
    ier = IDASolve(mem, tout, &tret, uu, up, IDA_NORMAL);
    if (check_flag(&ier, "IDASolve", 1)) { return (1); }
    PrintOutput(mem, tret, uu);
  }

  /* Print remaining counters. */

  ier = IDAGetNumErrTestFails(mem, &netf);
  check_flag(&ier, "IDAGetNumErrTestFails", 1);

  ier = IDAGetNumNonlinSolvConvFails(mem, &ncfn);
  check_flag(&ier, "IDAGetNumNonlinSolvConvFails", 1);

  ier = IDAGetNumNonlinSolvConvFails(mem, &ncfl);
  check_flag(&ier, "IDAGetNumNonlinSolvConvFails", 1);

  printf("\nError test failures            = %ld\n", netf);
  printf("Nonlinear convergence failures = %ld\n", ncfn);
  printf("Linear convergence failures    = %ld\n", ncfl);

  /*
   * -------------------------------------------------------------------------
   * CASE II
   * -------------------------------------------------------------------------
   */

  /* Re-initialize uu, up. */

  SetInitialProfile(data, uu, up, res);

  /* Re-initialize IDA and SPGMR */

  ier = IDAReInit(mem, t0, uu, up);
  if (check_flag(&ier, "IDAReInit", 1)) { return (1); }

  ier = SUNLinSol_SPGMRSetGSType(LS, SUN_CLASSICAL_GS);
  if (check_flag(&ier, "SUNLinSol_SPGMRSetGSType", 1)) { return (1); }

  /* Print case number, output table heading, and initial line of table. */

  printf("\n\nCase 2: gstype = SUN_CLASSICAL_GS\n");
  printf("\n   Output Summary (umax = max-norm of solution) \n\n");
  printf(
    "  time     umax       k  nst  nni  nje   nre   nreLS    h      npe nps\n");
  printf(
    "----------------------------------------------------------------------\n");

  /* Loop over output times, call IDASolve, and print results. */

  for (tout = t1, iout = 1; iout <= NOUT; iout++, tout *= TWO)
  {
    ier = IDASolve(mem, tout, &tret, uu, up, IDA_NORMAL);
    if (check_flag(&ier, "IDASolve", 1)) { return (1); }
    PrintOutput(mem, tret, uu);
  }

  /* Print remaining counters. */

  ier = IDAGetNumErrTestFails(mem, &netf);
  check_flag(&ier, "IDAGetNumErrTestFails", 1);

  ier = IDAGetNumNonlinSolvConvFails(mem, &ncfn);
  check_flag(&ier, "IDAGetNumNonlinSolvConvFails", 1);

  ier = IDAGetNumNonlinSolvConvFails(mem, &ncfl);
  check_flag(&ier, "IDAGetNumNonlinSolvConvFails", 1);

  printf("\nError test failures            = %ld\n", netf);
  printf("Nonlinear convergence failures = %ld\n", ncfn);
  printf("Linear convergence failures    = %ld\n", ncfl);

  /* Free Memory */

  IDAFree(&mem);
  SUNLinSolFree(LS);

  N_VDestroy(uu);
  N_VDestroy(up);
  N_VDestroy(res);

  N_VDestroy(data->pp);
  free(data);

  SUNContext_Free(&ctx);

  return (0);
}

/*
 *--------------------------------------------------------------------
 * FUNCTIONS CALLED BY IDA
 *--------------------------------------------------------------------
 */

/*
 * resHeat: heat equation system residual function (user-supplied)
 * This uses 5-point central differencing on the interior points, and
 * includes algebraic equations for the boundary values.
 * So for each interior point, the residual component has the form
 *    res_i = u'_i - (central difference)_i
 * while for each boundary point, it is res_i = u_i.
 */

int resHeat(sunrealtype tt, N_Vector uu, N_Vector up, N_Vector rr, void* user_data)
{
  sunindextype mm;
  sunrealtype coeff;
  UserData data;

  const sunrealtype* uu_data = N_VGetDeviceArrayPointer_Cuda(uu);
  const sunrealtype* up_data = N_VGetDeviceArrayPointer_Cuda(up);
  sunrealtype* rr_data       = N_VGetDeviceArrayPointer_Cuda(rr);

  data = (UserData)user_data;

  coeff = data->coeff;
  mm    = data->mm;

  unsigned block = 256;
  unsigned grid  = (mm * mm + block - 1) / block;

  resHeatKernel<<<grid, block>>>(uu_data, up_data, rr_data, mm, coeff);

  return (0);
}

/*
 * PsetupHeat: setup for diagonal preconditioner for idaHeat2D_kry.
 *
 * The optional user-supplied functions PsetupHeat and
 * PsolveHeat together must define the left preconditioner
 * matrix P approximating the system Jacobian matrix
 *                   J = dF/du + cj*dF/du'
 * (where the DAE system is F(t,u,u') = 0), and solve the linear
 * systems P z = r.   This is done in this case by keeping only
 * the diagonal elements of the J matrix above, storing them as
 * inverses in a vector pp, when computed in PsetupHeat, for
 * subsequent use in PsolveHeat.
 *
 * In this instance, only cj and data (user data structure, with
 * pp etc.) are used from the PsetupdHeat argument list.
 */

int PsetupHeat(sunrealtype tt, N_Vector uu, N_Vector up, N_Vector rr,
               sunrealtype c_j, void* prec_data)
{
  sunindextype mm;
  sunrealtype* ppv;
  UserData data;

  data              = (UserData)prec_data;
  ppv               = N_VGetDeviceArrayPointer_Cuda(data->pp);
  mm                = data->mm;
  sunrealtype coeff = data->coeff;

  unsigned block = 256;
  unsigned grid  = (mm * mm + block - 1) / block;

  PsetupHeatKernel<<<grid, block>>>(ppv, mm, c_j, coeff);

  return (0);
}

/*
 * PsolveHeat: solve preconditioner linear system.
 * This routine multiplies the input vector rvec by the vector pp
 * containing the inverse diagonal Jacobian elements (previously
 * computed in PrecondHeateq), returning the result in zvec.
 */

int PsolveHeat(sunrealtype tt, N_Vector uu, N_Vector up, N_Vector rr,
               N_Vector rvec, N_Vector zvec, sunrealtype c_j, sunrealtype delta,
               void* prec_data)
{
  UserData data;
  data = (UserData)prec_data;
  N_VProd(data->pp, rvec, zvec);
  return (0);
}

/*
 *--------------------------------------------------------------------
 * PRIVATE FUNCTIONS
 *--------------------------------------------------------------------
 */

/*
 * SetInitialProfile: routine to initialize u and up vectors.
 */

static int SetInitialProfile(UserData data, N_Vector uu, N_Vector up, N_Vector res)
{
  sunindextype mm, i, j;
  sunrealtype xfact, yfact, *udata, *updata;

  mm = data->mm;

  udata = N_VGetHostArrayPointer_Cuda(uu);

  /* Initialize uu on all grid points. */
  for (j = 0; j < mm; j++)
  {
    yfact = data->dx * j;
    for (i = 0; i < mm; i++)
    {
      xfact             = data->dx * i;
      udata[mm * j + i] = SUN_RCONST(16.0) * xfact * (ONE - xfact) * yfact *
                          (ONE - yfact);
    }
  }

  N_VCopyToDevice_Cuda(uu);

  /* Initialize up vector to 0. */
  N_VConst(ZERO, up);

  /* resHeat sets res to negative of ODE RHS values at interior points. */
  resHeat(ZERO, uu, up, res, data);

  /* Copy -res into up to get correct interior initial up values. */
  N_VScale(-ONE, res, up);

  /* Set up at boundary points to zero. */
  updata = N_VGetDeviceArrayPointer_Cuda(up);

  unsigned block = 256;
  unsigned grid  = (mm * mm + block - 1) / block;

  setInitHeatKernel<<<grid, block>>>(updata, mm);

  return (0);
}

/*
 * Print first lines of output (problem description)
 */

static void PrintHeader(sunrealtype rtol, sunrealtype atol)
{
  printf("\nidaHeat2D_kry: Heat equation, serial example problem for IDA \n");
  printf("         Discretized heat equation on 2D unit square. \n");
  printf("         Zero boundary conditions,");
  printf(" polynomial initial conditions.\n");
  printf("         Mesh dimensions: %d x %d", MGRID, MGRID);
  printf("        Total system size: %d\n\n", NEQ);
#if defined(SUNDIALS_EXTENDED_PRECISION)
  printf("Tolerance parameters:  rtol = %Lg   atol = %Lg\n", rtol, atol);
#elif defined(SUNDIALS_DOUBLE_PRECISION)
  printf("Tolerance parameters:  rtol = %g   atol = %g\n", rtol, atol);
#else
  printf("Tolerance parameters:  rtol = %g   atol = %g\n", rtol, atol);
#endif
  printf("Constraints set to force all solution components >= 0. \n");
  printf("Linear solver: SPGMR, preconditioner using diagonal elements. \n");
}

/*
 * PrintOutput: print max norm of solution and current solver statistics
 */

static void PrintOutput(void* mem, sunrealtype t, N_Vector uu)
{
  sunrealtype hused, umax;
  long int nst, nni, nje, nre, nreLS, nli, npe, nps;
  int kused, ier;

  umax = N_VMaxNorm(uu);

  ier = IDAGetLastOrder(mem, &kused);
  check_flag(&ier, "IDAGetLastOrder", 1);
  ier = IDAGetNumSteps(mem, &nst);
  check_flag(&ier, "IDAGetNumSteps", 1);
  ier = IDAGetNumNonlinSolvIters(mem, &nni);
  check_flag(&ier, "IDAGetNumNonlinSolvIters", 1);
  ier = IDAGetNumResEvals(mem, &nre);
  check_flag(&ier, "IDAGetNumResEvals", 1);
  ier = IDAGetLastStep(mem, &hused);
  check_flag(&ier, "IDAGetLastStep", 1);
  ier = IDAGetNumJtimesEvals(mem, &nje);
  check_flag(&ier, "IDAGetNumJtimesEvals", 1);
  ier = IDAGetNumLinIters(mem, &nli);
  check_flag(&ier, "IDAGetNumLinIters", 1);
  ier = IDAGetNumLinResEvals(mem, &nreLS);
  check_flag(&ier, "IDAGetNumLinResEvals", 1);
  ier = IDAGetNumPrecEvals(mem, &npe);
  check_flag(&ier, "IDAGetPrecEvals", 1);
  ier = IDAGetNumPrecSolves(mem, &nps);
  check_flag(&ier, "IDAGetNumPrecSolves", 1);

#if defined(SUNDIALS_EXTENDED_PRECISION)
  printf(" %5.2Lf %13.5Le  %d  %3ld  %3ld  %3ld  %4ld  %4ld  %9.2Le  %3ld "
         "%3ld\n",
         t, umax, kused, nst, nni, nje, nre, nreLS, hused, npe, nps);
#elif defined(SUNDIALS_DOUBLE_PRECISION)
  printf(" %5.2f %13.5e  %d  %3ld  %3ld  %3ld  %4ld  %4ld  %9.2e  %3ld %3ld\n",
         t, umax, kused, nst, nni, nje, nre, nreLS, hused, npe, nps);
#else
  printf(" %5.2f %13.5e  %d  %3ld  %3ld  %3ld  %4ld  %4ld  %9.2e  %3ld %3ld\n",
         t, umax, kused, nst, nni, nje, nre, nreLS, hused, npe, nps);
#endif
}

/*
 * Check function return value...
 *   opt == 0 means SUNDIALS function allocates memory so check if
 *            returned NULL pointer
 *   opt == 1 means SUNDIALS function returns a flag so check if
 *            flag >= 0
 *   opt == 2 means function allocates memory so check if returned
 *            NULL pointer
 */

static int check_flag(void* flagvalue, const char* funcname, int opt)
{
  int* errflag;

  /* Check if SUNDIALS function returned NULL pointer - no memory allocated */
  if (opt == 0 && flagvalue == NULL)
  {
    fprintf(stderr, "\nSUNDIALS_ERROR: %s() failed - returned NULL pointer\n\n",
            funcname);
    return (1);
  }
  else if (opt == 1)
  {
    /* Check if flag < 0 */
    errflag = (int*)flagvalue;
    if (*errflag < 0)
    {
      fprintf(stderr, "\nSUNDIALS_ERROR: %s() failed with flag = %d\n\n",
              funcname, *errflag);
      return (1);
    }
  }
  else if (opt == 2 && flagvalue == NULL)
  {
    /* Check if function returned NULL pointer - no memory allocated */
    fprintf(stderr, "\nMEMORY_ERROR: %s() failed - returned NULL pointer\n\n",
            funcname);
    return (1);
  }

  return (0);
}
