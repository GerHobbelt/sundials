# ---------------------------------------------------------------
# Programmer(s): Daniel R. Reynolds @ SMU
# ---------------------------------------------------------------
# SUNDIALS Copyright Start
# Copyright (c) 2002-2025, Lawrence Livermore National Security
# and Southern Methodist University.
# All rights reserved.
#
# See the top-level LICENSE and NOTICE files for details.
#
# SPDX-License-Identifier: BSD-3-Clause
# SUNDIALS Copyright End
# ---------------------------------------------------------------
# CMakeLists.txt file for the ARKode F2003 custom module examples
# ---------------------------------------------------------------

# Example lists are tuples "name\;type" where the type is 'develop' for examples
# excluded from 'make test' in releases

if(SUNDIALS_INDEX_SIZE MATCHES "64")

  # Examples using SUNDIALS linear solvers
  set(FARKODE_examples "ark_brusselator1D_f2003\;develop"
                       "ark_analytic_complex_f2003\;develop")

  set(FARKODE_tests
      "test_fnvector_complex_mod\;develop" "test_fnvector_fortran_mod\;develop"
      "test_fsunmatrix_fortran_mod\;develop"
      "test_fsunlinsol_fortran_mod\;develop")

endif()

# note the order matters when auto-generating the installed Makefile
set(FARKODEsources fnvector_complex_mod.f90 fnvector_fortran_mod.f90
                   fsunmatrix_fortran_mod.f90 fsunlinsol_fortran_mod.f90)

# Specify libraries to link against
set(ARKODE_LIB sundials_arkode)
set(FARKODE_LIB sundials_farkode_mod)

# Set-up linker flags and link libraries
set(SUNDIALS_LIBS ${FARKODE_LIB} ${ARKODE_LIB} ${EXE_EXTRA_LINK_LIBS})

# Add the build and install targets for each example
foreach(example_tuple ${FARKODE_examples})

  # parse the example tuple
  list(GET example_tuple 0 example)
  list(GET example_tuple 1 example_type)

  # build fortran modules into a unique directory to avoid naming collisions
  set(CMAKE_Fortran_MODULE_DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${example}.dir)

  # example source files
  sundials_add_executable(${example} ${example}.f90 ${FARKODEsources})

  set_target_properties(${example} PROPERTIES FOLDER "Examples")

  # add example to regression tests
  sundials_add_test(
    ${example} ${example}
    ANSWER_DIR ${CMAKE_CURRENT_SOURCE_DIR}
    ANSWER_FILE ${example}.out
    EXAMPLE_TYPE ${example_type})

  # libraries to link against
  target_link_libraries(${example} ${SUNDIALS_LIBS})

  # install example source and out files
  if(EXAMPLES_INSTALL)
    install(FILES ${example}.f90 ${example}.out ${FARKODEsources}
            DESTINATION ${EXAMPLES_INSTALL_PATH}/arkode/F2003_custom)
  endif()

endforeach(example_tuple ${FARKODE_examples})

# Add the build and install targets for regression test
foreach(example_tuple ${FARKODE_tests})

  # parse the example tuple
  list(GET example_tuple 0 example)
  list(GET example_tuple 1 example_type)

  # Install fortran modules to a unique directory to avoid naming collisions
  set(CMAKE_Fortran_MODULE_DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${example}.dir)

  # example source files
  sundials_add_executable(${example} ${example}.f90 ${FARKODEsources})

  set_target_properties(${example} PROPERTIES FOLDER "Examples")

  # add example to regression tests
  sundials_add_test(
    ${example} ${example}
    TEST_ARGS ""
    EXAMPLE_TYPE ${example_type}
    NODIFF)

  # libraries to link against
  target_link_libraries(${example} ${SUNDIALS_LIBS})

  # install example source and out files
  if(EXAMPLES_INSTALL)
    install(FILES ${example}.f90 ${FARKODEsources}
            DESTINATION ${EXAMPLES_INSTALL_PATH}/arkode/F2003_custom)
  endif()

endforeach(example_tuple ${FARKODE_tests})

# create Makefile and CMakeLists.txt for examples
if(EXAMPLES_INSTALL)

  # Install the extra files
  foreach(extrafile ${ARKODE_extras})
    install(FILES ${extrafile}
            DESTINATION ${EXAMPLES_INSTALL_PATH}/arkode/F2003_custom)
  endforeach()

  # Prepare substitution variables for Makefile and/or CMakeLists templates
  set(SOLVER "ARKODE")
  set(SOLVER_LIB "sundials_arkode")
  set(SOLVER_FLIB "sundials_farkode_mod")

  examples2string(FARKODE_examples EXAMPLES)
  examples2string(FARKODE_tests TESTFILES)
  set(EXAMPLES "${EXAMPLES} ${TESTFILES}")

  # shared sources with file extensions for generated CMakeLists.txt
  examples2string(FARKODEsources EXAMPLES_DEPENDENCIES)

  # Regardless of the platform we're on, we will generate and install
  # CMakeLists.txt file for building the examples. This file  can then be used
  # as a template for the user's own programs.

  # generate CMakelists.txt in the binary directory
  configure_file(
    ${PROJECT_SOURCE_DIR}/examples/templates/cmakelists_serial_F2003_ex.in
    ${PROJECT_BINARY_DIR}/examples/arkode/F2003_custom/CMakeLists.txt @ONLY)

  # install CMakelists.txt
  install(
    FILES ${PROJECT_BINARY_DIR}/examples/arkode/F2003_custom/CMakeLists.txt
    DESTINATION ${EXAMPLES_INSTALL_PATH}/arkode/F2003_custom)

  # On UNIX-type platforms, we also  generate and install a makefile for
  # building the examples. This makefile can then be used as a template for the
  # user's own programs.

  if(UNIX)
    # remove file extensions from dependencies for generated Makefile
    string(REPLACE ".f90" "" EXAMPLES_DEPENDENCIES "${EXAMPLES_DEPENDENCIES}")

    # generate Makefile and place it in the binary dir
    configure_file(
      ${PROJECT_SOURCE_DIR}/examples/templates/makefile_serial_F2003_ex.in
      ${PROJECT_BINARY_DIR}/examples/arkode/F2003_custom/Makefile_ex @ONLY)
    # install the configured Makefile_ex as Makefile
    install(
      FILES ${PROJECT_BINARY_DIR}/examples/arkode/F2003_custom/Makefile_ex
      DESTINATION ${EXAMPLES_INSTALL_PATH}/arkode/F2003_custom
      RENAME Makefile)
  endif()

  # add test_install target
  sundials_add_test_install(arkode F2003_custom)

endif()
