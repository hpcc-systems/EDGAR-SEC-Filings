IMPORT ML_Core;
IMPORT ML_Core.Analysis.Classification AS ml_ac;
IMPORT LogisticRegression as LR;
IMPORT LearningTrees AS LT;
IMPORT * FROM LT;
IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
IMPORT SEC_2_Vec.sentiment.sent_model as sm;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT * from SEC_2_Vec.sentiment;
IMPORT * FROM Types;

#OPTION('outputLimit',500);

vansents := DATASET(WORKUNIT('W20200726-092906','plain_vanilla'),trainrec);
tfsents := DATASET(WORKUNIT('W20200726-092906','plain_tfidf'),trainrec);

outrec := RECORD
    STRING sector;
    REAL8 vn_pod_100;
    REAL8 vn_pode_100;
    REAL8 tf_pod_100;
    REAL8 tf_pode_100;
    REAL8 vn_pod_50;
    REAL8 vn_pode_50;
    REAL8 tf_pod_50;
    REAL8 tf_pode_50;
    REAL8 vn_pod_25;
    REAL8 vn_pode_25;
    REAL8 tf_pod_25;
    REAL8 tf_pode_25;
    REAL8 vn_pod_10;
    REAL8 vn_pode_10;
    REAL8 tf_pod_10;
    REAL8 tf_pode_10;
    REAL8 docvn_pod_100;
    REAL8 docvn_pode_100;
    REAL8 doctf_pod_100;
    REAL8 doctf_pode_100;
    REAL8 docvn_pod_50;
    REAL8 docvn_pode_50;
    REAL8 doctf_pod_50;
    REAL8 doctf_pode_50;
    REAL8 docvn_pod_25;
    REAL8 docvn_pode_25;
    REAL8 doctf_pod_25;
    REAL8 doctf_pode_25;
    REAL8 docvn_pod_10;
    REAL8 docvn_pode_10;
    REAL8 doctf_pod_10;
    REAL8 doctf_pode_10;    
END;

CF1 := LT.ClassificationForest();
CF2 := LT.ClassificationForest(100,0,50);
CF3 := LT.ClassificationForest(100,0,25);
CF4 := LT.ClassificationForest(100,0,10);

secs := sectors.sectorlist;

