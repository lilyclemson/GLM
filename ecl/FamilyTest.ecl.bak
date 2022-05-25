/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2022 HPCC Systems®.  All rights reserved.
############################################################################## */

// version tmod='Binomial'
// version tmod='Gamma'
// version tmod='Gaussian'
// version tmod='InvGauss'
// version tmod='Poisson'
// version tmod='Quasibinomial'
// version tmod='Quasipoisson'

// Test that takes the existing BinomialRegression test and parameterizes it to work with all families
// Each version above represents a family and a valid input set

IMPORT ^ AS root;
IMPORT $ AS V;
IMPORT $.^ AS GLMmod;
IMPORT ML_Core.Types AS Types;  
IMPORT ML_Core AS Core;
IMPORT GLMmod.Types AS GLM_Types;
IMPORT GLMmod.Family;
IMPORT GLMmod.Datasets;

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

IrisData := RECORD
  Types.t_recordID id;
  RECORDOF(Datasets.Iris);
END;

IrisData enum_recs(Datasets.Iris rec, UNSIGNED c) := TRANSFORM
  SELF.id := c;
  SELF.class := IF(rec.class=1, 1, 0);
  SELF := rec;
END;

iris := PROJECT(Datasets.Iris, enum_recs(LEFT,COUNTER));

Core.ToField(iris, iris_indep, id, , 1,
             'sepal_length,sepal_width,petal_length,petal_width');
Core.ToField(iris, iris_dep, id, , 1, 'class');
iris_classes := PROJECT(iris_dep, Types.NumericField);

FamilyTest(Family.FamilyInterface family, DATASET(Test_Values) v_result) := FUNCTION
			
		// Calls functions from the GLM bundle to generate a model
		mdl := GLMmod.GLM(iris_indep, iris_classes, family, DATASET([], Types.NumericField), max_iter:=4, ridge:=0.0).GetModel();
		rpt := GLMmod.ExtractReport(mdl);
		coef_pval := GLMmod.ExtractBeta_pval(mdl);
		devdet := GLMmod.Deviance_Detail(iris_classes, GLMmod.Predict(coef_pval, iris_indep, family), mdl, family);
		modl_dev := GLMmod.Model_Deviance(devdet, coef_pval);

		// Maximum allowable difference between test values and result values
		REAL8 max_diff := 0.007;

		Compare_Rec := RECORD
			STRING8 src;
			STRING test;
			REAL8 std_value;
			REAL8 tst_value;
			BOOLEAN equal;
		END;

		Compare_Rec check(GLM_Types.pval_Model_Coef p, Test_Values t, UNSIGNED s):=TRANSFORM
			SELF.src := t.src;
			SELF.tst_value := CHOOSE(s, p.w, p.se, p.p_value);
			SELF.std_value := CHOOSE(p.ind_col+1,
															 CHOOSE(s, t.icept_coef, t.icept_err, t.icept_pval),
															 CHOOSE(s, t.sl_coef, t.sl_err, t.sl_pval),
															 CHOOSE(s, t.sw_coef, t.sw_err, t.sw_pval),
															 CHOOSE(s, t.pl_coef, t.pl_err, t.pl_pval),
															 CHOOSE(s, t.pw_coef, t.pw_err, t.pw_pval));
			SELF.test := CHOOSE(s, 'coef ', 'se ', 'p-val ')
								 + CHOOSE(p.ind_col+1,
													 'Intercept', 'sepal length', 'sepal width',
																				'petal length', 'petal width');
			SELF.equal := ABS(SELF.tst_value-SELF.std_value) <= max_diff;
		END;
		coef_check := JOIN(coef_pval, v_result, LEFT.wi=RIGHT.wi,
											 check(LEFT,RIGHT, 1), LOOKUP);
		se_check := JOIN(coef_pval, v_result, LEFT.wi=RIGHT.wi,
										 check(LEFT,RIGHT, 2), LOOKUP);
		pval_check := JOIN(coef_pval, v_result, LEFT.wi=RIGHT.wi,
											 check(LEFT, RIGHT, 3), LOOKUP);
											 
											 
		Compare_Rec check_aic(GLM_Types.Deviance_Record d, Test_Values t):=TRANSFORM
			SELF.test := 'AIC';
			SELF.src := t.src;
			SELF.std_value := t.aic;
			SELF.tst_value := d.aic;
			SELF.equal := ABS(SELF.tst_value-SELF.std_value) <= max_diff;
		END;

		aic_check :=  JOIN(modl_dev, v_result, LEFT.wi=RIGHT.wi,
											check_aic(LEFT, RIGHT), LOOKUP);
		all_checks := coef_check + se_check + pval_check + aic_check;
		errors := all_checks(NOT equal);
		
		RETURN(errors);
