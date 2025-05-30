/* ------------------------------------------------------------------
 * Programmer(s): David J. Gardner @ LLNL
 * ------------------------------------------------------------------
 * Based an example program by Rujeko Chinomona @ SMU.
 * ------------------------------------------------------------------
 * SUNDIALS Copyright Start
 * Copyright (c) 2002-2025, Lawrence Livermore National Security
 * and Southern Methodist University.
 * All rights reserved.
 *
 * See the top-level LICENSE and NOTICE files for details.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 * SUNDIALS Copyright End
 * ------------------------------------------------------------------
 * Example problem:
 *
 * The following test simulates a simple 1D reaction-diffusion
 * equation,
 *
 *   y_t = k * y_xx + y^2 * (1-y)
 *
 * for t in [0, 3], x in [0, L] with boundary conditions,
 *
 *   y_x(0,t) = y_x(L,t) = 0
 *
 * and initial condition,
 *
 *   y(x,0) = (1 + exp(lambda*(x-1))^(-1),
 *
 * with parameter k = 1e-4/ep, lambda = 0.5*sqrt(2*ep*1e4),
 * ep = 1e-2, and L = 5.
 *
 * The spatial derivatives are computed using second-order
 * centered differences, with the data distributed over N points
 * on a uniform spatial grid.
 *
 * This program solves the problem with the MRI stepper. Outputs are
 * printed at equal intervals of 0.1 and run statistics are printed
 * at the end.
 * ----------------------------------------------------------------*/

/* Header files */
#include <arkode/arkode_arkstep.h> /* prototypes for ARKStep fcts., consts */
#include <arkode/arkode_mristep.h> /* prototypes for MRIStep fcts., consts */
#include <math.h>
#include <nvector/nvector_serial.h> /* serial N_Vector types, fcts., macros */
#include <stdio.h>
#include <stdlib.h>
#include <sundials/sundials_types.h> /* defs. of sunrealtype, sunindextype, etc */

#if defined(SUNDIALS_EXTENDED_PRECISION)
#define GSYM "Lg"
#define ESYM "Le"
#define FSYM "Lf"
#else
#define GSYM "g"
#define ESYM "e"
#define FSYM "f"
#endif

/* user data structure */
typedef struct
{
  sunindextype N; /* number of intervals   */
  sunrealtype dx; /* mesh spacing          */
  sunrealtype k;  /* diffusion coefficient */
  sunrealtype lam;
}* UserData;

/* User-supplied Functions Called by the Solver */
static int fs(sunrealtype t, N_Vector y, N_Vector ydot, void* user_data);
static int ff(sunrealtype t, N_Vector y, N_Vector ydot, void* user_data);

/* Private function to set initial condition */
static int SetInitialCondition(N_Vector y, UserData udata);

/* Private function to check function return values */
static int check_retval(void* returnvalue, const char* funcname, int opt);

