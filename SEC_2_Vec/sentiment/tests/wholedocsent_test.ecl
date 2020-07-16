IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT LogisticRegression as LR;
IMPORT LearningTrees as LT;
IMPORT ML_Core;
IMPORT ML_Core.Types;
IMPORT * FROM EDGAR_Extract.Text_Tools;

classifyrec := Types.Classify_Result;
dscf := Types.DiscreteField;

trec := sentiment.sent_model.trainrec;

//plainlblvn := DATASET(WORKUNIT('W20200711-042721','plain_label_vanilla_data'),trec);
plainlblvn := DATASET(WORKUNIT('W20200711-064253','sandp_label_vanilla_data'),trec);


plain := sent_model.getFields(plainlblvn);

X := plain.NUMF;
Y := plain.DSCF;

plainblr := LR.BinomialLogisticRegression();

modpl := plainblr.getModel(X,Y);

conpl := LR.BinomialConfusion(plainblr.Report(modpl,X,Y));

preds := plainblr.Classify(modpl,X);

docsentrec := RECORD
    UNSIGNED8 id;
    STRING fname;
    REAL8 pred_avg;
    STRING label;
END;

docsentpre := RECORD
    UNSIGNED8 id;
    STRING fname;
    INTEGER4 value;
END;

docsentpre docsent_T(trec dat,classifyrec pr) := TRANSFORM
    SELF.id := pr.id;
    SELF.fname := dat.fname;
    SELF.value := pr.value;
END;

preavg := JOIN(plainlblvn,preds,LEFT.id = RIGHT.id,docsent_T(LEFT,RIGHT));

preavgsrt := SORT(preavg,fname);
preavggrp := GROUP(preavgsrt,fname);

docsentrec rollgrp_T(docsentpre l,DATASET(docsentpre) rl) := TRANSFORM
    SELF.id := 0;
    SELF.fname := l.fname;
    SELF.pred_avg := AVE(rl,rl.value);
    SELF.label := get_label(l.fname);
END;

rollupgrp := ROLLUP(preavggrp,GROUP,rollgrp_T(LEFT,ROWS(LEFT)));

docsentid := ITERATE(rollupgrp,TRANSFORM(docsentrec,SELF.id := LEFT.id+1,SELF := RIGHT));

ML_Core.ToField(docsentid,Xdocs,id,'pred_avg');
//ML_Core.ToField(docsentid,Ydocs,id,'label');

dscf make_y_T(docsentrec dsr) := TRANSFORM
    SELF.wi := 1;
    SELF.id := dsr.id;
    SELF.number := 1;
    SELF.value := (INTEGER4) dsr.label;
END;

Ydocs := PROJECT(docsentid,make_y_T(LEFT));

//plainblr := LR.BinomialLogisticRegression();
docsentblr := LR.BinomialLogisticRegression(200,.0000001);

mod := docsentblr.GetModel(Xdocs,Ydocs);
rpt := docsentblr.Report(mod,Xdocs,Ydocs);
con := LR.BinomialConfusion(rpt);

// OUTPUT(COUNT(Y));
// OUTPUT(COUNT(preds));
// OUTPUT(COUNT(plainlblvn));
OUTPUT(Xdocs);
OUTPUT(Ydocs);
OUTPUT(rpt);
OUTPUT(con);
OUTPUT(conpl);