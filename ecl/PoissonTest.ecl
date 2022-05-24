/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2022 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $;
IMPORT $.^ AS GLMmod;
IMPORT GLMmod.Family;

errors := $.FamilyTest(Family.Poisson, 
												DATASET([{'sm.logit',
												2.91292705, -0.17274345, -1.41938918,  0.71830595, -1.38427087,
												1.54799533,  0.43345102,  0.45487716,  0.42528159,  0.75265393,
												0.05937306,  0.68515427,  0.00040520,  0.091486405,  0.06502140,
												192.66486509, 1}], $.Test_Values));

SEQUENTIAL(OUTPUT('Test -- Poisson', NAMED('TestName')), OUTPUT(IF(EXISTS(errors), 'Fail', 'Pass'), NAMED('Result')), OUTPUT(errors, NAMED('Errors')));
										