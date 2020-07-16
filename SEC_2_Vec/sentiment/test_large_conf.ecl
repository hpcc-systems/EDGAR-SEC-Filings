IMPORT ML_Core;
IMPORT ML_Core.Types AS Types;
class_result := Types.Classify_Result;
discrt_field := Types.DiscreteField;

// readin1rec := RECORD
//     UNSIGNED wi;
//     UNSIGNED id;
//     UNSIGNED number;
//     INTEGER4 value;
// END;

//Y_true_raw := DATASET(WORKUNIT('W20200624-230908','sandp_vn_labels'),readin1rec);
Y_true_raw := DATASET(WORKUNIT('W20200624-230908','sandp_vn_labels'),discrt_field);

// readin2rec := RECORD
//     UNSIGNED wi;
//     UNSIGNED id;
//     UNSIGNED number;
//     INTEGER4 value;
//     REAL8 conf;
// END;

//Y_pred_raw := DATASET(WORKUNIT('W20200624-230908','sandp_vn_preds'),readin2rec);
Y_pred_raw := DATASET(WORKUNIT('W20200624-230908','sandp_vn_preds'),class_result);

ytrec := RECORD
    Y_true_raw.id;
    Y_true_raw.value;
END;

Y_true := TABLE(Y_true_raw,ytrec);

yprec := RECORD
    Y_pred_raw.id;
    Y_pred_raw.value;
END;

Y_pred := TABLE(Y_pred_raw,yprec);

OUTPUT(Y_true_raw);
OUTPUT(Y_pred_raw);
OUTPUT(Y_true);
OUTPUT(Y_pred);

combo := JOIN(Y_true,Y_pred,LEFT.id = RIGHT.id,TRANSFORM({INTEGER id,INTEGER ytrue,INTEGER ypred,INTEGER correct},SELF.id := LEFT.id,SELF.ytrue := LEFT.value,SELF.ypred := RIGHT.value,SELF.correct := IF(SELF.ytrue=SELF.ypred,1,0)));
numcor := SUM(SET(combo,combo.correct));
dat0s := combo(ytrue=0);
dat1s := combo(ytrue=1);
num0s := COUNT(dat0s);
num1s := COUNT(dat1s);
numcor0 := COUNT(dat0s(correct=1));
numcor1 := COUNT(dat1s(correct=1));
numwrn0 := num0s-numcor0;
numwrn1 := num1s-numcor1;
OUTPUT(combo);
OUTPUT(COUNT(combo),NAMED('numberofobservations'));
OUTPUT(numcor,NAMED('numbercorrect'));
OUTPUT((numcor0/num0s),NAMED('percentcorrect0'));
OUTPUT((numcor1/num1s),NAMED('percentcorrect1'));
OUTPUT((numcor/COUNT(combo)),NAMED('accuracy'));
OUTPUT(.5*((numcor0/num0s)+(numcor1/num1s)),NAMED('adjustedacc'));