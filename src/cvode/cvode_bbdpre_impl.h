/*
 * -----------------------------------------------------------------
 * Programmer(s): Daniel R. Reynolds @ SMU
 *     Michael Wittman, Alan C. Hindmarsh and Radu Serban @ LLNL
 * -----------------------------------------------------------------
 * SUNDIALS Copyright Start
 * Copyright (c) 2002-2025, Lawrence Livermore National Security
 * and Southern Methodist University.
 * All rights reserved.
 *
 * See the top-level LICENSE and NOTICE files for details.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 * SUNDIALS Copyright End
 * -----------------------------------------------------------------
 * Implementation header file for the CVBBDPRE module.
 * -----------------------------------------------------------------
 */

#ifndef _CVBBDPRE_IMPL_H
#define _CVBBDPRE_IMPL_H

#include <cvode/cvode_bbdpre.h>
#include <sunlinsol/sunlinsol_band.h>
#include <sunmatrix/sunmatrix_band.h>

#ifdef __cplusplus /* wrapper to enable C++ usage */
extern "C" {
#endif

/*-----------------------------------------------------------------
  Type: CVBBDPrecData
  -----------------------------------------------------------------*/

typedef struct CVBBDPrecDataRec
{
  /* passed by user to CVBBDPrecInit and used by PrecSetup/PrecSolve */
  sunindextype mudq, mldq, mukeep, mlkeep;
  sunrealtype dqrely;
  CVLocalFn gloc;
  CVCommFn cfn;

  /* set by CVBBDPrecSetup and used by CVBBDPrecSolve */
  SUNMatrix savedJ;
  SUNMatrix savedP;
  SUNLinearSolver LS;
  N_Vector tmp1;
  N_Vector tmp2;
  N_Vector tmp3;
  N_Vector zlocal;
  N_Vector rlocal;

  /* set by CVBBDPrecInit and used by CVBBDPrecSetup */
  sunindextype n_local;

  /* available for optional output */
  long int rpwsize;
  long int ipwsize;
  long int nge;

  /* pointer to cvode_mem */
  void* cvode_mem;

}* CVBBDPrecData;

/*-----------------------------------------------------------------
  CVBBDPRE error messages
  -----------------------------------------------------------------*/

#define MSGBBD_MEM_NULL "Integrator memory is NULL."
#define MSGBBD_LMEM_NULL                                                   \
  "Linear solver memory is NULL. One of the SPILS linear solvers must be " \
  "attached."
#define MSGBBD_MEM_FAIL    "A memory request failed."
#define MSGBBD_BAD_NVECTOR "A required vector operation is not implemented."
#define MSGBBD_SUNMAT_FAIL "An error arose from a SUNBandMatrix routine."
#define MSGBBD_SUNLS_FAIL  "An error arose from a SUNBandLinearSolver routine."
#define MSGBBD_PMEM_NULL \
  "BBD peconditioner memory is NULL. CVBBDPrecInit must be called."
#define MSGBBD_FUNC_FAILED \
  "The gloc or cfn routine failed in an unrecoverable manner."

#ifdef __cplusplus
}
#endif

#endif
