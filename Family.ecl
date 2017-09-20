IMPORT ML_Core AS Core;

PI := 3.141592653589793238462643;
LargeValue := 999999999999999;
SmallValue := 0.0000000000001;

EXPORT Family := MODULE
  // Define interface
  EXPORT FamilyInterface := INTERFACE
    EXPORT REAL8 link(REAL8 m);
    EXPORT REAL8 mu  (REAL8 v);
    EXPORT REAL8 deta(REAL8 m);
    EXPORT REAL8 var (REAL8 m);
    EXPORT REAL8 init(REAL8 y, REAL8 w);
    EXPORT REAL8 ll  (REAL8 y, REAL8 m, REAL8 disp);
    EXPORT VARSTRING mu_LUCI;
    EXPORT BOOLEAN dispersion;

    EXPORT SET OF UNSIGNED4 cardinality;
    EXPORT SET OF REAL8 values;
    EXPORT BOOLEAN isInteger;
  END;

  EXPORT Binomial := MODULE(FamilyInterface)
    EXPORT REAL8 link(REAL8 m) := LN(m / (1.0 - m));
    EXPORT REAL8 mu  (REAL8 v) := 1.0 / (1.0 + EXP(-v));
    EXPORT REAL8 deta(REAL8 m) := 1.0 / (m * (1.0 - m));
    EXPORT REAL8 var (REAL8 m) := m * (1.0 - m);
    EXPORT REAL8 init(REAL8 y, REAL8 w = 1.0) := (w * y + 0.5) / (w + 1.0);
    EXPORT REAL8 ll  (REAL8 y, REAL8 m, REAL8 disp = 0.0) := y * LN(m) + (1.0 - y) * LN(1.0 - m);
    EXPORT VARSTRING mu_LUCI := '1.0 / (1.0 + EXP(-Raw_point))';
    EXPORT BOOLEAN dispersion := FALSE;

    EXPORT SET OF UNSIGNED4 cardinality := [2, LargeValue];
    EXPORT SET OF REAL8 values := [0.0, 1.0];
    EXPORT BOOLEAN isInteger := FALSE;
  END;

  EXPORT Quasibinomial := MODULE(FamilyInterface)
    EXPORT REAL8 link(REAL8 m) := LN(m / (1.0 - m));
    EXPORT REAL8 mu  (REAL8 v) := 1.0 / (1.0 + EXP(-v));
    EXPORT REAL8 deta(REAL8 m) := 1.0 / (m * (1.0 - m));
    EXPORT REAL8 var (REAL8 m) := m * (1.0 - m);
    EXPORT REAL8 init(REAL8 y, REAL8 w = 1.0) := (w * y + 0.5) / (w + 1.0);
    EXPORT REAL8 ll  (REAL8 y, REAL8 m, REAL8 disp) := disp * (y * LN(m) + (1.0 - y) * LN(1.0 - m));
    EXPORT VARSTRING mu_LUCI := '1.0 / (1.0 + EXP(-Raw_point))';
    EXPORT BOOLEAN dispersion := TRUE;

    EXPORT SET OF UNSIGNED4 cardinality := [2, LargeValue];
    EXPORT SET OF REAL8 values := [0.0, 1.0];
    EXPORT BOOLEAN isInteger := FALSE;
  END;

  EXPORT Poisson := MODULE(FamilyInterface)
    EXPORT REAL8 link(REAL8 m) := LN(m);
    EXPORT REAL8 mu  (REAL8 v) := EXP(v);
    EXPORT REAL8 deta(REAL8 m) := 1.0 / m;
    EXPORT REAL8 var (REAL8 m) := m;
    EXPORT REAL8 init(REAL8 y, REAL8 w = 1.0) := y + 0.1;
    EXPORT REAL8 ll  (REAL8 y, REAL8 m, REAL8 disp = 0.0) := y * LN(m) - m - LN(Core.Math.gamma(y + 1.0));
    EXPORT VARSTRING mu_LUCI := 'EXP(Raw_point)';
    EXPORT BOOLEAN dispersion := FALSE;

    EXPORT SET OF UNSIGNED4 cardinality := [2, LargeValue];
    EXPORT SET OF REAL8 values := [0, LargeValue];
    EXPORT BOOLEAN isInteger := TRUE;
  END;

  EXPORT Quasipoisson := MODULE(FamilyInterface)
    EXPORT REAL8 link(REAL8 m) := LN(m);
    EXPORT REAL8 mu  (REAL8 v) := EXP(v);
    EXPORT REAL8 deta(REAL8 m) := 1.0 / m;
    EXPORT REAL8 var (REAL8 m) := m;
    EXPORT REAL8 init(REAL8 y, REAL8 w = 1.0) := y + 0.1;
    EXPORT REAL8 ll  (REAL8 y, REAL8 m, REAL8 disp) := disp * (y * LN(m) - m - LN(Core.Math.gamma(y + 1.0)));
    EXPORT VARSTRING mu_LUCI := 'EXP(Raw_point)';
    EXPORT BOOLEAN dispersion := TRUE;

    EXPORT SET OF UNSIGNED4 cardinality := [2, LargeValue];
    EXPORT SET OF REAL8 values := [0, LargeValue];
    EXPORT BOOLEAN isInteger := FALSE;
  END;

  EXPORT Gamma := MODULE(FamilyInterface)
    EXPORT REAL8 link(REAL8 m) := 1.0 / m;
    EXPORT REAL8 mu  (REAL8 v) := 1.0 / v;
    EXPORT REAL8 deta(REAL8 m) := - 1.0 / POWER(m, 2);
    EXPORT REAL8 var (REAL8 m) := POWER(m, 2);
    EXPORT REAL8 init(REAL8 y, REAL8 w = 1.0) := y;
    EXPORT REAL8 ll  (REAL8 y, REAL8 m, REAL8 disp) := -1 / disp * (y / m + LN(m) + (disp - 1) * LN(y) + LN(disp) + disp * LN(Core.Math.gamma(1 / disp)));
    EXPORT VARSTRING mu_LUCI := '1.0 / Raw_point';
    EXPORT BOOLEAN dispersion := TRUE;

    EXPORT SET OF UNSIGNED4 cardinality := [2, LargeValue];
    EXPORT SET OF REAL8 values := [SmallValue, LargeValue];
    EXPORT BOOLEAN isInteger := FALSE;
  END;

  EXPORT Gaussian := MODULE(FamilyInterface)
    EXPORT REAL8 link(REAL8 m) := m;
    EXPORT REAL8 mu  (REAL8 v) := v;
    EXPORT REAL8 deta(REAL8 m) := 1.0;
    EXPORT REAL8 var (REAL8 m) := 1.0;
    EXPORT REAL8 init(REAL8 y, REAL8 w = 1.0) := y;
    EXPORT REAL8 ll  (REAL8 y, REAL8 m, REAL8 disp) := - LN(2 * PI * disp) / 2 - 1/(2 * disp) * POWER(y - m, 2);
    EXPORT VARSTRING mu_LUCI := 'Raw_point';
    EXPORT BOOLEAN dispersion := TRUE;

    EXPORT SET OF UNSIGNED4 cardinality := [2, LargeValue];
    EXPORT SET OF REAL8 values := [-LargeValue, LargeValue];
    EXPORT BOOLEAN isInteger := FALSE;
  END;

  EXPORT InvGauss := MODULE(FamilyInterface)
    EXPORT REAL8 link(REAL8 m) := 1.0 / POWER(m, 2);
    EXPORT REAL8 mu  (REAL8 v) := 1.0 / SQRT(v);
    EXPORT REAL8 deta(REAL8 m) := - 2.0 / POWER(m, 3);
    EXPORT REAL8 var (REAL8 m) := POWER(m, 3);
    EXPORT REAL8 init(REAL8 y, REAL8 w = 1.0) := y;
    EXPORT REAL8 ll  (REAL8 y, REAL8 m, REAL8 disp) := - 1 / 2 * (POWER(y - m, 2) / (y * m * disp) + LN(disp * POWER(y, 3)) + LN(2 * PI));
    EXPORT VARSTRING mu_LUCI := '1.0 / SQRT(Raw_point)';
    EXPORT BOOLEAN dispersion := TRUE;

    EXPORT SET OF UNSIGNED4 cardinality := [2, LargeValue];
    EXPORT SET OF REAL8 values := [SmallValue, LargeValue];
    EXPORT BOOLEAN isInteger := FALSE;
  END;
END;