make_cfs(INTEGER n) := FUNCTION

    sect := secs[n];

    datvn_all := vansents(get_tick(fname) IN sectors.ticksn(n));
    datvnsplit := traintestsplit(datvn_all,'filename',2);
    datvn := datvnsplit.trn;
    datvnh := datvnsplit.tst;

    dattf_all := tfsents(get_tick(fname) IN sectors.ticksn(n));
    dattfsplit := traintestsplit(dattf_all,'filename',2);
    dattf := dattfsplit.trn;
    dattfh := dattfsplit.tst;

    vanff := sm.getFields(datvn);
    tfff := sm.getFields(dattf);

    Xvn := vanff.NUMF;
    Yvn := vanff.DSCF;
    Xtf := tfff.NUMF;
    Ytf := tfff.DSCF;

    vanff_h := sm.getFields(datvnh);
    tfff_h := sm.getFields(dattfh);

    Xvnh := vanff_h.NUMF;
    Yvnh := vanff_h.DSCF;
    Xtfh := tfff_h.NUMF;
    Ytfh := tfff_h.DSCF;

    mod1vn := CF1.GetModel(Xvn,Yvn);
    mod1tf := CF1.GetModel(Xtf,Ytf);
    mod2vn := CF2.GetModel(Xvn,Yvn);
    mod2tf := CF2.GetModel(Xtf,Ytf);
    mod3vn := CF3.GetModel(Xvn,Yvn);
    mod3tf := CF3.GetModel(Xtf,Ytf);
    mod4vn := CF4.GetModel(Xvn,Yvn);
    mod4tf := CF4.GetModel(Xtf,Ytf);

    preds1vn := CF1.Classify(mod1vn,Xvn);
    preds1vnh := CF1.Classify(mod1vn,Xvnh);
    preds1tf := CF1.Classify(mod1tf,Xtf);
    preds1tfh := CF1.Classify(mod1tf,Xtfh);
    preds2vn := CF2.Classify(mod2vn,Xvn);
    preds2vnh := CF2.Classify(mod2vn,Xvnh);
    preds2tf := CF2.Classify(mod2tf,Xtf);
    preds2tfh := CF2.Classify(mod2tf,Xtfh);
    preds3vn := CF3.Classify(mod3vn,Xvn);
    preds3vnh := CF3.Classify(mod3vn,Xvnh);
    preds3tf := CF3.Classify(mod3tf,Xtf);
    preds3tfh := CF3.Classify(mod3tf,Xtfh);
    preds4vn := CF4.Classify(mod4vn,Xvn);
    preds4vnh := CF4.Classify(mod4vn,Xvnh);
    preds4tf := CF4.Classify(mod4tf,Xtf);
    preds4tfh := CF4.Classify(mod4tf,Xtfh);

    //pod1 := ml_ac.Accuracy(preds1,Y);
    pod1vnh := ml_ac.Accuracy(preds1vnh,Yvnh);
    pod1tfh := ml_ac.Accuracy(preds1tfh,Ytfh);
    //pod2 := ml_ac.Accuracy(preds2,Y);
    pod2vnh := ml_ac.Accuracy(preds2vnh,Yvnh);
    pod2tfh := ml_ac.Accuracy(preds2tfh,Ytfh);
    //pod3 := ml_ac.Accuracy(preds3,Y);
    pod3vnh := ml_ac.Accuracy(preds3vnh,Yvnh);
    pod3tfh := ml_ac.Accuracy(preds3tfh,Ytfh);
    //pod4 := ml_ac.Accuracy(preds4,Y);
    pod4vnh := ml_ac.Accuracy(preds4vnh,Yvnh);
    pod4tfh := ml_ac.Accuracy(preds4tfh,Ytfh);

    dsent1vn := docsent(preds1vn,datvn);
    dsent1vnh := docsent(preds1vnh,datvnh);
    dsent1tf := docsent(preds1tf,dattf);
    dsent1tfh := docsent(preds1tfh,dattfh);
    dsent2vn := docsent(preds2vn,datvn);
    dsent2vnh := docsent(preds2vnh,datvnh);
    dsent2tf := docsent(preds2tf,dattf);
    dsent2tfh := docsent(preds2tfh,dattfh);
    dsent3vn := docsent(preds3vn,datvn);
    dsent3vnh := docsent(preds3vnh,datvnh);
    dsent3tf := docsent(preds3tf,dattf);
    dsent3tfh := docsent(preds3tfh,dattfh);
    dsent4vn := docsent(preds4vn,datvn);
    dsent4vnh := docsent(preds4vnh,datvnh);
    dsent4tf := docsent(preds4tf,dattf);
    dsent4tfh := docsent(preds4tfh,dattfh);

    docX1vn := dsent1vn.docavg;
    docX1vnh := dsent1vnh.docavg;
    docX1tf := dsent1tf.docavg;
    docX1tfh := dsent1tfh.docavg;
    docX2vn := dsent2vn.docavg;
    docX2vnh := dsent2vnh.docavg;
    docX2tf := dsent2tf.docavg;
    docX2tfh := dsent2tfh.docavg;
    docX3vn := dsent3vn.docavg;
    docX3vnh := dsent3vnh.docavg;
    docX3tf := dsent3tf.docavg;
    docX3tfh := dsent3tfh.docavg;
    docX4vn := dsent4vn.docavg;
    docX4vnh := dsent4vnh.docavg;
    docX4tf := dsent4tf.docavg;
    docX4tfh := dsent4tfh.docavg;

    docY1vn := dsent1vn.labtru;
    docY1vnh := dsent1vnh.labtru;
    docY1tf := dsent1tf.labtru;
    docY1tfh := dsent1tfh.labtru;
    docY2vn := dsent2vn.labtru;
    docY2vnh := dsent2vnh.labtru;
    docY2tf := dsent2tf.labtru;
    docY2tfh := dsent2tfh.labtru;
    docY3vn := dsent3vn.labtru;
    docY3vnh := dsent3vnh.labtru;
    docY3tf := dsent3tf.labtru;
    docY3tfh := dsent3tfh.labtru;
    docY4vn := dsent4vn.labtru;
    docY4vnh := dsent4vnh.labtru;
    docY4tf := dsent4tf.labtru;
    docY4tfh := dsent4tfh.labtru;

    dmod1vn := CF1.GetModel(docX1vn,docY1vn);
    dmod1tf := CF1.GetModel(docX1tf,docY1tf);
    dmod2vn := CF2.GetModel(docX2vn,docY2vn);
    dmod2tf := CF2.GetModel(docX2tf,docY2tf);
    dmod3vn := CF3.GetModel(docX3vn,docY3vn);
    dmod3tf := CF3.GetModel(docX3tf,docY3tf);
    dmod4vn := CF4.GetModel(docX4vn,docY4vn);
    dmod4tf := CF4.GetModel(docX4tf,docY4tf);

    //dpreds1 := CF1.Classify(mod1doc1,docX1);
    dpreds1vnh := CF1.Classify(dmod1vn,docX1vnh);
    dpreds1tfh := CF1.Classify(dmod1tf,docX1tfh);
    dpreds2vnh := CF2.Classify(dmod2vn,docX2vnh);
    dpreds2tfh := CF2.Classify(dmod2tf,docX2tfh);
    dpreds3vnh := CF3.Classify(dmod3vn,docX3vnh);
    dpreds3tfh := CF3.Classify(dmod3tf,docX3tfh);
    dpreds4vnh := CF4.Classify(dmod4vn,docX4vnh);
    dpreds4tfh := CF4.Classify(dmod4tf,docX4tfh);

    //doing the document prediction with BLR after
    //doing sentence prediction using CF
    // IMPORT LogisticRegression as LR;
    // plainblr := LR.BinomialLogisticRegression();

    // doc1mod := plainblr.GetModel(docX1,docY1);
    // doc2mod := plainblr.GetModel(docX2,docY2);
    // doc3mod := plainblr.GetModel(docX3,docY3);
    // doc4mod := plainblr.GetModel(docX4,docY4);

    // dpreds1 := plainblr.Classify(doc1mod,docX1);
    // dpreds1h := plainblr.Classify(doc1mod,docX1h);
    // dpreds2 := plainblr.Classify(doc2mod,docX2);
    // dpreds2h := plainblr.Classify(doc2mod,docX2h);
    // dpreds3 := plainblr.Classify(doc3mod,docX3);
    // dpreds3h := plainblr.Classify(doc3mod,docX3h);
    // dpreds4 := plainblr.Classify(doc4mod,docX4);
    // dpreds4h := plainblr.Classify(doc4mod,docX4h);


    docpod1vnh := ml_ac.Accuracy(dpreds1vnh,docY1vnh);
    docpod1tfh := ml_ac.Accuracy(dpreds1tfh,docY1tfh);
    docpod2vnh := ml_ac.Accuracy(dpreds2vnh,docY2vnh);
    docpod2tfh := ml_ac.Accuracy(dpreds2tfh,docY2tfh);
    docpod3vnh := ml_ac.Accuracy(dpreds3vnh,docY3vnh);
    docpod3tfh := ml_ac.Accuracy(dpreds3tfh,docY3tfh);
    docpod4vnh := ml_ac.Accuracy(dpreds4vnh,docY4vnh);
    docpod4tfh := ml_ac.Accuracy(dpreds4tfh,docY4tfh);

    result := MODULE
        EXPORT sec := sect;
        EXPORT p1v_pod := pod1vnh[1].pod;
        EXPORT p1v_pode := pod1vnh[1].pode;
        EXPORT p1t_pod := pod1tfh[1].pod;
        EXPORT p1t_pode := pod1tfh[1].pode;
        EXPORT p2v_pod := pod2vnh[1].pod;
        EXPORT p2v_pode := pod2vnh[1].pode;
        EXPORT p2t_pod := pod2tfh[1].pod;
        EXPORT p2t_pode := pod2tfh[1].pode;
        EXPORT p3v_pod := pod3vnh[1].pod;
        EXPORT p3v_pode := pod3vnh[1].pode;
        EXPORT p3t_pod := pod3tfh[1].pod;
        EXPORT p3t_pode := pod3tfh[1].pode;
        EXPORT p4v_pod := pod4vnh[1].pod;
        EXPORT p4v_pode := pod4vnh[1].pode;
        EXPORT p4t_pod := pod4tfh[1].pod;
        EXPORT p4t_pode := pod4tfh[1].pode;
        EXPORT dp1v_pod := docpod1vnh[1].pod;
        EXPORT dp1v_pode := docpod1vnh[1].pode;
        EXPORT dp1t_pod := docpod1tfh[1].pod;
        EXPORT dp1t_pode := docpod1tfh[1].pode;
        EXPORT dp2v_pod := docpod2vnh[1].pod;
        EXPORT dp2v_pode := docpod2vnh[1].pode;
        EXPORT dp2t_pod := docpod2tfh[1].pod;
        EXPORT dp2t_pode := docpod2tfh[1].pode;
        EXPORT dp3v_pod := docpod3vnh[1].pod;
        EXPORT dp3v_pode := docpod3vnh[1].pode;
        EXPORT dp3t_pod := docpod3tfh[1].pod;
        EXPORT dp3t_pode := docpod3tfh[1].pode;
        EXPORT dp4v_pod := docpod4vnh[1].pod;
        EXPORT dp4v_pode := docpod4vnh[1].pode;
        EXPORT dp4t_pod := docpod4tfh[1].pod;
        EXPORT dp4t_pode := docpod4tfh[1].pode;        
    END;

    RETURN DATASET([{result.sec,
    result.p1v_pod,result.p1v_pode,result.p1t_pod,result.p1t_pode,
    result.p2v_pod,result.p2v_pode,result.p2t_pod,result.p2t_pode,
    result.p3v_pod,result.p3v_pode,result.p3t_pod,result.p3t_pode,
    result.p4v_pod,result.p4v_pode,result.p4t_pod,result.p4t_pode,
    result.dp1v_pod,result.dp1v_pode,result.dp1t_pod,result.dp1t_pode,
    result.dp2v_pod,result.dp2v_pode,result.dp2t_pod,result.dp2t_pode,
    result.dp3v_pod,result.dp3v_pode,result.dp3t_pod,result.dp3t_pode,
    result.dp4v_pod,result.dp4v_pode,result.dp4t_pod,result.dp4t_pode}],outrec);

END;

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

OUTPUT(rs);