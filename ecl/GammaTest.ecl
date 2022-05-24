/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2022 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $;
IMPORT $.^ AS GLMmod;
IMPORT GLMmod.Family;

errors := $.FamilyTest(Family.Quasibinomial, 
												DATASET([{'sm.logit',
												7.32292705, -0.25274345, -2.77938918,  1.29930595, -2.70427087,
												2.39799533,  0.62345102,  0.75487716,  0.65528159,  1.11265393,
												0.00337306,  0.68515427,  0.00040520,  0.04786405,  0.02002140,
												144.50486509, 1}], $.Test_Values));

SEQUENTIAL(OUTPUT('Test -- Quasibinomial', NAMED('TestName')), OUTPUT(IF(EXISTS(errors), 'Fail', 'Pass'), NAMED('Result')), OUTPUT(errors, NAMED('Errors')));
										