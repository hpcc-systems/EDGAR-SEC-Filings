IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT LogisticRegression as LR;

#OPTION('outputLimit',2000);

path10k := '~ncf::edgarfilings::raw::labels_allsecs_all_10k';
path10q := '~ncf::edgarfilings::raw::plainlabel_allsecs_all';

pllblsents := SORT(secvec_input_lbl(path10q,path10k,TRUE,'plain'),fname);
splblsents := SORT(secvec_input_lbl(path10q,path10k,TRUE,'s&p'),fname);

//OUTPUT(pllblsents[..1000]);
//OUTPUT(splblsents[..1000]);

plainlblvn := sent_model.trn10q10klbl_van(pllblsents);
sandplblvn := sent_model.trn10q10klbl_van(splblsents);

//plain := sent_model.getFields(plainlblvn);
//sandp := sent_model.getFields(sandplblvn);

//Xplvn := plain.NUMF;
//Xspvn := sandp.NUMF;
//Yplvn := plain.DSCF;
//Yspvn := sandp.DSCF;

//plainblr := LR.BinomialLogisticRegression();

//modpl := plainblr.getModel(Xplvn,Yplvn);
//modsp := plainblr.getModel(Xspvn,Yspvn);

// predpl := plainblr.Classify(modpl,Xplvn);
// predsp := plainblr.Classify(modsp,Xspvn);

//conpl := LR.BinomialConfusion(plainblr.Report(modpl,Xplvn,Yplvn));
//consp := LR.BinomialConfusion(plainblr.Report(modsp,Xspvn,Yspvn));

//OUTPUT(conpl);
//OUTPUT(consp);
OUTPUT(sandplblvn,ALL,NAMED('sandp_label_vanilla_data'));
OUTPUT(plainlblvn,ALL,NAMED('plain_label_vanilla_data'));
//OUTPUT(COUNT(pllblsents));