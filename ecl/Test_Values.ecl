/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2022 HPCC Systems®.  All rights reserved.
############################################################################## */

EXPORT Test_Values := RECORD
  STRING8 src;
  REAL8 icept_coef;
  REAL8 sl_coef;
  REAL8 sw_coef;
  REAL8 pl_coef;
  REAL8 pw_coef;
  REAL8 icept_err;
  REAL8 sl_err;
  REAL8 sw_err;
  REAL8 pl_err;
  REAL8 pw_err;
  REAL8 icept_pval;
  REAL8 sl_pval;
  REAL8 sw_pval;
  REAL8 pl_pval;
  REAL8 pw_pval;
  REAL8 aic;
  UNSIGNED4 wi;
END;