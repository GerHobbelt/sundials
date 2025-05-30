! This file was automatically generated by SWIG (http://www.swig.org).
! Version 4.0.0
!
! Do not make changes to this file unless you know what you are doing--modify
! the SWIG interface file instead.

! ---------------------------------------------------------------
! Programmer(s): Auto-generated by swig.
! ---------------------------------------------------------------
! SUNDIALS Copyright Start
! Copyright (c) 2002-2025, Lawrence Livermore National Security
! and Southern Methodist University.
! All rights reserved.
!
! See the top-level LICENSE and NOTICE files for details.
!
! SPDX-License-Identifier: BSD-3-Clause
! SUNDIALS Copyright End
! ---------------------------------------------------------------

module farkode_splittingstep_mod
 use, intrinsic :: ISO_C_BINDING
 use farkode_mod
 use fsundials_core_mod
 implicit none
 private

 ! DECLARATION CONSTRUCTS

 integer, parameter :: swig_cmem_own_bit = 0
 integer, parameter :: swig_cmem_rvalue_bit = 1
 integer, parameter :: swig_cmem_const_bit = 2
 type, bind(C) :: SwigClassWrapper
  type(C_PTR), public :: cptr = C_NULL_PTR
  integer(C_INT), public :: cmemflags = 0
 end type
 ! struct struct SplittingStepCoefficientsMem
 type, public :: SplittingStepCoefficientsMem
  type(SwigClassWrapper), public :: swigdata
 contains
  procedure :: set_alpha => swigf_SplittingStepCoefficientsMem_alpha_set
  procedure :: get_alpha => swigf_SplittingStepCoefficientsMem_alpha_get
  procedure :: set_beta => swigf_SplittingStepCoefficientsMem_beta_set
  procedure :: get_beta => swigf_SplittingStepCoefficientsMem_beta_get
  procedure :: set_sequential_methods => swigf_SplittingStepCoefficientsMem_sequential_methods_set
  procedure :: get_sequential_methods => swigf_SplittingStepCoefficientsMem_sequential_methods_get
  procedure :: set_stages => swigf_SplittingStepCoefficientsMem_stages_set
  procedure :: get_stages => swigf_SplittingStepCoefficientsMem_stages_get
  procedure :: set_partitions => swigf_SplittingStepCoefficientsMem_partitions_set
  procedure :: get_partitions => swigf_SplittingStepCoefficientsMem_partitions_get
  procedure :: set_order => swigf_SplittingStepCoefficientsMem_order_set
  procedure :: get_order => swigf_SplittingStepCoefficientsMem_order_get
  procedure :: release => swigf_release_SplittingStepCoefficientsMem
  procedure, private :: swigf_SplittingStepCoefficientsMem_op_assign__
  generic :: assignment(=) => swigf_SplittingStepCoefficientsMem_op_assign__
 end type SplittingStepCoefficientsMem
 interface SplittingStepCoefficientsMem
  module procedure swigf_create_SplittingStepCoefficientsMem
 end interface
 ! typedef enum ARKODE_SplittingCoefficientsID
 enum, bind(c)
  enumerator :: ARKODE_SPLITTING_NONE = -1
  enumerator :: ARKODE_MIN_SPLITTING_NUM = 0
  enumerator :: ARKODE_SPLITTING_LIE_TROTTER_1_1_2 = ARKODE_MIN_SPLITTING_NUM
  enumerator :: ARKODE_SPLITTING_STRANG_2_2_2
  enumerator :: ARKODE_SPLITTING_BEST_2_2_2
  enumerator :: ARKODE_SPLITTING_SUZUKI_3_3_2
  enumerator :: ARKODE_SPLITTING_RUTH_3_3_2
  enumerator :: ARKODE_SPLITTING_YOSHIDA_4_4_2
  enumerator :: ARKODE_SPLITTING_YOSHIDA_8_6_2
  enumerator :: ARKODE_MAX_SPLITTING_NUM = ARKODE_SPLITTING_YOSHIDA_8_6_2
 end enum
 integer, parameter, public :: ARKODE_SplittingCoefficientsID = kind(ARKODE_SPLITTING_NONE)
 public :: ARKODE_SPLITTING_NONE, ARKODE_MIN_SPLITTING_NUM, ARKODE_SPLITTING_LIE_TROTTER_1_1_2, ARKODE_SPLITTING_STRANG_2_2_2, &
    ARKODE_SPLITTING_BEST_2_2_2, ARKODE_SPLITTING_SUZUKI_3_3_2, ARKODE_SPLITTING_RUTH_3_3_2, ARKODE_SPLITTING_YOSHIDA_4_4_2, &
    ARKODE_SPLITTING_YOSHIDA_8_6_2, ARKODE_MAX_SPLITTING_NUM
 public :: FSplittingStepCoefficients_Alloc
 public :: FSplittingStepCoefficients_Create
 public :: FSplittingStepCoefficients_Destroy
 public :: FSplittingStepCoefficients_Copy
 public :: FSplittingStepCoefficients_Write
 public :: FSplittingStepCoefficients_LoadCoefficients
 type, bind(C) :: SwigArrayWrapper
  type(C_PTR), public :: data = C_NULL_PTR
  integer(C_SIZE_T), public :: size = 0
 end type
 public :: FSplittingStepCoefficients_LoadCoefficientsByName
 public :: FSplittingStepCoefficients_IDToName
 public :: FSplittingStepCoefficients_LieTrotter
 public :: FSplittingStepCoefficients_Strang
 public :: FSplittingStepCoefficients_Parallel
 public :: FSplittingStepCoefficients_SymmetricParallel
 public :: FSplittingStepCoefficients_ThirdOrderSuzuki
 public :: FSplittingStepCoefficients_TripleJump
 public :: FSplittingStepCoefficients_SuzukiFractal
 public :: FSplittingStepCreate
 public :: FSplittingStepReInit
 public :: FSplittingStepSetCoefficients
 public :: FSplittingStepGetNumEvolves

! WRAPPER DECLARATIONS
interface
subroutine swigc_SplittingStepCoefficientsMem_alpha_set(farg1, farg2) &
bind(C, name="_wrap_SplittingStepCoefficientsMem_alpha_set")
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: farg1
type(C_PTR), value :: farg2
end subroutine

function swigc_SplittingStepCoefficientsMem_alpha_get(farg1) &
bind(C, name="_wrap_SplittingStepCoefficientsMem_alpha_get") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: farg1
type(C_PTR) :: fresult
end function

subroutine swigc_SplittingStepCoefficientsMem_beta_set(farg1, farg2) &
bind(C, name="_wrap_SplittingStepCoefficientsMem_beta_set")
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: farg1
type(C_PTR), value :: farg2
end subroutine

function swigc_SplittingStepCoefficientsMem_beta_get(farg1) &
bind(C, name="_wrap_SplittingStepCoefficientsMem_beta_get") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: farg1
type(C_PTR) :: fresult
end function

subroutine swigc_SplittingStepCoefficientsMem_sequential_methods_set(farg1, farg2) &
bind(C, name="_wrap_SplittingStepCoefficientsMem_sequential_methods_set")
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: farg1
integer(C_INT), intent(in) :: farg2
end subroutine

function swigc_SplittingStepCoefficientsMem_sequential_methods_get(farg1) &
bind(C, name="_wrap_SplittingStepCoefficientsMem_sequential_methods_get") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: farg1
integer(C_INT) :: fresult
end function

subroutine swigc_SplittingStepCoefficientsMem_stages_set(farg1, farg2) &
bind(C, name="_wrap_SplittingStepCoefficientsMem_stages_set")
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: farg1
integer(C_INT), intent(in) :: farg2
end subroutine

function swigc_SplittingStepCoefficientsMem_stages_get(farg1) &
bind(C, name="_wrap_SplittingStepCoefficientsMem_stages_get") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: farg1
integer(C_INT) :: fresult
end function

subroutine swigc_SplittingStepCoefficientsMem_partitions_set(farg1, farg2) &
bind(C, name="_wrap_SplittingStepCoefficientsMem_partitions_set")
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: farg1
integer(C_INT), intent(in) :: farg2
end subroutine

function swigc_SplittingStepCoefficientsMem_partitions_get(farg1) &
bind(C, name="_wrap_SplittingStepCoefficientsMem_partitions_get") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: farg1
integer(C_INT) :: fresult
end function

subroutine swigc_SplittingStepCoefficientsMem_order_set(farg1, farg2) &
bind(C, name="_wrap_SplittingStepCoefficientsMem_order_set")
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: farg1
integer(C_INT), intent(in) :: farg2
end subroutine

function swigc_SplittingStepCoefficientsMem_order_get(farg1) &
bind(C, name="_wrap_SplittingStepCoefficientsMem_order_get") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: farg1
integer(C_INT) :: fresult
end function

function swigc_new_SplittingStepCoefficientsMem() &
bind(C, name="_wrap_new_SplittingStepCoefficientsMem") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: fresult
end function

subroutine swigc_delete_SplittingStepCoefficientsMem(farg1) &
bind(C, name="_wrap_delete_SplittingStepCoefficientsMem")
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper), intent(inout) :: farg1
end subroutine

