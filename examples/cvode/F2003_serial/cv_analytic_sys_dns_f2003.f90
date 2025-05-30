! ------------------------------------------------------------------
! Programmer(s): David J. Gardner, Cody J. Balos  @ LLNL
! ------------------------------------------------------------------
! SUNDIALS Copyright Start
! Copyright (c) 2002-2025, Lawrence Livermore National Security
! and Southern Methodist University.
! All rights reserved.
!
! See the top-level LICENSE and NOTICE files for details.
!
! SPDX-License-Identifier: BSD-3-Clause
! SUNDIALS Copyright End
! ------------------------------------------------------------------
! The following is a simple example problem with an analytical
! solution.
!
!   dy/dt = A * y
!
! where A = V * D * Vi
!
!      [ lambda/4 - 23/40 | lambda/4 - 3/40 | lambda/4 + 13/40 ]
!  A = [ lambda/4 + 21/40 | lambda/4 + 1/40 | lambda/4 - 11/40 ]
!      [ lambda/2 + 1/20  | lambda/2 + 1/20 | lambda/2 - 1/20  ]
!
!      [  1 -1 1 ]     [ -1/2   0     0   ]      [ 5/4 1/4 -3/4 ]
!  V = [ -1  2 1 ] D = [   0  -1/10   0   ] Vi = [ 1/2 1/2 -1/2 ]
!      [  0 -1 2 ]     [   0    0   lambda ]      [ 1/4 1/4  1/4 ]
!
! and lambda is a large negative number. The analytical solution to
! this problem is
!
!   y(t) = V * exp(D * t) * Vi * y0
!
! for t in the interval [0.0, 0.05], with initial condition:
! y(0) = [1,1,1]'.
!
! The stiffness of the problem is directly proportional to the value
! of lambda. The value of lambda should be negative to result in a
! well-posed ODE; for values with magnitude larger than 100 the
! problem becomes quite stiff.
!
! In this example, we choose lambda = -100.
!
! Output is printed every 1.0 units of time (10 total).
! Run statistics (optional outputs) are printed at the end.
! ------------------------------------------------------------------

module ode_mod

  !======= Inclusions ===========
  use, intrinsic :: iso_c_binding
  use fsundials_core_mod

  !======= Declarations =========
  implicit none

  ! number of equations
  integer(c_int64_t), parameter :: neq = 3

  ! ODE parameters
  double precision, parameter :: lambda = -100.0d0

contains

  ! ----------------------------------------------------------------
  ! RhsFn: The right hand side function for the ODE dy/dt = A * y
  !
  ! Return values:
  !    0 = success,
  !    1 = recoverable error,
  !   -1 = non-recoverable error
  ! ----------------------------------------------------------------
  integer(c_int) function RhsFn(tn, sunvec_y, sunvec_f, user_data) &
    result(ierr) bind(C, name='RhsFn')

    !======= Inclusions ===========
    use, intrinsic :: iso_c_binding

    !======= Declarations =========
    implicit none

    ! calling variables
    real(c_double), value :: tn        ! current time
    type(N_Vector)        :: sunvec_y  ! solution N_Vector
    type(N_Vector)        :: sunvec_f  ! rhs N_Vector
    type(c_ptr), value :: user_data ! user-defined data

    ! pointers to data in SUNDIALS vectors
    real(c_double), pointer :: yvec(:)
    real(c_double), pointer :: fvec(:)

    ! ODE system matrix
    real(c_double) :: Amat(neq, neq)

    !======= Internals ============

    ! get data arrays from SUNDIALS vectors
    yvec => FN_VGetArrayPointer(sunvec_y)
    fvec => FN_VGetArrayPointer(sunvec_f)

    ! fill A matrix (column major ordering)
    Amat = reshape([ &
                   lambda/4.d0 - 23.d0/40.d0, lambda/4.d0 + 21.d0/40, lambda/2.d0 + 1.d0/20.d0, &
                   lambda/4.d0 - 3.d0/40.d0, lambda/4.d0 + 1.d0/40, lambda/2.d0 + 1.d0/20.d0, &
                   lambda/4.d0 + 13.d0/40.d0, lambda/4.d0 - 11.d0/40, lambda/2.d0 - 1.d0/20.d0], &
                   [3, 3])

    ! fill RHS vector f(t,y) = A*y
    fvec = matmul(Amat, yvec(1:neq))

    ! return success
    ierr = 0
    return

  end function RhsFn

