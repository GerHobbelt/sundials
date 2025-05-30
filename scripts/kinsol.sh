#!/bin/bash
# ------------------------------------------------------------------------------
# Programmer(s): Radu Serban, David J. Gardner, Cody J. Balos @ LLNL
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
# Script to add KINSOL files to a SUNDIALS tar-file.
# ------------------------------------------------------------------------------

set -e
set -o pipefail

tarfile=$1
distrobase=$2
doc=$3

# all remaining inputs are for tar command
shift 3
tar=$*

echo "   --- Add kinsol module to $tarfile"

if [ $doc = "T" ]; then
    $tar $tarfile $distrobase/doc/kinsol/kin_guide.pdf
    $tar $tarfile $distrobase/doc/kinsol/kin_examples.pdf
fi
$tar $tarfile $distrobase/doc/kinsol/guide/Makefile
$tar $tarfile $distrobase/doc/kinsol/guide/source

echo "   --- Add kinsol include files to $tarfile"
$tar $tarfile $distrobase/include/kinsol

echo "   --- Add kinsol source files to $tarfile"
$tar $tarfile $distrobase/src/kinsol

echo "   --- Add kinsol examples to $tarfile"
$tar $tarfile $distrobase/examples/kinsol

echo "   --- Add kinsol unit tests to $tarfile"
$tar $tarfile $distrobase/test/unit_tests/kinsol
