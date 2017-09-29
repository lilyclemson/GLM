IMPORT $ AS GLMMod;
IMPORT GLMMod.Constants;
IMPORT GLMMod.IRLS;
IMPORT GLMMod.Family;
IMPORT ML_Core.Interfaces;
IMPORT ML_Core.Types AS Types;

//Aliases
NumericField := Types.NumericField;
Layout_Model := Types.Layout_Model;

/**
 * GLM regression using iteratively re-weighted least squares.
 * @param X The observed explanatory values.
 * @param Y The observed values the model aims to fit.
 * @param fam A module defining the error distribution and link of the dependent values.
 * @param weights A set of observation weights (one per dependent value).
 * @param max_iter Maximum number of iterations to try.
 * @param epsilon The minimum change in the Beta value estimate to continue.
 * @param ridge A value to populate a diagonal matrix that is added to
 * a matrix help assure that the matrix is invertible.
 */

 EXPORT GLM(
  DATASET(NumericField) X       = DATASET([], NumericField),
  DATASET(NumericField) Y       = DATASET([], NumericField),
  Family.FamilyInterface fam    = Family.Gaussian,
  DATASET(NumericField) weights = DATASET([], NumericField),
  UNSIGNED max_iter             = 200,
  REAL8 epsilon                 = Constants.default_epsilon,
  REAL8 ridge                   = Constants.default_ridge) :=
MODULE(Interfaces.IRegression())

  /**
   * Calculate a model to fit the observation data to the observed values.
   * @return The encoded model.
   */
  EXPORT DATASET(Types.Layout_Model) GetModel :=
    IRLS.GetModel(X, Y, fam, max_iter, epsilon, ridge, weights, TRUE);

  /**
   * Predict the observations using models trained by the GetModel function.
   * @param newX Observations to be classified.
   * @param model The models, which should be produced by a corresponding GetModel function.
   * @return Predictions.
   */
   EXPORT DATASET(NumericField) Predict(
    DATASET(NumericField) newX,
    DATASET(Layout_Model) model) :=
    GLMMod.Predict(GLMMod.ExtractBeta(model), newX, fam);

END;
    