subroutine swigc_SplittingStepCoefficientsMem_op_assign__(farg1, farg2) &
bind(C, name="_wrap_SplittingStepCoefficientsMem_op_assign__")
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper), intent(inout) :: farg1
type(SwigClassWrapper) :: farg2
end subroutine

function swigc_FSplittingStepCoefficients_Alloc(farg1, farg2, farg3) &
bind(C, name="_wrap_FSplittingStepCoefficients_Alloc") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
integer(C_INT), intent(in) :: farg1
integer(C_INT), intent(in) :: farg2
integer(C_INT), intent(in) :: farg3
type(SwigClassWrapper) :: fresult
end function

function swigc_FSplittingStepCoefficients_Create(farg1, farg2, farg3, farg4, farg5, farg6) &
bind(C, name="_wrap_FSplittingStepCoefficients_Create") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
integer(C_INT), intent(in) :: farg1
integer(C_INT), intent(in) :: farg2
integer(C_INT), intent(in) :: farg3
integer(C_INT), intent(in) :: farg4
type(C_PTR), value :: farg5
type(C_PTR), value :: farg6
type(SwigClassWrapper) :: fresult
end function

subroutine swigc_FSplittingStepCoefficients_Destroy(farg1) &
bind(C, name="_wrap_FSplittingStepCoefficients_Destroy")
use, intrinsic :: ISO_C_BINDING
type(C_PTR), value :: farg1
end subroutine

