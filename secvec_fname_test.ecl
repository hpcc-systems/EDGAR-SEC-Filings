IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;

path := '~ncf::edgarfilings::raw::labels_allsecs_all';

OUTPUT(secvec_input_lbl(path,TRUE,'plain'));
OUTPUT(secvec_input_lbl(path,TRUE,'s&p'));