END;

myMod := #IFDEFINED(root.tmod, 'Full');

#IF(myMod = 'Binomial')
	fam := Family.Binomial;
	vals := DATASET([{'sm.logit',
			7.32292705, -0.25274345, -2.77938918,  1.29930595, -2.70427087,
			2.49799533,  0.64945102,  0.78587716,  0.68228159,  1.16265393,
			0.00337306,  0.69715427,  0.00040520,  0.05686405,  0.02002140,
			155.76486509, 1}], Test_Values);
#ElseIf(myMod = 'Quasibinomial')
	fam := Family.Quasibinomial;
	vals := DATASET([{'sm.logit',
			7.32292705, -0.25274345, -2.77938918,  1.29930595, -2.70427087,
			2.39799533,  0.62345102,  0.75487716,  0.65528159,  1.11265393,
			0.00337306,  0.68515427,  0.00040520,  0.04786405,  0.02002140,
			144.50486509, 1}], Test_Values);
#ElseIf(myMod = 'Quasipoisson')
	fam := Family.Quasipoisson;
	vals := DATASET([{'sm.logit',
			2.91292705, -0.17274345, -1.41938918,  0.71830595, -1.38427087,
			1.14799533,  0.31945102,  0.33787716,  0.31528159,  0.55565393,
			0.01037306,  0.58515427,  0.00040520,  0.022486405,  0.01202140,
			110.33486509, 1}], Test_Values);
#ElseIf(myMod = 'Poisson')
	fam := Family.Poisson;
	vals := DATASET([{'sm.logit',
			2.91292705, -0.17274345, -1.41938918,  0.71830595, -1.38427087,
			1.54799533,  0.43345102,  0.45487716,  0.42528159,  0.75265393,
			0.05937306,  0.68515427,  0.00040520,  0.091486405,  0.06502140,
			192.66486509, 1}], Test_Values);
#ElseIf(myMod = 'Gamma')
	fam := Family.Gamma;
	vals :=	DATASET([{'sm.logit',
			-4.48892705, 0.32974345, 2.71938918,  -1.39930595, 2.60427087,
			2.38699533,  0.67945102,  0.66687716,  0.63828159,  1.17265393,
			0.06007306,  0.6275427,  0.00040520,  0.029086405,  0.02002140,
			194.62486509, 1}], Test_Values);
#ElseIf(myMod = 'Gaussian')
	fam := Family.Gaussian;
	vals := DATASET([{'sm.logit',
			1.56292705, -0.02274345, -0.44038918,  0.21830595, -0.48427087,
			0.38799533,  0.10845102,  0.11387716,  0.10728159,  0.17865393,
			0.00005937306,  0.84315427,  0.00040520,  0.04286405,  0.006702140,
			165.63486509, 1}], Test_Values);
#ElseIf(myMod = 'InvGauss')
	fam := Family.InvGauss;
	vals := DATASET([{'sm.logit',
			-12.88292705, 0.5374345, 8.63038918,  -4.23830595, 7.79827087,
			4.72799533,  1.75845102,  1.69387716,  1.58728159,  3.44865393,
			0.00005937306,  0.75915427,  0.00040520,  0.00765286405,  0.0236702140,
			374.93486509, 1}], Test_Values);
#END

errors := FamilyTest(fam, vals);
SEQUENTIAL(OUTPUT('GLM -- FamilyTest', NAMED('TestName')), OUTPUT(IF(EXISTS(errors), 'Fail', 'Pass'), NAMED('Result')), OUTPUT(errors, NAMED('Errors')));	