function swigc_FSplittingStepCoefficients_Copy(farg1) &
bind(C, name="_wrap_FSplittingStepCoefficients_Copy") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: farg1
type(SwigClassWrapper) :: fresult
end function

subroutine swigc_FSplittingStepCoefficients_Write(farg1, farg2) &
bind(C, name="_wrap_FSplittingStepCoefficients_Write")
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(SwigClassWrapper) :: farg1
type(C_PTR), value :: farg2
end subroutine

function swigc_FSplittingStepCoefficients_LoadCoefficients(farg1) &
bind(C, name="_wrap_FSplittingStepCoefficients_LoadCoefficients") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
integer(C_INT), intent(in) :: farg1
type(SwigClassWrapper) :: fresult
end function

function swigc_FSplittingStepCoefficients_LoadCoefficientsByName(farg1) &
bind(C, name="_wrap_FSplittingStepCoefficients_LoadCoefficientsByName") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
import :: swigarraywrapper
type(SwigArrayWrapper) :: farg1
type(SwigClassWrapper) :: fresult
end function

 subroutine SWIG_free(cptr) &
  bind(C, name="free")
 use, intrinsic :: ISO_C_BINDING
 type(C_PTR), value :: cptr
end subroutine
function swigc_FSplittingStepCoefficients_IDToName(farg1) &
bind(C, name="_wrap_FSplittingStepCoefficients_IDToName") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigarraywrapper
integer(C_INT), intent(in) :: farg1
type(SwigArrayWrapper) :: fresult
end function

function swigc_FSplittingStepCoefficients_LieTrotter(farg1) &
bind(C, name="_wrap_FSplittingStepCoefficients_LieTrotter") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
integer(C_INT), intent(in) :: farg1
type(SwigClassWrapper) :: fresult
end function

function swigc_FSplittingStepCoefficients_Strang(farg1) &
bind(C, name="_wrap_FSplittingStepCoefficients_Strang") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
integer(C_INT), intent(in) :: farg1
type(SwigClassWrapper) :: fresult
end function

function swigc_FSplittingStepCoefficients_Parallel(farg1) &
bind(C, name="_wrap_FSplittingStepCoefficients_Parallel") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
integer(C_INT), intent(in) :: farg1
type(SwigClassWrapper) :: fresult
end function

