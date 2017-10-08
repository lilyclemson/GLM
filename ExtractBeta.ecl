IMPORT $ AS GLM;
IMPORT GLM.Types AS Types;
IMPORT ML_Core.Types AS Core_Types;

// convenience aliases
id_betas := GLM.Constants.id_betas;
id_betas_coef := GLM.Constants.id_betas_coef;
id_betas_SE := GLM.Constants.id_betas_SE;
id_base := GLM.Constants.id_base;
base_ind_vars := GLM.Constants.base_ind_vars;
Model_Coef := Types.Model_Coef;
/**
 * Extract the beta values form the model dataset.
 * @param mod_ds the model dataset
 * @return a beta values as Model Coefficient records, zero as the constant
 * term.
 */
EXPORT ExtractBeta(DATASET(Core_Types.Layout_Model) mod_ds):=FUNCTION
  full := GLM.ExtractBeta_full(mod_ds);
  rslt := PROJECT(full, Model_Coef);
  RETURN rslt;
END;