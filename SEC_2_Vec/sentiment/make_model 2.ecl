IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM ML_Core;
IMPORT TextVectors as tv;
IMPORT LogisticRegression AS LR;
trainrec := sent_model.trainrec;

#OPTION('outputLimit',500);
//path := '~ncf::edgarfilings::raw::tech10qs_medium';
//path_w_labels := '~ncf::edgarfilings::raw::tech_10qs_medium_withlabels';
//path := '~ncf::edgarfilings::raw::labels_allsecs_medium';
//path := '~ncf::edgarfilings::raw::fixedlabels_allsecs_medium';
//path := '~ncf::edgarfilings::raw::fixedlabels_allsecs_big';
//path := '~ncf::edgarfilings::raw::labels_allsecs_all';
path := '~ncf::edgarfilings::raw::plainlabel_allsecs_all';

tsents := secvec_input_lbl(path,TRUE,'s&p');
//dat := sent_model.trndata_wlbl(path,TRUE,'s&p');
dat := sent_model.trndata_wlbl(tsents);

dat_vn_all := dat[1];
van_0 := dat_vn_all(label='0');
van_1 := dat_vn_all(label='1');
dat_vn := van_0[1..100]+van_1[1..600];
holdout_vn := van_0[101..]+van_1[601..800];

dat_tf_all := dat[2];
tf_0 := dat_tf_all(label='0');
tf_1 := dat_tf_all(label='1');
dat_tf := tf_0[1..100]+tf_1[1..600];
holdout_tf := tf_0[101..]+tf_1[601..800];

big_dat_tf := tf_0(id%2=0)+tf_1(id%2=0);
big_dat_vn := van_0(id%2=0)+van_1(id%2=0);

big_holdout_tf := tf_0(id%2=1)+tf_1(id%2=1);
big_holdout_vn := van_0(id%2=1)+van_1(id%2=1);

ff_vn := sent_model.getFields(dat_vn);
ff_vnhold := sent_model.getFields(holdout_vn);
ff_tf := sent_model.getFields(dat_tf);
ff_tfhold := sent_model.getFields(holdout_tf);

ff_vn_big := sent_model.getFields(big_dat_vn);
ff_vnhold_big := sent_model.getFields(big_holdout_vn);
ff_tf_big := sent_model.getFields(big_dat_tf);
ff_tfhold_big := sent_model.getFields(big_holdout_tf);

X_vn_ho := ff_vnhold.NUMF;
X_vn := ff_vn.NUMF;
X_tf_ho := ff_tfhold.NUMF;
X_tf := ff_tf.NUMF;

X_vn_ho_big := ff_vnhold_big.NUMF;
X_vn_big := ff_vn_big.NUMF;
X_tf_ho_big := ff_tfhold_big.NUMF;
X_tf_big := ff_tf_big.NUMF;

Y_vn_ho := ff_vnhold.DSCF;
Y_tf_ho := ff_tfhold.DSCF;
Y_tf := ff_tf.DSCF;
Y_vn := ff_vn.DSCF;

Y_vn_ho_big := ff_vnhold_big.DSCF;
Y_tf_ho_big := ff_tfhold_big.DSCF;
Y_tf_big := ff_tf_big.DSCF;
Y_vn_big := ff_vn_big.DSCF;

blr_mod_tf := sent_model.train_binlogreg(dat_tf,100);
blr_mod_vn := sent_model.train_binlogreg(dat_vn,100);

blr_mod_vn_bighalf := sent_model.train_binlogreg(big_dat_vn);
blr_mod_tf_bighalf := sent_model.train_binlogreg(big_dat_tf);

plainblr := LR.BinomialLogisticRegression();

//blr_rprt_vn := plainblr.Report(blr_mod_vn,X_vn,Y_vn);
//blr_rprt_tf := plainblr.Report(blr_mod_tf,X_tf,Y_tf)

allpreds_tf := plainblr.Classify(blr_mod_tf,X_tf);
allpreds_vn := plainblr.Classify(blr_mod_vn,X_vn);
allconfu_vn := LR.Confusion(Y_vn,allpreds_vn);
allconfu_tf := LR.Confusion(Y_tf,allpreds_tf);

allpreds_tf_big := plainblr.Classify(blr_mod_tf_bighalf,X_tf_big);
allpreds_vn_big := plainblr.Classify(blr_mod_vn_bighalf,X_vn_big);
allconfu_vn_big := LR.Confusion(Y_vn_big,allpreds_vn_big);
allconfu_tf_big := LR.Confusion(Y_tf_big,allpreds_tf_big);

holdpreds_vn := plainblr.Classify(blr_mod_vn,X_vn_ho);
holdpreds_tf := plainblr.Classify(blr_mod_tf,X_tf_ho);
holdconfu_vn := LR.Confusion(Y_vn_ho,holdpreds_vn);
holdconfu_tf := LR.Confusion(Y_tf_ho,holdpreds_tf);

holdpreds_vn_big := plainblr.Classify(blr_mod_vn_bighalf,X_vn_ho_big);
holdpreds_tf_big := plainblr.Classify(blr_mod_tf_bighalf,X_tf_ho_big);
holdconfu_vn_big := LR.Confusion(Y_vn_ho_big,holdpreds_vn_big);
holdconfu_tf_big := LR.Confusion(Y_tf_ho_big,holdpreds_tf_big);

hldvnconfu := LR.BinomialConfusion(holdconfu_vn);
blrvnconfu := LR.BinomialConfusion(allconfu_vn);
hldtfconfu := LR.BinomialConfusion(holdconfu_tf);
blrtfconfu := LR.BinomialConfusion(allconfu_tf);

hldvnconfu_big := LR.BinomialConfusion(holdconfu_vn_big);
blrvnconfu_big := LR.BinomialConfusion(allconfu_vn_big);
hldtfconfu_big := LR.BinomialConfusion(holdconfu_tf_big);
blrtfconfu_big := LR.BinomialConfusion(allconfu_tf_big);

OUTPUT(dat_vn_all,ALL,NAMED('sandp_vanilla_all'));
OUTPUT(dat_tf_all,ALL,NAMED('sandp_tfidf_all'));
//OUTPUT(dat_vn,ALL,NAMED('sandp_vn_vecs'));
//OUTPUT(dat_tf,ALL,NAMED('sandp_tf_vecs'));
OUTPUT(X_vn[..200],NAMED('sandp_vn_numeric'));
OUTPUT(X_tf[..200],NAMED('sandp_tf_numeric'));
OUTPUT(Y_vn,ALL,NAMED('sandp_vn_labels'));
OUTPUT(Y_tf,ALL,NAMED('sandp_tf_labels'));
OUTPUT(allpreds_vn,ALL,NAMED('sandp_vn_preds'));
OUTPUT(allpreds_tf,ALL,NAMED('sandp_tf_preds'));
OUTPUT(blrvnconfu,ALL,NAMED('blr_vn_confu'));
OUTPUT(blrtfconfu,ALL,NAMED('blr_tf_confu'));
OUTPUT(hldvnconfu,ALL,NAMED('holdout_vanilla_confusion'));
OUTPUT(hldtfconfu,ALL,NAMED('holdout_tfidf_confusion'));
OUTPUT(blrvnconfu_big,NAMED('blr_vn_confu_bighalf'));
OUTPUT(blrtfconfu_big,NAMED('blr_tf_confu_bighalf'));
OUTPUT(hldvnconfu_big,NAMED('holdout_vanilla_confusion_bighalf'));
OUTPUT(hldtfconfu_big,NAMED('holdout_tfidf_confusion_bighalf'));