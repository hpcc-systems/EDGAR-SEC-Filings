IMPORT ML_Core;
IMPORT ML_Core.Types;
IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;

#OPTION('outputLimit',100);

//sp := DATASET(WORKUNIT('W20200713-063347','sandp_label_vanilla_data'),sent_model.trainrec);
sp := DATASET(WORKUNIT('W20200712-072825','plain_label_vanilla_data'),sent_model.trainrec);

IMPORT LogisticRegression as LR;

plainblr := LR.BinomialLogisticRegression();

ff := sent_model.getFields(sp);

X := ff.NUMF;
Y := ff.DSCF;

mod := plainblr.GetModel(X,Y);
preds := plainblr.Classify(mod,X);
acc := ML_Core.Analysis.Classification.Accuracy(preds,Y);


dsent := docsent(preds,sp);

docX := dsent.docavg;
docY := dsent.labtru;

docmod := plainblr.GetModel(docX,docY);
docpreds := plainblr.Classify(docmod,docX);
docacc := ML_Core.Analysis.Classification.Accuracy(docpreds,docY);

OUTPUT(acc);
OUTPUT(docacc);