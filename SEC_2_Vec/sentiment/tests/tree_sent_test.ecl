IMPORT ML_Core;
IMPORT ML_Core.Analysis.Classification AS ml_ac;
IMPORT LogisticRegression as LR;
IMPORT LearningTrees AS LT;
IMPORT * FROM LT;
IMPORT SEC_2_Vec;
IMPORT SEC_2_Vec.sentiment.sent_model as sm;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT * from SEC_2_Vec.sentiment;

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
    REAL8 doc_acc100;
    REAL8 doc_acc50;
    REAL8 doc_acc25;
    REAL8 doc_acc10;
    REAL8 doc_pod_100;
    REAL8 doc_pode_100;
    REAL8 doc_hpod_100;
    REAL8 doc_hpode_100;
    REAL8 doc_pod_50;
    REAL8 doc_pode_50;
    REAL8 doc_hpod_50;
    REAL8 doc_hpode_50;
    REAL8 doc_pod_25;
    REAL8 doc_pode_25;
    REAL8 doc_hpod_25;
    REAL8 doc_hpode_25;
    REAL8 doc_pod_10;
    REAL8 doc_pode_10;
    REAL8 doc_hpod_10;
    REAL8 doc_hpode_10;
END;

CF1 := LT.ClassificationForest();
CF2 := LT.ClassificationForest(100,0,50);
CF3 := LT.ClassificationForest(100,0,25);
CF4 := LT.ClassificationForest(100,0,10);

secs := sectors.sectorlist;