end module ode_mod

program main

  !======= Inclusions ===========
  use, intrinsic :: iso_c_binding
  use fsundials_core_mod
  use fcvode_mod                 ! Fortran interface to CVODE
  use fnvector_serial_mod        ! Fortran interface to serial N_Vector
  use fsunmatrix_dense_mod       ! Fortran interface to dense SUNMatrix
  use fsunlinsol_dense_mod       ! Fortran interface to dense SUNLinearSolver
  use ode_mod                    ! ODE functions

  !======= Declarations =========
  implicit none

  ! local variables
  real(c_double) :: tstart     ! initial time
  real(c_double) :: tend       ! final time
  real(c_double) :: rtol, atol ! relative and absolute tolerance
  real(c_double) :: dtout      ! output time interval
  real(c_double) :: tout       ! output time
  real(c_double) :: tcur(1)    ! current time

  integer(c_int) :: ierr       ! error flag from C functions
  integer(c_int) :: nout       ! number of outputs

  integer :: outstep           ! output loop counter

  type(N_Vector), pointer :: sunvec_y      ! sundials vector
  type(SUNMatrix), pointer :: sunmat_A      ! sundials matrix
  type(SUNLinearSolver), pointer :: sunlinsol_LS  ! sundials linear solver
  type(c_ptr)                    :: ctx           ! SUNDIALS simulation context
  type(c_ptr)                    :: cvode_mem     ! CVODE memory

  ! solution vector, neq is set in the ode_mod module
  real(c_double) :: yvec(neq)

  !======= Internals ============

  ! initialize ODE
  tstart = 0.0d0
  tend = 0.05d0
  tcur = tstart
  tout = tstart
  dtout = 0.005d0
  nout = ceiling(tend/dtout)

  ! initialize solution vector
  yvec(1) = 1.0d0
  yvec(2) = 1.0d0
  yvec(3) = 1.0d0

  ! create SUNDIALS context
  ierr = FSUNContext_Create(SUN_COMM_NULL, ctx)

  ! create a serial vector
  sunvec_y => FN_VMake_Serial(neq, yvec, ctx)
  if (.not. associated(sunvec_y)) then
    print *, 'ERROR: sunvec = NULL'
    stop 1
  end if

  ! create a dense matrix
  sunmat_A => FSUNDenseMatrix(neq, neq, ctx)
  if (.not. associated(sunmat_A)) then
    print *, 'ERROR: sunmat = NULL'
    stop 1
  end if

  ! create a dense linear solver
  sunlinsol_LS => FSUNLinSol_Dense(sunvec_y, sunmat_A, ctx)
  if (.not. associated(sunlinsol_LS)) then
    print *, 'ERROR: sunlinsol = NULL'
    stop 1
  end if

  ! create CVode memory
  cvode_mem = FCVodeCreate(CV_BDF, ctx)
  if (.not. c_associated(cvode_mem)) then
    print *, 'ERROR: cvode_mem = NULL'
    stop 1
  end if

  ! initialize CVode
  ierr = FCVodeInit(cvode_mem, c_funloc(RhsFn), tstart, sunvec_y)
  if (ierr /= 0) then
    print *, 'Error in FCVodeInit, ierr = ', ierr, '; halting'
    stop 1
  end if

  ! set relative and absolute tolerances
  rtol = 1.0d-6
  atol = 1.0d-10

  ierr = FCVodeSStolerances(cvode_mem, rtol, atol)
  if (ierr /= 0) then
    print *, 'Error in FCVodeSStolerances, ierr = ', ierr, '; halting'
    stop 1
  end if

  ! attach linear solver
  ierr = FCVodeSetLinearSolver(cvode_mem, sunlinsol_LS, sunmat_A); 
  if (ierr /= 0) then
    print *, 'Error in FCVodeSetLinearSolver, ierr = ', ierr, '; halting'
    stop 1
  end if

  ! start time stepping
  print *, '   '
  print *, 'Finished initialization, starting time steps'
  print *, '   '
  print *, '       t           y1           y2           y3       '
  print *, '------------------------------------------------------'
  print '(2x,4(es12.5,1x))', tcur, yvec(1), yvec(2), yvec(3)
  do outstep = 1, nout

    ! call CVode
    tout = min(tout + dtout, tend)
    ierr = FCVode(cvode_mem, tout, sunvec_y, tcur, CV_NORMAL)
    if (ierr /= 0) then
      print *, 'Error in FCVODE, ierr = ', ierr, '; halting'
      stop 1
    end if

    ! output current solution
    print '(2x,4(es12.5,1x))', tcur, yvec(1), yvec(2), yvec(3)

  end do

  ! diagnostics output
  call CVodeStats(cvode_mem)

  ! clean up
  call FCVodeFree(cvode_mem)
  ierr = FSUNLinSolFree(sunlinsol_LS)
  call FSUNMatDestroy(sunmat_A)
  call FN_VDestroy(sunvec_y)
  ierr = FSUNContext_Free(ctx)