function swigc_FSplittingStepCoefficients_SymmetricParallel(farg1) &
bind(C, name="_wrap_FSplittingStepCoefficients_SymmetricParallel") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
integer(C_INT), intent(in) :: farg1
type(SwigClassWrapper) :: fresult
end function

function swigc_FSplittingStepCoefficients_ThirdOrderSuzuki(farg1) &
bind(C, name="_wrap_FSplittingStepCoefficients_ThirdOrderSuzuki") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
integer(C_INT), intent(in) :: farg1
type(SwigClassWrapper) :: fresult
end function

function swigc_FSplittingStepCoefficients_TripleJump(farg1, farg2) &
bind(C, name="_wrap_FSplittingStepCoefficients_TripleJump") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
integer(C_INT), intent(in) :: farg1
integer(C_INT), intent(in) :: farg2
type(SwigClassWrapper) :: fresult
end function

function swigc_FSplittingStepCoefficients_SuzukiFractal(farg1, farg2) &
bind(C, name="_wrap_FSplittingStepCoefficients_SuzukiFractal") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
integer(C_INT), intent(in) :: farg1
integer(C_INT), intent(in) :: farg2
type(SwigClassWrapper) :: fresult
end function

function swigc_FSplittingStepCreate(farg1, farg2, farg3, farg4, farg5) &
bind(C, name="_wrap_FSplittingStepCreate") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
type(C_PTR), value :: farg1
integer(C_INT), intent(in) :: farg2
real(C_DOUBLE), intent(in) :: farg3
type(C_PTR), value :: farg4
type(C_PTR), value :: farg5
type(C_PTR) :: fresult
end function

function swigc_FSplittingStepReInit(farg1, farg2, farg3, farg4, farg5) &
bind(C, name="_wrap_FSplittingStepReInit") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
type(C_PTR), value :: farg1
type(C_PTR), value :: farg2
integer(C_INT), intent(in) :: farg3
real(C_DOUBLE), intent(in) :: farg4
type(C_PTR), value :: farg5
integer(C_INT) :: fresult
end function

function swigc_FSplittingStepSetCoefficients(farg1, farg2) &
bind(C, name="_wrap_FSplittingStepSetCoefficients") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
import :: swigclasswrapper
type(C_PTR), value :: farg1
type(SwigClassWrapper) :: farg2
integer(C_INT) :: fresult
end function

function swigc_FSplittingStepGetNumEvolves(farg1, farg2, farg3) &
bind(C, name="_wrap_FSplittingStepGetNumEvolves") &
result(fresult)
use, intrinsic :: ISO_C_BINDING
type(C_PTR), value :: farg1
integer(C_INT), intent(in) :: farg2
type(C_PTR), value :: farg3
integer(C_INT) :: fresult
end function

end interface


contains
 ! MODULE SUBPROGRAMS
subroutine swigf_SplittingStepCoefficientsMem_alpha_set(self, alpha)
use, intrinsic :: ISO_C_BINDING
class(SplittingStepCoefficientsMem), intent(in) :: self
real(C_DOUBLE), dimension(*), target, intent(inout) :: alpha
type(SwigClassWrapper) :: farg1 
type(C_PTR) :: farg2 

farg1 = self%swigdata
farg2 = c_loc(alpha(1))
call swigc_SplittingStepCoefficientsMem_alpha_set(farg1, farg2)
end subroutine

function swigf_SplittingStepCoefficientsMem_alpha_get(self) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
real(C_DOUBLE), dimension(:), pointer :: swig_result
class(SplittingStepCoefficientsMem), intent(in) :: self
type(C_PTR) :: fresult 
type(SwigClassWrapper) :: farg1 

farg1 = self%swigdata
fresult = swigc_SplittingStepCoefficientsMem_alpha_get(farg1)
call c_f_pointer(fresult, swig_result, [1])
end function

subroutine swigf_SplittingStepCoefficientsMem_beta_set(self, beta)
use, intrinsic :: ISO_C_BINDING
class(SplittingStepCoefficientsMem), intent(in) :: self
type(C_PTR), target, intent(inout) :: beta
type(SwigClassWrapper) :: farg1 
type(C_PTR) :: farg2 

farg1 = self%swigdata
farg2 = c_loc(beta)
call swigc_SplittingStepCoefficientsMem_beta_set(farg1, farg2)
end subroutine