make_cfs(INTEGER n) := FUNCTION

    sect := secs[n];
    datn_all := vansents(get_tick(fname) IN SET(sectors.sectorticker(sector=sect),ticker));
    datsplit := traintestsplit(datn_all,'filename',2);
    // datn := datn_all(id%2=0);
    // dath := datn_all(id%2=1);
    datn := datsplit.trn;
    dath := datsplit.tst;

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

    pod1 := ml_ac.Accuracy(preds1,Y);
    pod1h := ml_ac.Accuracy(preds1h,Yh);
    pod2 := ml_ac.Accuracy(preds2,Y);
    pod2h := ml_ac.Accuracy(preds2h,Yh);
    pod3 := ml_ac.Accuracy(preds3,Y);
    pod3h := ml_ac.Accuracy(preds3h,Yh);
    pod4 := ml_ac.Accuracy(preds4,Y);
    pod4h := ml_ac.Accuracy(preds4h,Yh);

    dsent1 := docsent(preds1,datn);
    dsent1h := docsent(preds1h,dath);
    dsent2 := docsent(preds2,datn);
    dsent2h := docsent(preds2h,dath);
    dsent3 := docsent(preds3,datn);
    dsent3h := docsent(preds3h,dath);
    dsent4 := docsent(preds4,datn);
    dsent4h := docsent(preds4h,dath);

    docX1 := dsent1.docavg;
    docX1h := dsent1h.docavg;
    docX2 := dsent2.docavg;
    docX2h := dsent2h.docavg;
    docX3 := dsent3.docavg;
    docX3h := dsent3h.docavg;
    docX4 := dsent4.docavg;
    docX4h := dsent4h.docavg;

    docY1 := dsent1.labtru;
    docY1h := dsent1h.labtru;
    docY2 := dsent2.labtru;
    docY2h := dsent2h.labtru;
    docY3 := dsent3.labtru;
    docY3h := dsent3h.labtru;
    docY4 := dsent4.labtru;
    docY4h := dsent4h.labtru;

    // mod1doc1 := CF1.GetModel(docX1,docY1);
    // mod2doc2 := CF2.GetModel(docX2,docY2);
    // mod3doc3 := CF3.GetModel(docX3,docY3);
    // mod4doc4 := CF4.GetModel(docX4,docY4);

    // dpreds1 := CF1.Classify(mod1doc1,docX1);
    // dpreds1h := CF1.Classify(mod1doc1,docX1h);
    // dpreds2 := CF2.Classify(mod2doc2,docX2);
    // dpreds2h := CF2.Classify(mod2doc2,docX2h);
    // dpreds3 := CF3.Classify(mod3doc3,docX3);
    // dpreds3h := CF3.Classify(mod3doc3,docX3h);
    // dpreds4 := CF4.Classify(mod4doc4,docX4);
    // dpreds4h := CF4.Classify(mod4doc4,docX4h);

    //doing the document prediction with BLR after
    //doing sentence prediction using CF
    IMPORT LogisticRegression as LR;
    plainblr := LR.BinomialLogisticRegression();

    doc1mod := plainblr.GetModel(docX1,docY1);
    doc2mod := plainblr.GetModel(docX2,docY2);
    doc3mod := plainblr.GetModel(docX3,docY3);
    doc4mod := plainblr.GetModel(docX4,docY4);

    dpreds1 := plainblr.Classify(doc1mod,docX1);
    dpreds1h := plainblr.Classify(doc1mod,docX1h);
    dpreds2 := plainblr.Classify(doc2mod,docX2);
    dpreds2h := plainblr.Classify(doc2mod,docX2h);
    dpreds3 := plainblr.Classify(doc3mod,docX3);
    dpreds3h := plainblr.Classify(doc3mod,docX3h);
    dpreds4 := plainblr.Classify(doc4mod,docX4);
    dpreds4h := plainblr.Classify(doc4mod,docX4h);


    docpod1 := ML_Core.Analysis.Classification.Accuracy(dpreds1,docY1);
    docpod1h := ML_Core.Analysis.Classification.Accuracy(dpreds1h,docY1h);
    docpod2 := ML_Core.Analysis.Classification.Accuracy(dpreds2,docY2);
    docpod2h := ML_Core.Analysis.Classification.Accuracy(dpreds2h,docY2h);
    docpod3 := ML_Core.Analysis.Classification.Accuracy(dpreds3,docY3);
    docpod3h := ML_Core.Analysis.Classification.Accuracy(dpreds3h,docY3h);
    docpod4 := ML_Core.Analysis.Classification.Accuracy(dpreds4,docY4);
    docpod4h := ML_Core.Analysis.Classification.Accuracy(dpreds4h,docY4h);

    result := MODULE
        EXPORT sec := sect;
        EXPORT acc1 := pod1[1].raw_accuracy;
        EXPORT acc2 := pod2[1].raw_accuracy;
        EXPORT acc3 := pod3[1].raw_accuracy;
        EXPORT acc4 := pod4[1].raw_accuracy;
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
        EXPORT dacc1 := docpod1[1].raw_accuracy;
        EXPORT dacc2 := docpod2[1].raw_accuracy;
        EXPORT dacc3 := docpod3[1].raw_accuracy;
        EXPORT dacc4 := docpod4[1].raw_accuracy;
        EXPORT dp1 := docpod1[1].pod;
        EXPORT dpe1 := docpod1[1].pode;
        EXPORT dhp1 := docpod1h[1].pod;
        EXPORT dhpe1 := docpod1h[1].pode;
        EXPORT dp2 := docpod2[1].pod;
        EXPORT dpe2 := docpod2[1].pode;
        EXPORT dhp2 := docpod2h[1].pod;
        EXPORT dhpe2 := docpod2h[1].pode;
        EXPORT dp3 := docpod3[1].pod;
        EXPORT dpe3 := docpod3[1].pode;
        EXPORT dhp3 := docpod3h[1].pod;
        EXPORT dhpe3 := docpod3h[1].pode;
        EXPORT dp4 := docpod4[1].pod;
        EXPORT dpe4 := docpod4[1].pode;
        EXPORT dhp4 := docpod4h[1].pod;
        EXPORT dhpe4 := docpod4h[1].pode;
    END;

    RETURN DATASET([{result.sec,result.acc1,result.acc2,result.acc3,result.acc4,
                    result.p1,result.pe1,result.hp1,result.hpe1,
                    result.p2,result.pe2,result.hp2,result.hpe2,
                    result.p3,result.pe3,result.hp3,result.hpe3,
                    result.p4,result.pe4,result.hp4,result.hpe4,
                    result.dacc1,result.dacc2,result.dacc3,result.dacc4,
                    result.dp1,result.dpe1,result.dhp1,result.dhpe1,
                    result.dp2,result.dpe2,result.dhp2,result.dhpe2,
                    result.dp3,result.dpe3,result.dhp3,result.dhpe3,
                    result.dp4,result.dpe4,result.dhp4,result.dhpe4}],outrec);

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