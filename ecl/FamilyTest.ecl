/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2022 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $ AS V;
IMPORT $.^ AS GLMmod;
IMPORT ML_Core.Types AS Types;  
IMPORT ML_Core AS Core;
IMPORT GLMmod.Types AS GLM_Types;
IMPORT GLMmod.Family;
IMPORT GLMmod.Datasets;

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

EXPORT FamilyTest(Family.FamilyInterface family, DATASET($.Test_Values) v_result) := FUNCTION
			
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

		Compare_Rec check(GLM_Types.pval_Model_Coef p, $.Test_Values t, UNSIGNED s):=TRANSFORM
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
											 
											 
		Compare_Rec check_aic(GLM_Types.Deviance_Record d, $.Test_Values t):=TRANSFORM
			SELF.test := 'AIC';
			SELF.src := t.src;
			SELF.std_value := t.aic;
			SELF.tst_value := d.aic;
			SELF.equal := ABS(SELF.tst_value-SELF.std_value) <= max_diff;
		END;

		aic_check := JOIN(modl_dev, v_result, LEFT.wi=RIGHT.wi,
											check_aic(LEFT, RIGHT), LOOKUP);
		all_checks := coef_check + se_check + pval_check + aic_check;
		errors := all_checks(NOT equal);
		
		RETURN(errors);
END;