function swigf_SplittingStepCoefficientsMem_beta_get(self) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
type(C_PTR), pointer :: swig_result
class(SplittingStepCoefficientsMem), intent(in) :: self
type(C_PTR) :: fresult 
type(SwigClassWrapper) :: farg1 

farg1 = self%swigdata
fresult = swigc_SplittingStepCoefficientsMem_beta_get(farg1)
call c_f_pointer(fresult, swig_result)
end function

subroutine swigf_SplittingStepCoefficientsMem_sequential_methods_set(self, sequential_methods)
use, intrinsic :: ISO_C_BINDING
class(SplittingStepCoefficientsMem), intent(in) :: self
integer(C_INT), intent(in) :: sequential_methods
type(SwigClassWrapper) :: farg1 
integer(C_INT) :: farg2 

farg1 = self%swigdata
farg2 = sequential_methods
call swigc_SplittingStepCoefficientsMem_sequential_methods_set(farg1, farg2)
end subroutine

function swigf_SplittingStepCoefficientsMem_sequential_methods_get(self) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
integer(C_INT) :: swig_result
class(SplittingStepCoefficientsMem), intent(in) :: self
integer(C_INT) :: fresult 
type(SwigClassWrapper) :: farg1 

farg1 = self%swigdata
fresult = swigc_SplittingStepCoefficientsMem_sequential_methods_get(farg1)
swig_result = fresult
end function

subroutine swigf_SplittingStepCoefficientsMem_stages_set(self, stages)
use, intrinsic :: ISO_C_BINDING
class(SplittingStepCoefficientsMem), intent(in) :: self
integer(C_INT), intent(in) :: stages
type(SwigClassWrapper) :: farg1 
integer(C_INT) :: farg2 

farg1 = self%swigdata
farg2 = stages
call swigc_SplittingStepCoefficientsMem_stages_set(farg1, farg2)
end subroutine

function swigf_SplittingStepCoefficientsMem_stages_get(self) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
integer(C_INT) :: swig_result
class(SplittingStepCoefficientsMem), intent(in) :: self
integer(C_INT) :: fresult 
type(SwigClassWrapper) :: farg1 

farg1 = self%swigdata
fresult = swigc_SplittingStepCoefficientsMem_stages_get(farg1)
swig_result = fresult
end function

subroutine swigf_SplittingStepCoefficientsMem_partitions_set(self, partitions)
use, intrinsic :: ISO_C_BINDING
class(SplittingStepCoefficientsMem), intent(in) :: self
integer(C_INT), intent(in) :: partitions
type(SwigClassWrapper) :: farg1 
integer(C_INT) :: farg2 

farg1 = self%swigdata
farg2 = partitions
call swigc_SplittingStepCoefficientsMem_partitions_set(farg1, farg2)
end subroutine

function swigf_SplittingStepCoefficientsMem_partitions_get(self) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
integer(C_INT) :: swig_result
class(SplittingStepCoefficientsMem), intent(in) :: self
integer(C_INT) :: fresult 
type(SwigClassWrapper) :: farg1 

farg1 = self%swigdata
fresult = swigc_SplittingStepCoefficientsMem_partitions_get(farg1)
swig_result = fresult
end function

subroutine swigf_SplittingStepCoefficientsMem_order_set(self, order)
use, intrinsic :: ISO_C_BINDING
class(SplittingStepCoefficientsMem), intent(in) :: self
integer(C_INT), intent(in) :: order
type(SwigClassWrapper) :: farg1 
integer(C_INT) :: farg2 

farg1 = self%swigdata
farg2 = order
call swigc_SplittingStepCoefficientsMem_order_set(farg1, farg2)
end subroutine

function swigf_SplittingStepCoefficientsMem_order_get(self) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
integer(C_INT) :: swig_result
class(SplittingStepCoefficientsMem), intent(in) :: self
integer(C_INT) :: fresult 
type(SwigClassWrapper) :: farg1 

farg1 = self%swigdata
fresult = swigc_SplittingStepCoefficientsMem_order_get(farg1)
swig_result = fresult
end function

function swigf_create_SplittingStepCoefficientsMem() &
result(self)
use, intrinsic :: ISO_C_BINDING
type(SplittingStepCoefficientsMem) :: self
type(SwigClassWrapper) :: fresult 

fresult = swigc_new_SplittingStepCoefficientsMem()
self%swigdata = fresult
end function