/* Main Program */
int main(void)
{
  /* general problem parameters */
  sunrealtype T0    = SUN_RCONST(0.0);       /* initial time */
  sunrealtype Tf    = SUN_RCONST(3.0);       /* final time */
  sunrealtype dTout = SUN_RCONST(0.1);       /* time between outputs */
  int Nt            = (int)ceil(Tf / dTout); /* number of output times */
  sunrealtype hs    = SUN_RCONST(0.001);     /* slow step size */
  sunrealtype hf    = SUN_RCONST(0.00002);   /* fast step size */
  UserData udata    = NULL;                  /* user data */

  sunrealtype* data;                /* array for solution output */
  sunrealtype L  = SUN_RCONST(5.0); /* domain length */
  sunindextype N = 1001;            /* number of mesh points */
  sunrealtype ep = SUN_RCONST(1e-2);
  sunindextype i;

  /* general problem variables */
  int retval;                    /* reusable error-checking flag */
  N_Vector y             = NULL; /* empty vector for storing solution */
  void* arkode_mem       = NULL; /* empty ARKode memory structure */
  void* inner_arkode_mem = NULL; /* empty ARKode memory structure */
  MRIStepInnerStepper inner_stepper = NULL; /* inner stepper */
  FILE *FID, *UFID;
  sunrealtype t, tout;
  int iout;

  /* Create the SUNDIALS context object for this simulation */
  SUNContext ctx;
  retval = SUNContext_Create(SUN_COMM_NULL, &ctx);
  if (check_retval(&retval, "SUNContext_Create", 1)) { return 1; }

  /*
   * Initialization
   */

  /* allocate and fill user data structure */
  udata      = (UserData)malloc(sizeof(*udata));
  udata->N   = N;
  udata->dx  = L / (SUN_RCONST(1.0) * N - SUN_RCONST(1.0));
  udata->k   = SUN_RCONST(1e-4) / ep;
  udata->lam = SUN_RCONST(0.5) * sqrt(SUN_RCONST(2.0) * ep * SUN_RCONST(1e4));

  /* Initial problem output */
  printf("\n1D reaction-diffusion PDE test problem:\n");
  printf("  N = %li\n", (long int)udata->N);
  printf("  diffusion coefficient:  k = %" GSYM "\n", udata->k);

  /* Create and initialize serial vector for the solution */
  y = N_VNew_Serial(N, ctx);
  if (check_retval((void*)y, "N_VNew_Serial", 0)) { return 1; }

  retval = SetInitialCondition(y, udata);
  if (check_retval(&retval, "SetInitialCondition", 1)) { return 1; }

  /*
   * Create the fast integrator and set options
   */

  /* Initialize the fast integrator. Specify the explicit fast right-hand side
     function in y'=fe(t,y)+fi(t,y)+ff(t,y), the initial time T0, and the
     initial dependent variable vector y. */
  inner_arkode_mem = ARKStepCreate(ff, NULL, T0, y, ctx);
  if (check_retval((void*)inner_arkode_mem, "ARKStepCreate", 0)) { return 1; }

  /* Attach user data to fast integrator */
  retval = ARKodeSetUserData(inner_arkode_mem, (void*)udata);
  if (check_retval(&retval, "ARKodeSetUserData", 1)) { return 1; }

  /* Set the fast method */
  retval = ARKStepSetTableNum(inner_arkode_mem, -1, ARKODE_KNOTH_WOLKE_3_3);
  if (check_retval(&retval, "ARKStepSetTableNum", 1)) { return 1; }

  /* Set the fast step size */
  retval = ARKodeSetFixedStep(inner_arkode_mem, hf);
  if (check_retval(&retval, "ARKodeSetFixedStep", 1)) { return 1; }

  /* Create inner stepper */
  retval = ARKodeCreateMRIStepInnerStepper(inner_arkode_mem, &inner_stepper);
  if (check_retval(&retval, "ARKodeCreateMRIStepInnerStepper", 1)) { return 1; }

  /*
   * Create the slow integrator and set options
   */

  /* Initialize the slow integrator. Specify the explicit slow right-hand side
     function in y'=fe(t,y)+fi(t,y)+ff(t,y), the initial time T0, the
     initial dependent variable vector y, and the fast integrator. */
  arkode_mem = MRIStepCreate(fs, NULL, T0, y, inner_stepper, ctx);
  if (check_retval((void*)arkode_mem, "MRIStepCreate", 0)) { return 1; }

  /* Pass udata to user functions */
  retval = ARKodeSetUserData(arkode_mem, (void*)udata);
  if (check_retval(&retval, "ARKodeSetUserData", 1)) { return 1; }

  /* Set the slow step size */
  retval = ARKodeSetFixedStep(arkode_mem, hs);
  if (check_retval(&retval, "ARKodeSetFixedStep", 1)) { return 1; }

  /* Increase max num steps  */
  retval = ARKodeSetMaxNumSteps(arkode_mem, 10000);
  if (check_retval(&retval, "ARKodeSetMaxNumSteps", 1)) { return 1; }

  /*
   * Integrate ODE
   */

  /* output mesh to disk */
  FID = fopen("heat_mesh.txt", "w");
  for (i = 0; i < N; i++) { fprintf(FID, "  %.16" ESYM "\n", udata->dx * i); }
  fclose(FID);

  /* Open output stream for results, access data array */
  UFID = fopen("heat1D.txt", "w");
  data = N_VGetArrayPointer(y);

  /* output initial condition to disk */
  for (i = 0; i < N; i++) { fprintf(UFID, " %.16" ESYM "", data[i]); }
  fprintf(UFID, "\n");

  /* Main time-stepping loop: calls ARKodeEvolve to perform the integration, then
     prints results. Stops when the final time has been reached */
  t     = T0;
  dTout = (Tf - T0) / Nt;
  tout  = T0 + dTout;
  printf("        t      ||u||_rms\n");
  printf("   -------------------------\n");
  printf("  %10.6" FSYM "  %10.6f\n", t, sqrt(N_VDotProd(y, y) / N));
  for (iout = 0; iout < Nt; iout++)
  {
    /* call integrator */
    retval = ARKodeEvolve(arkode_mem, tout, y, &t, ARK_NORMAL);
    if (check_retval(&retval, "ARKodeEvolve", 1)) { break; }

    /* print solution stats and output results to disk */
    printf("  %10.6" FSYM "  %10.6f\n", t, sqrt(N_VDotProd(y, y) / N));
    for (i = 0; i < N; i++) { fprintf(UFID, " %.16" ESYM "", data[i]); }
    fprintf(UFID, "\n");

    /* successful solve: update output time */
    tout += dTout;
    tout = (tout > Tf) ? Tf : tout;
  }
  printf("   -------------------------\n");
  fclose(UFID);

  /* Print final statistics to the screen */
  printf("\nFinal Slow Statistics:\n");
  retval = ARKodePrintAllStats(arkode_mem, stdout, SUN_OUTPUTFORMAT_TABLE);
  printf("\nFinal Fast Statistics:\n");
  retval = ARKodePrintAllStats(inner_arkode_mem, stdout, SUN_OUTPUTFORMAT_TABLE);

  /* Print final statistics to a file in CSV format */
  FID    = fopen("ark_reaction_diffusion_mri_slow_stats.csv", "w");
  retval = ARKodePrintAllStats(arkode_mem, FID, SUN_OUTPUTFORMAT_CSV);
  fclose(FID);
  FID    = fopen("ark_reaction_diffusion_mri_fast_stats.csv", "w");
  retval = ARKodePrintAllStats(inner_arkode_mem, FID, SUN_OUTPUTFORMAT_CSV);
  fclose(FID);

  /* Clean up and return */
  N_VDestroy(y);                            /* Free y vector */
  ARKodeFree(&inner_arkode_mem);            /* Free integrator memory */
  MRIStepInnerStepper_Free(&inner_stepper); /* Free inner stepper */
  ARKodeFree(&arkode_mem);                  /* Free integrator memory */
  free(udata);                              /* Free user data */
  SUNContext_Free(&ctx);                    /* Free context */

  return 0;
}

