/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * run_usrp_rx_terminate.c
 *
 * Code generation for function 'run_usrp_rx_terminate'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "run_usrp_rx.h"
#include "run_usrp_rx_terminate.h"
#include "_coder_run_usrp_rx_mex.h"
#include "run_usrp_rx_data.h"

/* Function Definitions */
void run_usrp_rx_atexit(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  run_usrp_rx_free(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  emlrtDestroyArray(&eml_mx);
  emlrtDestroyArray(&b_eml_mx);
}

void run_usrp_rx_terminate(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (run_usrp_rx_terminate.c) */
