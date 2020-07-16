IMPORT STD;
IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
IMPORT LogisticRegression as LR;
IMPORT ML_Core;

trainrec := sentiment.sent_model.trainrec;

fnamevecs_vn := DATASET(WORKUNIT('W20200701-073359','vanilla'),trainrec);
fnamevecs_tf := DATASET(WORKUNIT('W20200701-073359','tfidf'),trainrec);

get_ticker(STRING f) := FUNCTION
    parts := STD.Str.SplitWords(f,'_',FALSE);
    tick := parts[1];
    RETURN tick;
END;

tickrec := RECORD
    STRING ticker := get_ticker(fnamevecs_tf.fname);
END;

tickds := TABLE(fnamevecs_tf,tickrec);

fnamesds := DEDUP(tickds,tickds.ticker);
fnames := SET(fnamesds,fnamesds.ticker);

tick1ds := fnamevecs_tf(get_ticker(fname)=fnames[1]);
tick5ds := fnamevecs_tf(get_ticker(fname)=fnames[5]);
dedupnamesin5 := DEDUP(tick5ds,tick5ds.fname);
namesin5 := SET(dedupnamesin5,dedupnamesin5.fname);
tick10ds := fnamevecs_tf(get_ticker(fname)=fnames[10]);
dedupnamesin10 := DEDUP(tick10ds,tick10ds.fname);
namesin10 := SET(dedupnamesin10,dedupnamesin10.fname);

doc_5_1 := tick5ds(fname=namesin5[1]);
doc_5_2 := tick5ds(fname=namesin5[2]);

doc_10_1 := tick10ds(fname=namesin10[1]);
doc_10_2 := tick10ds(fname=namesin10[2]);

sl := similarity.simlabs(fnamevecs_tf);

sal := sl.sim_and_labels;

ML_Core.ToField(sal,X,sid,'similarity');

lblintrec := RECORD
    UNSIGNED rowid;
    INTEGER4 label;
END;

lblintrec lblintT(RECORDOF(sal) s) := TRANSFORM
    SELF.rowid := s.sid;
    SELF.label := (INTEGER4)s.label;
END;

output_tofield := PROJECT(sal,lblintT(LEFT));

Y := PROJECT(output_tofield,TRANSFORM(ML_Core.Types.DiscreteField,SELF.wi := 1,SELF.value := LEFT.label,SELF.id := LEFT.rowid,SELF.number := 1));

blr := LR.BinomialLogisticRegression();
mod := blr.getModel(X,Y);

con := LR.BinomialConfusion(blr.Report(mod,X,Y));

OUTPUT(fnames);
OUTPUT(tick1ds);
OUTPUT(tick5ds);
OUTPUT(tick10ds);
OUTPUT(similarity.docsim(doc_5_1,doc_5_2));
OUTPUT(similarity.docsim(doc_10_1,doc_10_2));
OUTPUT(similarity.docsim(doc_5_1,doc_10_1));
OUTPUT(similarity.docsim(doc_5_2,doc_10_2));
OUTPUT(similarity.docsim(tick1ds,doc_5_1));
OUTPUT(similarity.docsim(tick1ds,doc_10_1));
OUTPUT(sl.fname_bytick);
OUTPUT(sl.simsentcomp);
OUTPUT(mod);
OUTPUT(con);