/* ------------------------------
 * Functions called by the solver
 * ------------------------------*/

/* ff routine to compute the fast portion of the ODE RHS. */
static int ff(sunrealtype t, N_Vector y, N_Vector ydot, void* user_data)
{
  UserData udata = (UserData)user_data; /* access problem data */
  sunindextype N = udata->N;            /* set variable shortcuts */
  sunrealtype *Y = NULL, *Ydot = NULL;
  sunindextype i;

  /* access state array data */
  Y = N_VGetArrayPointer(y);
  if (check_retval((void*)Y, "N_VGetArrayPointer", 0)) { return 1; }

  /* access RHS array data */
  Ydot = N_VGetArrayPointer(ydot);
  if (check_retval((void*)Ydot, "N_VGetArrayPointer", 0)) { return 1; }

  /* iterate over domain, computing reaction term */
  for (i = 0; i < N; i++) { Ydot[i] = Y[i] * Y[i] * (SUN_RCONST(1.0) - Y[i]); }

  /* Return with success */
  return 0;
}

/* fs routine to compute the slow portion of the ODE RHS. */
static int fs(sunrealtype t, N_Vector y, N_Vector ydot, void* user_data)
{
  UserData udata = (UserData)user_data; /* access problem data */
  sunindextype N = udata->N;            /* set variable shortcuts */
  sunrealtype k  = udata->k;
  sunrealtype dx = udata->dx;
  sunrealtype *Y = NULL, *Ydot = NULL;
  sunrealtype c1, c2;
  sunindextype i;

  /* access state array data */
  Y = N_VGetArrayPointer(y);
  if (check_retval((void*)Y, "N_VGetArrayPointer", 0)) { return 1; }

  /* access RHS array data */
  Ydot = N_VGetArrayPointer(ydot);
  if (check_retval((void*)Ydot, "N_VGetArrayPointer", 0)) { return 1; }

  /* iterate over domain, computing diffusion term */
  c1 = k / dx / dx;
  c2 = SUN_RCONST(2.0) * k / dx / dx;

  /* left boundary condition */
  Ydot[0] = c2 * (Y[1] - Y[0]);

  /* interior points */
  for (i = 1; i < N - 1; i++)
  {
    Ydot[i] = c1 * Y[i - 1] - c2 * Y[i] + c1 * Y[i + 1];
  }

  /* right boundary condition */
  Ydot[N - 1] = c2 * (Y[N - 2] - Y[N - 1]);

  /* Return with success */
  return 0;
}

