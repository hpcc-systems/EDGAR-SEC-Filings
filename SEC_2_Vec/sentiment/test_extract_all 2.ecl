IMPORT EDGAR_Extract;
IMPORT * FROM EDGAR_Extract;
IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;

#OPTION('outputLimit',500);

path := '~ncf::edgarfilings::raw::plainlabel_allsecs_all';

sents_lbl := secvec_input_lbl(path,TRUE,'s&p');

OUTPUT(sents_lbl,ALL,NAMED('all_sentences_sandp'));