end program main

! ----------------------------------------------------------------
! CVodeStats
!
! Print CVODE statstics to standard out
! ----------------------------------------------------------------
subroutine CVodeStats(cvode_mem)

  !======= Inclusions ===========
  use iso_c_binding
  use fcvode_mod

  !======= Declarations =========
  implicit none

  type(c_ptr), intent(in) :: cvode_mem ! solver memory structure

  integer(c_int)  :: ierr          ! error flag

  integer(c_long) :: nsteps(1)     ! num steps
  integer(c_long) :: nfevals(1)    ! num function evals
  integer(c_long) :: nlinsetups(1) ! num linear solver setups
  integer(c_long) :: netfails(1)   ! num error test fails

  integer(c_int)  :: qlast(1)      ! method order in last step
  integer(c_int)  :: qcur(1)       ! method order for next step

  real(c_double)  :: hinused(1)    ! initial step size
  real(c_double)  :: hlast(1)      ! last step size
  real(c_double)  :: hcur(1)       ! step size for next step
  real(c_double)  :: tcur(1)       ! internal time reached

  integer(c_long) :: nniters(1)    ! nonlinear solver iterations
  integer(c_long) :: nncfails(1)   ! nonlinear solver fails

  integer(c_long) :: njevals(1)    ! num Jacobian evaluations

  !======= Internals ============

  ! general solver statistics
  ierr = FCVodeGetIntegratorStats(cvode_mem, nsteps, nfevals, nlinsetups, &
                                  netfails, qlast, qcur, hinused, hlast, hcur, tcur)
  if (ierr /= 0) then
    print *, 'Error in FCVodeGetIntegratorStats, ierr = ', ierr, '; halting'
    stop 1
  end if

  ! nonlinear solver statistics
  ierr = FCVodeGetNonlinSolvStats(cvode_mem, nniters, nncfails)
  if (ierr /= 0) then
    print *, 'Error in FCVodeGetNonlinSolvStats, ierr = ', ierr, '; halting'
    stop 1
  end if

  ! number of Jacobian evaluations
  ierr = FCVodeGetNumJacEvals(cvode_mem, njevals)
  if (ierr /= 0) then
    print *, 'Error in FCVodeGetNumJacEvals, ierr = ', ierr, '; halting'
    stop 1
  end if

  print *, ' '
  print *, ' General Solver Stats:'
  print '(4x,A,i9)', 'Total internal steps taken =', nsteps
  print '(4x,A,i9)', 'Total rhs function calls   =', nfevals
  print '(4x,A,i9)', 'Num lin solver setup calls =', nlinsetups
  print '(4x,A,i9)', 'Num error test failures    =', netfails
  print '(4x,A,i9)', 'Last method order          =', qlast
  print '(4x,A,i9)', 'Next method order          =', qcur
  print '(4x,A,es12.5)', 'First internal step size   =', hinused
  print '(4x,A,es12.5)', 'Last internal step size    =', hlast
  print '(4x,A,es12.5)', 'Next internal step size    =', hcur
  print '(4x,A,es12.5)', 'Current internal time      =', tcur
  print '(4x,A,i9)', 'Num nonlinear solver iters =', nniters
  print '(4x,A,i9)', 'Num nonlinear solver fails =', nncfails
  print '(4x,A,i9)', 'Num Jacobian evaluations   =', njevals
  print *, ' '

  return

end subroutine CVodeStats
