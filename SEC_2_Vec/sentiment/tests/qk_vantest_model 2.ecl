IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
IMPORT TextVectors as tv;
IMPORT tv.Types;
IMPORT SEC_2_Vec.sentiment.sent_model;
IMPORT LogisticRegression as LR;

t_Vector := Types.t_Vector;

srec := sent_model.sveclblrec;
modrec := Types.TextMod;
trainrec := SEC_2_Vec.sentiment.sent_model.trainrec;

// sents := DATASET(WORKUNIT('W20200710-035637','Result 1'),srec);
// model := DATASET(WORKUNIT('W20200710-035637','Result 2'),modrec);

traindat_van := DATASET(WORKUNIT('W20200710-075950','Result 2'),trainrec);

mod := sent_model.train_binlogreg(traindat_van);

plainblr := LR.BinomialLogisticRegression();

fields := sent_model.getFields(traindat_van);
X := fields.NUMF;
Y := fields.DSCF;

con := LR.BinomialConfusion(plainblr.Report(mod,X,Y));

OUTPUT(con);