subroutine swigf_release_SplittingStepCoefficientsMem(self)
use, intrinsic :: ISO_C_BINDING
class(SplittingStepCoefficientsMem), intent(inout) :: self
type(SwigClassWrapper) :: farg1 

farg1 = self%swigdata
if (btest(farg1%cmemflags, swig_cmem_own_bit)) then
call swigc_delete_SplittingStepCoefficientsMem(farg1)
endif
farg1%cptr = C_NULL_PTR
farg1%cmemflags = 0
self%swigdata = farg1
end subroutine

subroutine swigf_SplittingStepCoefficientsMem_op_assign__(self, other)
use, intrinsic :: ISO_C_BINDING
class(SplittingStepCoefficientsMem), intent(inout) :: self
type(SplittingStepCoefficientsMem), intent(in) :: other
type(SwigClassWrapper) :: farg1 
type(SwigClassWrapper) :: farg2 

farg1 = self%swigdata
farg2 = other%swigdata
call swigc_SplittingStepCoefficientsMem_op_assign__(farg1, farg2)
self%swigdata = farg1
end subroutine

function FSplittingStepCoefficients_Alloc(sequential_methods, stages, partitions) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
type(SplittingStepCoefficientsMem) :: swig_result
integer(C_INT), intent(in) :: sequential_methods
integer(C_INT), intent(in) :: stages
integer(C_INT), intent(in) :: partitions
type(SwigClassWrapper) :: fresult 
integer(C_INT) :: farg1 
integer(C_INT) :: farg2 
integer(C_INT) :: farg3 

farg1 = sequential_methods
farg2 = stages
farg3 = partitions
fresult = swigc_FSplittingStepCoefficients_Alloc(farg1, farg2, farg3)
swig_result%swigdata = fresult
end function

function FSplittingStepCoefficients_Create(sequential_methods, stages, partitions, order, alpha, beta) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
type(SplittingStepCoefficientsMem) :: swig_result
integer(C_INT), intent(in) :: sequential_methods
integer(C_INT), intent(in) :: stages
integer(C_INT), intent(in) :: partitions
integer(C_INT), intent(in) :: order
real(C_DOUBLE), dimension(*), target, intent(inout) :: alpha
real(C_DOUBLE), dimension(*), target, intent(inout) :: beta
type(SwigClassWrapper) :: fresult 
integer(C_INT) :: farg1 
integer(C_INT) :: farg2 
integer(C_INT) :: farg3 
integer(C_INT) :: farg4 
type(C_PTR) :: farg5 
type(C_PTR) :: farg6 

farg1 = sequential_methods
farg2 = stages
farg3 = partitions
farg4 = order
farg5 = c_loc(alpha(1))
farg6 = c_loc(beta(1))
fresult = swigc_FSplittingStepCoefficients_Create(farg1, farg2, farg3, farg4, farg5, farg6)
swig_result%swigdata = fresult
end function

subroutine FSplittingStepCoefficients_Destroy(coefficients)
use, intrinsic :: ISO_C_BINDING
type(C_PTR), target, intent(inout) :: coefficients
type(C_PTR) :: farg1 

farg1 = c_loc(coefficients)
call swigc_FSplittingStepCoefficients_Destroy(farg1)
end subroutine

function FSplittingStepCoefficients_Copy(coefficients) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
type(SplittingStepCoefficientsMem) :: swig_result
class(SplittingStepCoefficientsMem), intent(in) :: coefficients
type(SwigClassWrapper) :: fresult 
type(SwigClassWrapper) :: farg1 

farg1 = coefficients%swigdata
fresult = swigc_FSplittingStepCoefficients_Copy(farg1)
swig_result%swigdata = fresult
end function

subroutine FSplittingStepCoefficients_Write(coefficients, outfile)
use, intrinsic :: ISO_C_BINDING
class(SplittingStepCoefficientsMem), intent(in) :: coefficients
type(C_PTR) :: outfile
type(SwigClassWrapper) :: farg1 
type(C_PTR) :: farg2 

farg1 = coefficients%swigdata
farg2 = outfile
call swigc_FSplittingStepCoefficients_Write(farg1, farg2)
end subroutine

function FSplittingStepCoefficients_LoadCoefficients(id) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
type(SplittingStepCoefficientsMem) :: swig_result
integer(ARKODE_SplittingCoefficientsID), intent(in) :: id
type(SwigClassWrapper) :: fresult 
integer(C_INT) :: farg1 