/* -----------------------------------------
 * Private function to set initial condition
 * -----------------------------------------*/

static int SetInitialCondition(N_Vector y, UserData user_data)
{
  UserData udata  = (UserData)user_data; /* access problem data */
  sunindextype N  = udata->N;            /* set variable shortcuts */
  sunrealtype lam = udata->lam;
  sunrealtype dx  = udata->dx;
  sunrealtype* Y  = NULL;
  sunindextype i;

  /* access state array data */
  Y = N_VGetArrayPointer(y);
  if (check_retval((void*)Y, "N_VGetArrayPointer", 0)) { return -1; }

  /* set initial condition */
  for (i = 0; i < N; i++)
  {
    Y[i] = SUN_RCONST(1.0) / (1 + exp(lam * (i * dx - SUN_RCONST(1.0))));
  }

  /* Return with success */
  return 0;
}

/* ------------------------------
 * Private helper functions
 * ------------------------------*/

/* Check function return value...
    opt == 0 means SUNDIALS function allocates memory so check if
             returned NULL pointer
    opt == 1 means SUNDIALS function returns a retval so check if
             retval < 0
    opt == 2 means function allocates memory so check if returned
             NULL pointer
*/
static int check_retval(void* returnvalue, const char* funcname, int opt)
{
  int* retval;

  /* Check if SUNDIALS function returned NULL pointer - no memory allocated */
  if (opt == 0 && returnvalue == NULL)
  {
    fprintf(stderr, "\nSUNDIALS_ERROR: %s() failed - returned NULL pointer\n\n",
            funcname);
    return 1;
  }

  /* Check if retval < 0 */
  else if (opt == 1)
  {
    retval = (int*)returnvalue;
    if (*retval < 0)
    {
      fprintf(stderr, "\nSUNDIALS_ERROR: %s() failed with retval = %d\n\n",
              funcname, *retval);
      return 1;
    }
  }

  /* Check if function returned NULL pointer - no memory allocated */
  else if (opt == 2 && returnvalue == NULL)
  {
    fprintf(stderr, "\nMEMORY_ERROR: %s() failed - returned NULL pointer\n\n",
            funcname);
    return 1;
  }

  return 0;
}

/*---- end of file ----*/
