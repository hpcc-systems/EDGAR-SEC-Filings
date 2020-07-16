IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;

#OPTION('outputLimit',1000);

path10k := '~ncf::edgarfilings::raw::labels_allsecs_all_10k';
path10q := '~ncf::edgarfilings::raw::plainlabel_allsecs_all';

pllblsents := SORT(secvec_input_lbl(path10q,path10k,TRUE,'plain'),fname);

plainlblvn := sent_model.trn10q10klbl_van(pllblsents);

OUTPUT(plainlblvn,ALL,NAMED('plain_label_vanilla_data'));