farg1 = id
fresult = swigc_FSplittingStepCoefficients_LoadCoefficients(farg1)
swig_result%swigdata = fresult
end function


subroutine SWIG_string_to_chararray(string, chars, wrap)
  use, intrinsic :: ISO_C_BINDING
  character(kind=C_CHAR, len=*), intent(IN) :: string
  character(kind=C_CHAR), dimension(:), target, allocatable, intent(OUT) :: chars
  type(SwigArrayWrapper), intent(OUT) :: wrap
  integer :: i

  allocate(character(kind=C_CHAR) :: chars(len(string) + 1))
  do i=1,len(string)
    chars(i) = string(i:i)
  end do
  i = len(string) + 1
  chars(i) = C_NULL_CHAR ! C string compatibility
  wrap%data = c_loc(chars)
  wrap%size = len(string)
end subroutine

function FSplittingStepCoefficients_LoadCoefficientsByName(name) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
type(SplittingStepCoefficientsMem) :: swig_result
character(kind=C_CHAR, len=*), target :: name
character(kind=C_CHAR), dimension(:), allocatable, target :: farg1_chars
type(SwigClassWrapper) :: fresult 
type(SwigArrayWrapper) :: farg1 

call SWIG_string_to_chararray(name, farg1_chars, farg1)
fresult = swigc_FSplittingStepCoefficients_LoadCoefficientsByName(farg1)
swig_result%swigdata = fresult
end function


subroutine SWIG_chararray_to_string(wrap, string)
  use, intrinsic :: ISO_C_BINDING
  type(SwigArrayWrapper), intent(IN) :: wrap
  character(kind=C_CHAR, len=:), allocatable, intent(OUT) :: string
  character(kind=C_CHAR), dimension(:), pointer :: chars
  integer(kind=C_SIZE_T) :: i
  call c_f_pointer(wrap%data, chars, [wrap%size])
  allocate(character(kind=C_CHAR, len=wrap%size) :: string)
  do i=1, wrap%size
    string(i:i) = chars(i)
  end do
end subroutine

function FSplittingStepCoefficients_IDToName(id) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
character(kind=C_CHAR, len=:), allocatable :: swig_result
integer(ARKODE_SplittingCoefficientsID), intent(in) :: id
type(SwigArrayWrapper) :: fresult 
integer(C_INT) :: farg1 

farg1 = id
fresult = swigc_FSplittingStepCoefficients_IDToName(farg1)
call SWIG_chararray_to_string(fresult, swig_result)
if (.false.) call SWIG_free(fresult%data)
end function

function FSplittingStepCoefficients_LieTrotter(partitions) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
type(SplittingStepCoefficientsMem) :: swig_result
integer(C_INT), intent(in) :: partitions
type(SwigClassWrapper) :: fresult 
integer(C_INT) :: farg1 

farg1 = partitions
fresult = swigc_FSplittingStepCoefficients_LieTrotter(farg1)
swig_result%swigdata = fresult
end function

function FSplittingStepCoefficients_Strang(partitions) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
type(SplittingStepCoefficientsMem) :: swig_result
integer(C_INT), intent(in) :: partitions
type(SwigClassWrapper) :: fresult 
integer(C_INT) :: farg1 

farg1 = partitions
fresult = swigc_FSplittingStepCoefficients_Strang(farg1)
swig_result%swigdata = fresult
end function

function FSplittingStepCoefficients_Parallel(partitions) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
type(SplittingStepCoefficientsMem) :: swig_result
integer(C_INT), intent(in) :: partitions
type(SwigClassWrapper) :: fresult 
integer(C_INT) :: farg1 

farg1 = partitions
fresult = swigc_FSplittingStepCoefficients_Parallel(farg1)
swig_result%swigdata = fresult
end function

function FSplittingStepCoefficients_SymmetricParallel(partitions) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
type(SplittingStepCoefficientsMem) :: swig_result
integer(C_INT), intent(in) :: partitions
type(SwigClassWrapper) :: fresult 
integer(C_INT) :: farg1 

farg1 = partitions
fresult = swigc_FSplittingStepCoefficients_SymmetricParallel(farg1)
swig_result%swigdata = fresult
end function

function FSplittingStepCoefficients_ThirdOrderSuzuki(partitions) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
type(SplittingStepCoefficientsMem) :: swig_result
integer(C_INT), intent(in) :: partitions
type(SwigClassWrapper) :: fresult 
integer(C_INT) :: farg1 

