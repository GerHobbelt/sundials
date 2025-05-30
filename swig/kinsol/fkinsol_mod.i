// ---------------------------------------------------------------
// Programmer: Cody J. Balos @ LLNL
// ---------------------------------------------------------------
// SUNDIALS Copyright Start
// Copyright (c) 2002-2025, Lawrence Livermore National Security
// and Southern Methodist University.
// All rights reserved.
//
// See the top-level LICENSE and NOTICE files for details.
//
// SPDX-License-Identifier: BSD-3-Clause
// SUNDIALS Copyright End
// ---------------------------------------------------------------
// Swig interface file
// ---------------------------------------------------------------

%module fkinsol_mod

%include "../sundials/fsundials.i"

%{
#include "kinsol/kinsol.h"
#include "kinsol/kinsol_bbdpre.h"
#include "kinsol/kinsol_ls.h"
%}

%import "../sundials/fsundials_core_mod.i"

// Process definitions from these files
%include "kinsol/kinsol.h"
%include "kinsol/kinsol_bbdpre.h"
%include "kinsol/kinsol_ls.h"

