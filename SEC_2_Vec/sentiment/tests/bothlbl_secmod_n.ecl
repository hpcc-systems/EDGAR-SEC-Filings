IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT ML_Core;
//IMPORT * FROM ML_Core.Analysis.Classification;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT LogisticRegression as LR;
IMPORT TextVectors as tv;
IMPORT * FROM tv.Types;
IMPORT * FROM Types;

EXPORT bothlbl_secmod_n(DATASET(trainrec) pl_vn,DATASET(trainrec) pl_tf,DATASET(trainrec) sp_vn,DATASET(trainrec) sp_tf,INTEGER n,STRING spliton='filename') := FUNCTION

    // //sam := sents_and_mod;
    // //model := sam.m;
    // //sents := sam.p;

    // trainrec make_tr_T(TextMod m) := TRANSFORM
    //     plainrow := sents(sentId=m.id)[1];
    //     SELF.label := plainrow.label;
    //     SELF.fname := plainrow.fname;
    //     SELF.id := m.id;
    //     SELF.text := m.text;
    //     SELF.vec := m.vec;
    // END;

    // tr := PROJECT(model(typ=2),make_tr_T(LEFT));

    // pl_vn := tr;
    // pl_tf := tfidf_experimental(model(typ=1),sents,100,1);
    // sp_vn := lbljoin(pl_vn);
    // sp_tf := lbljoin(pl_tf);

    // secs := sectors.sectorlist;
    // secn := secs[n];

    // secticksn := SET(sectors.sectorticker(sector=secn),ticker);
    secn := sectors.sectorlist[n];

    pv := pl_vn(get_tick(fname) in sectors.ticksn(n));//secticksn);
    pt := pl_tf(get_tick(fname) in sectors.ticksn(n));//secticksn);
    sv := sp_vn(get_tick(fname) in sectors.ticksn(n));//secticksn);
    st := sp_tf(get_tick(fname) in sectors.ticksn(n));//secticksn);

    dat1 := traintestsplit(pv,spliton,2);
    dat1_secn := dat1.trn;
    dat1_h := dat1.tst;
    dat2 := traintestsplit(pt,spliton,2);
    dat2_secn := dat2.trn;
    dat2_h := dat2.tst;
    dat3 := traintestsplit(sv,spliton,2);
    dat3_secn := dat3.trn;
    dat3_h := dat3.tst;
    dat4 := traintestsplit(st,spliton,2);
    dat4_secn := dat4.trn;
    dat4_h := dat4.tst;

    ff1 := sent_model.getFields(dat1_secn);
    ff2 := sent_model.getFields(dat2_secn);
    ff3 := sent_model.getFields(dat3_secn);
    ff4 := sent_model.getFields(dat4_secn);

    X1 := ff1.NUMF;
    Y1 := ff1.DSCF;
    X2 := ff2.NUMF;
    Y2 := ff2.DSCF;
    X3 := ff3.NUMF;
    Y3 := ff3.DSCF;
    X4 := ff4.NUMF;
    Y4 := ff4.DSCF;

    h1 := sent_model.getFields(dat1_h);
    h2 := sent_model.getFields(dat2_h);
    h3 := sent_model.getFields(dat3_h);
    h4 := sent_model.getFields(dat4_h);

    X1h := h1.NUMF;
    Y1h := h1.DSCF;
    X2h := h2.NUMF;
    Y2h := h2.DSCF;
    X3h := h3.NUMF;
    Y3h := h3.DSCF;
    X4h := h4.NUMF;
    Y4h := h4.DSCF;

    plainblr := LR.BinomialLogisticRegression();

    mod1 := plainblr.getModel(X1,Y1);
    mod2 := plainblr.getModel(X2,Y2);
    mod3 := plainblr.getModel(X3,Y3);
    mod4 := plainblr.getModel(X4,Y4);

    preds1 := plainblr.Classify(mod1,X1);
    preds2 := plainblr.Classify(mod2,X2);
    preds3 := plainblr.Classify(mod3,X3);
    preds4 := plainblr.Classify(mod4,X4);
    preds1h := plainblr.Classify(mod1,X1h);
    preds2h := plainblr.Classify(mod2,X2h);
    preds3h := plainblr.Classify(mod3,X3h);
    preds4h := plainblr.Classify(mod4,X4h);

    pod1h := ML_Core.Analysis.Classification.Accuracy(preds1h,Y1h);
    pod2h := ML_Core.Analysis.Classification.Accuracy(preds2h,Y2h);
    pod3h := ML_Core.Analysis.Classification.Accuracy(preds3h,Y3h);
    pod4h := ML_Core.Analysis.Classification.Accuracy(preds4h,Y4h);

    doctrn1 := docsent(preds1,dat1_secn);
    doctrn2 := docsent(preds2,dat2_secn);
    doctrn3 := docsent(preds3,dat3_secn);
    doctrn4 := docsent(preds4,dat4_secn);
    doctst1 := docsent(preds1h,dat1_h);
    doctst2 := docsent(preds2h,dat2_h);
    doctst3 := docsent(preds3h,dat3_h);
    doctst4 := docsent(preds4h,dat4_h);

    docX1 := doctrn1.docavg;
    docY1 := doctrn1.labtru;
    docX2 := doctrn2.docavg;
    docY2 := doctrn2.labtru;
    docX3 := doctrn3.docavg;
    docY3 := doctrn3.labtru;
    docX4 := doctrn4.docavg;
    docY4 := doctrn4.labtru;
    docX1h := doctst1.docavg;
    docY1h := doctst1.labtru;
    docX2h := doctst2.docavg;
    docY2h := doctst2.labtru;
    docX3h := doctst3.docavg;
    docY3h := doctst3.labtru;
    docX4h := doctst4.docavg;
    docY4h := doctst4.labtru;

    docmod1 := plainblr.getModel(docX1,docY1);
    docmod2 := plainblr.getModel(docX2,docY2);
    docmod3 := plainblr.getModel(docX3,docY3);
    docmod4 := plainblr.getModel(docX4,docY4);

    docpreds1h := plainblr.Classify(docmod1,docX1h);
    docpreds2h := plainblr.Classify(docmod2,docX2h);
    docpreds3h := plainblr.Classify(docmod3,docX3h);
    docpreds4h := plainblr.Classify(docmod4,docX4h);

    docpod1h := ML_Core.Analysis.Classification.Accuracy(docpreds1h,docY1h);
    docpod2h := ML_Core.Analysis.Classification.Accuracy(docpreds2h,docY2h);
    docpod3h := ML_Core.Analysis.Classification.Accuracy(docpreds3h,docY3h);
    docpod4h := ML_Core.Analysis.Classification.Accuracy(docpreds4h,docY4h);


    result := MODULE
        EXPORT s := secn;
        EXPORT h1 := pod1h;
        EXPORT h2 := pod2h;
        EXPORT h3 := pod3h;
        EXPORT h4 := pod4h;
        EXPORT dh1 := docpod1h;
        EXPORT dh2 := docpod2h;
        EXPORT dh3 := docpod3h;
        EXPORT dh4 := docpod4h;
    END;
    RETURN result;
END;