farg1 = partitions
fresult = swigc_FSplittingStepCoefficients_ThirdOrderSuzuki(farg1)
swig_result%swigdata = fresult
end function

function FSplittingStepCoefficients_TripleJump(partitions, order) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
type(SplittingStepCoefficientsMem) :: swig_result
integer(C_INT), intent(in) :: partitions
integer(C_INT), intent(in) :: order
type(SwigClassWrapper) :: fresult 
integer(C_INT) :: farg1 
integer(C_INT) :: farg2 

farg1 = partitions
farg2 = order
fresult = swigc_FSplittingStepCoefficients_TripleJump(farg1, farg2)
swig_result%swigdata = fresult
end function

function FSplittingStepCoefficients_SuzukiFractal(partitions, order) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
type(SplittingStepCoefficientsMem) :: swig_result
integer(C_INT), intent(in) :: partitions
integer(C_INT), intent(in) :: order
type(SwigClassWrapper) :: fresult 
integer(C_INT) :: farg1 
integer(C_INT) :: farg2 

farg1 = partitions
farg2 = order
fresult = swigc_FSplittingStepCoefficients_SuzukiFractal(farg1, farg2)
swig_result%swigdata = fresult
end function

function FSplittingStepCreate(steppers, partitions, t0, y0, sunctx) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
type(C_PTR) :: swig_result
type(C_PTR), target, intent(inout) :: steppers
integer(C_INT), intent(in) :: partitions
real(C_DOUBLE), intent(in) :: t0
type(N_Vector), target, intent(inout) :: y0
type(C_PTR) :: sunctx
type(C_PTR) :: fresult 
type(C_PTR) :: farg1 
integer(C_INT) :: farg2 
real(C_DOUBLE) :: farg3 
type(C_PTR) :: farg4 
type(C_PTR) :: farg5 

farg1 = c_loc(steppers)
farg2 = partitions
farg3 = t0
farg4 = c_loc(y0)
farg5 = sunctx
fresult = swigc_FSplittingStepCreate(farg1, farg2, farg3, farg4, farg5)
swig_result = fresult
end function

function FSplittingStepReInit(arkode_mem, steppers, partitions, t0, y0) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
integer(C_INT) :: swig_result
type(C_PTR) :: arkode_mem
type(C_PTR), target, intent(inout) :: steppers
integer(C_INT), intent(in) :: partitions
real(C_DOUBLE), intent(in) :: t0
type(N_Vector), target, intent(inout) :: y0
integer(C_INT) :: fresult 
type(C_PTR) :: farg1 
type(C_PTR) :: farg2 
integer(C_INT) :: farg3 
real(C_DOUBLE) :: farg4 
type(C_PTR) :: farg5 

farg1 = arkode_mem
farg2 = c_loc(steppers)
farg3 = partitions
farg4 = t0
farg5 = c_loc(y0)
fresult = swigc_FSplittingStepReInit(farg1, farg2, farg3, farg4, farg5)
swig_result = fresult
end function

function FSplittingStepSetCoefficients(arkode_mem, coefficients) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
integer(C_INT) :: swig_result
type(C_PTR) :: arkode_mem
class(SplittingStepCoefficientsMem), intent(in) :: coefficients
integer(C_INT) :: fresult 
type(C_PTR) :: farg1 
type(SwigClassWrapper) :: farg2 

farg1 = arkode_mem
farg2 = coefficients%swigdata
fresult = swigc_FSplittingStepSetCoefficients(farg1, farg2)
swig_result = fresult
end function

function FSplittingStepGetNumEvolves(arkode_mem, partition, evolves) &
result(swig_result)
use, intrinsic :: ISO_C_BINDING
integer(C_INT) :: swig_result
type(C_PTR) :: arkode_mem
integer(C_INT), intent(in) :: partition
integer(C_LONG), dimension(*), target, intent(inout) :: evolves
integer(C_INT) :: fresult 
type(C_PTR) :: farg1 
integer(C_INT) :: farg2 
type(C_PTR) :: farg3 

farg1 = arkode_mem
farg2 = partition
farg3 = c_loc(evolves(1))
fresult = swigc_FSplittingStepGetNumEvolves(farg1, farg2, farg3)
swig_result = fresult
end function


end module
