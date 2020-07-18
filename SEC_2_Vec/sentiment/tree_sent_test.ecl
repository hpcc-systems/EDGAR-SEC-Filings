IMPORT ML_Core;
IMPORT ML_Core.Analysis.Classification AS ml_ac;
IMPORT LogisticRegression as LR;
IMPORT LearningTrees AS LT;
IMPORT * FROM LT;
IMPORT SEC_2_Vec;
IMPORT SEC_2_Vec.sentiment.sent_model as sm;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT sectors from SEC_2_Vec.sentiment.tests;

#OPTION('outputLimit',500);

vansents := DATASET(WORKUNIT('W20200713-063347','sandp_label_vanilla_data'),sm.trainrec);

outrec := RECORD
    STRING sector;
    REAL8 acc100;
    REAL8 acc50;
    REAL8 acc25;
    REAL8 acc10;
    REAL8 pod_100;
    REAL8 pode_100;
    REAL8 hpod_100;
    REAL8 hpode_100;
    REAL8 pod_50;
    REAL8 pode_50;
    REAL8 hpod_50;
    REAL8 hpode_50;
    REAL8 pod_25;
    REAL8 pode_25;
    REAL8 hpod_25;
    REAL8 hpode_25;
    REAL8 pod_10;
    REAL8 pode_10;
    REAL8 hpod_10;
    REAL8 hpode_10;
END;

CF1 := LT.ClassificationForest();
CF2 := LT.ClassificationForest(100,0,50);
CF3 := LT.ClassificationForest(100,0,25);
CF4 := LT.ClassificationForest(100,0,10);

secs := sectors.sectorlist;

make_cfs(INTEGER n) := FUNCTION

    sect := secs[n];
    datn_all := vansents(get_tick(fname) IN SET(sectors.sectorticker(sector=sect),ticker));
    datn := datn_all(id%2=0);
    dath := datn_all(id%2=1);

    ff := sm.getFields(datn);

    X := ff.NUMF;
    Y := ff.DSCF;

    ff_h := sm.getFields(dath);

    Xh := ff_h.NUMF;
    Yh := ff_h.DSCF;

    mod1 := CF1.GetModel(X,Y);
    mod2 := CF2.GetModel(X,Y);
    mod3 := CF3.GetModel(X,Y);
    mod4 := CF4.GetModel(X,Y);

    preds1 := CF1.Classify(mod1,X);
    preds1h := CF1.Classify(mod1,Xh);
    preds2 := CF2.Classify(mod2,X);
    preds2h := CF2.Classify(mod2,Xh);
    preds3 := CF3.Classify(mod3,X);
    preds3h := CF3.Classify(mod3,Xh);
    preds4 := CF4.Classify(mod4,X);
    preds4h := CF4.Classify(mod4,Xh);

    precon1 := LR.Confusion(Y,preds1);
    con1 := LR.BinomialConfusion(precon1);
    precon2 := LR.Confusion(Y,preds2);
    con2 := LR.BinomialConfusion(precon2);
    precon3 := LR.Confusion(Y,preds3);
    con3 := LR.BinomialConfusion(precon3);
    precon4 := LR.Confusion(Y,preds4);
    con4 := LR.BinomialConfusion(precon4);

    pod1 := ml_ac.Accuracy(preds1,Y);
    pod1h := ml_ac.Accuracy(preds1h,Yh);
    pod2 := ml_ac.Accuracy(preds2,Y);
    pod2h := ml_ac.Accuracy(preds2h,Yh);
    pod3 := ml_ac.Accuracy(preds3,Y);
    pod3h := ml_ac.Accuracy(preds3h,Yh);
    pod4 := ml_ac.Accuracy(preds4,Y);
    pod4h := ml_ac.Accuracy(preds4h,Yh);

    result := MODULE
        EXPORT sec := sect;
        EXPORT acc1 := con1[1].accuracy;
        EXPORT acc2 := con2[1].accuracy;
        EXPORT acc3 := con3[1].accuracy;
        EXPORT acc4 := con4[1].accuracy;
        EXPORT p1 := pod1[1].pod;
        EXPORT pe1 := pod1[1].pode;
        EXPORT hp1 := pod1h[1].pod;
        EXPORT hpe1 := pod1h[1].pode;
        EXPORT p2 := pod2[1].pod;
        EXPORT pe2 := pod2[1].pode;
        EXPORT hp2 := pod2h[1].pod;
        EXPORT hpe2 := pod2h[1].pode;
        EXPORT p3 := pod3[1].pod;
        EXPORT pe3 := pod3[1].pode;
        EXPORT hp3 := pod3h[1].pod;
        EXPORT hpe3 := pod3h[1].pode;
        EXPORT p4 := pod4[1].pod;
        EXPORT pe4 := pod4[1].pode;
        EXPORT hp4 := pod4h[1].pod;
        EXPORT hpe4 := pod4h[1].pode;
    END;

    RETURN DATASET([{result.sec,result.acc1,result.acc2,result.acc3,result.acc4,
                    result.p1,result.pe1,result.hp1,result.hpe1,
                    result.p2,result.pe2,result.hp2,result.hpe2,
                    result.p3,result.pe3,result.hp3,result.hpe3,
                    result.p4,result.pe4,result.hp4,result.hpe4}],outrec);

