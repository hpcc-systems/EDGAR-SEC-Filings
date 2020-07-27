IMPORT ML_Core;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM SEC_2_Vec.sentiment.tests;
IMPORT * FROM Types;
IMPORT LogisticRegression as LR;

#OPTION('outputLimit',500);

pl_vn_all := DATASET(WORKUNIT('W20200726-092906','plain_vanilla'),trainrec);

pl_vn := pl_vn_all(get_tick(fname) IN sectors.ticksn(2));
// pl_tf_all := DATASET(WORKUNIT('W20200726-092906','plain_tfidf'),trainrec);

// pl_tf := pl_tf_all(get_tick(fname) IN sectors.ticksn(2));

//pl_tf_dat := traintestsplit(pl_tf,'filename');
pl_tf_dat := traintestsplit(pl_vn,'filename');

pl_tf_trn := pl_tf_dat.trn;
pl_tf_tst := pl_tf_dat.tst;

ff_trn := sent_model.getFields(pl_tf_trn);
ff_tst := sent_model.getFields(pl_tf_tst);

x := ff_trn.NUMF;
y := ff_trn.DSCF;

xh := ff_tst.NUMF;
yh := ff_tst.DSCF;

plainblr := LR.BinomialLogisticRegression();

mod := plainblr.getModel(x,y);

preds := plainblr.classify(mod,x);
predsh := plainblr.classify(mod,xh);

podh := ML_Core.Analysis.Classification.Accuracy(predsh,yh);

doc_trn := docsent(preds,pl_tf_trn);
doc_tst := docsent(predsh,pl_tf_tst);

doc_x := doc_trn.docavg;
doc_y := doc_trn.labtru;

doc_xh := doc_tst.docavg;
doc_yh := doc_tst.labtru;

docmod := plainblr.getModel(doc_x,doc_y);

docpredsh := plainblr.classify(docmod,doc_xh);

docpodh := ML_Core.Analysis.Classification.Accuracy(docpredsh,doc_yh);

OUTPUT(podh[1].pod,NAMED('test_pod'));
OUTPUT(podh[1].pode,NAMED('test_pode'));
OUTPUT(docpodh[1].pod,NAMED('doc_pod'));
OUTPUT(docpodh[1].pode,NAMED('doc_pode'));