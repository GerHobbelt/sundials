# ------------------------------------------------------------------------------
# Programmer(s): David J. Gardner @ LLNL
# ------------------------------------------------------------------------------
# SUNDIALS Copyright Start
# Copyright (c) 2002-2025, Lawrence Livermore National Security
# and Southern Methodist University.
# All rights reserved.
#
# See the top-level LICENSE and NOTICE files for details.
#
# SPDX-License-Identifier: BSD-3-Clause
# SUNDIALS Copyright End
# ------------------------------------------------------------------------------
# test/unit_tests/sunnonlinsol level CMakeLists.txt for SUNDIALS
# ------------------------------------------------------------------------------

if(ENABLE_CALIPER AND SUNDIALS_BUILD_WITH_PROFILING)
  include_directories(${caliper_INCLUDE_DIR})
  set(EXE_EXTRA_LINK_LIBS ${EXE_EXTRA_LINK_LIBS} caliper)
endif()

# Always add the Newton and fixed point examples
add_subdirectory(newton)
add_subdirectory(fixedpoint)

if(BUILD_SUNNONLINSOL_PETSCSNES)
  add_subdirectory(petsc)
endif()