END;

// rslt := make_cfs(1);
// OUTPUT(rslt.sec);
// OUTPUT(rslt.acc1);
// OUTPUT(rslt.acc2);
// OUTPUT(rslt.acc3);
// OUTPUT(rslt.acc4);
// OUTPUT(rslt.p1);
// OUTPUT(rslt.p2);
// OUTPUT(rslt.p3);
// OUTPUT(rslt.p4);
//OUTPUT(svc.Report(svm_mod,X,Y),NAMED('SVC_Report_All'));
//OUTPUT(svm_con,NAMED('svm_model_confusion'));

//OUTPUT(DATASET(COUNT(secs),TRANSFORM({STRING sector},SELF.sector := secs[COUNTER])));

// prec := DATASET(ML_Core.Types.Classification_Accuracy);


// outrec out_T(INTEGER C) := TRANSFORM
//     rslt := make_cfs(C);
//     SELF.sector := rslt.sec;
//     SELF.acc100 := rslt.acc1;
//     SELF.acc50 := rslt.acc2;
//     SELF.acc25 := rslt.acc3;
//     SELF.acc10 := rslt.acc4;
//     SELF.pod_100 := rslt.p1[1].pod;
//     SELF.pode_100 := rslt.p1[1].pode;
//     SELF.pod_50 := rslt.p2[1].pod;
//     SELF.pode_50 := rslt.p2[1].pode;
//     SELF.pod_25 := rslt.p3[1].pod;
//     SELF.pode_25 := rslt.p3[1].pode;
//     SELF.pod_10 := rslt.p4[1].pod;
//     SELF.pode_10 := rslt.p4[1].pode;
// END;

//out := DATASET(COUNT(secs),out_T(COUNTER));

//OUTPUT(out);

rslt1 := make_cfs(1);
rslt2 := make_cfs(2);
rslt3 := make_cfs(3);
rslt4 := make_cfs(4);
rslt5 := make_cfs(5);
rslt6 := make_cfs(6);
rslt7 := make_cfs(7);
rslt8 := make_cfs(8);
rslt9 := make_cfs(9);
rslt10 := make_cfs(10);
rslt11 := make_cfs(11);
rslt12 := make_cfs(12);
rslt13 := make_cfs(13);

rs := DATASET([rslt1[1],
        rslt2[1],
        rslt3[1],
        rslt4[1],
        rslt5[1],
        rslt6[1],
        rslt7[1],
        rslt8[1],
        rslt9[1],
        rslt10[1],
        rslt11[1],
        rslt12[1],
        rslt13[1]],outrec);


// outrec make_outrow(INTEGER C) := TRANSFORM
//     SELF := rs[C][1];
    // SELF.sector := rslt[1].sector;
    // SELF.acc100 := rslt[1].acc100;
    // SELF.acc50 := rslt[1].acc50;
    // SELF.acc25 := rslt[1].acc;
    // SELF.acc10 := rslt[1].acc4;
    // SELF.pod_100 := rslt[1].p1;
    // SELF.pode_100 := rslt[1].pe1;
    // SELF.pod_50 := rslt[1].p2;
    // SELF.pode_50 := rslt[1].pe2;
    // SELF.pod_25 := rslt[1].p3;
    // SELF.pode_25 := rslt[1].pe3;
    // SELF.pod_10 := rslt[1].p4;
    // SELF.pode_10 := rslt[1].pe4;
//END;

//out := DATASET(COUNT(rs),make_outrow(COUNTER));

// OUTPUT(rslt1);
// OUTPUT(rslt2);
// OUTPUT(rslt3);
// OUTPUT(rslt4);
// OUTPUT(rslt5);
// OUTPUT(rslt6);
// OUTPUT(rslt7);
// OUTPUT(rslt8);
// OUTPUT(rslt9);
// OUTPUT(rslt10);
// OUTPUT(rslt11);
// OUTPUT(rslt12);
// OUTPUT(rslt13);

OUTPUT(rs);