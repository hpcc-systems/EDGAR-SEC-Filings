IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT ML_Core;
//IMPORT * FROM ML_Core.Analysis.Classification;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT LogisticRegression as LR;
IMPORT TextVectors as tv;
IMPORT * FROM tv.Types;
IMPORT * FROM Types;

EXPORT bothlbl_secmod_n(STRING veclbltype = 'pl_vn',INTEGER n,STRING spliton='filename') := FUNCTION
    
    pl_vn := DATASET(WORKUNIT('W20200726-092906','plain_vanilla'),trainrec);
    pl_tf := DATASET(WORKUNIT('W20200726-092906','plain_tfidf'),trainrec);

    secn := sectors.sectorlist[n];

    v := CASE(veclbltype, 'pl_vn' => pl_vn, 'pl_tf' => pl_tf, 'sp_vn' => lbljoin(pl_vn), 'sp_tf' => lbljoin(pl_tf));
    pv := v(get_tick(fname) in sectors.ticksn(n));

    dat := traintestsplit(pv,spliton,2);
    dat_secn := dat.trn;
    dat_h := dat.tst;

    ff := sent_model.getFields(dat_secn);

    X := ff.NUMF;
    Y := ff.DSCF;

    h := sent_model.getFields(dat_h);

    Xh := h.NUMF;
    Yh := h.DSCF;

    plainblr := LR.BinomialLogisticRegression();

    mod := plainblr.getModel(X,Y);

    preds := plainblr.Classify(mod,X);
    predsh := plainblr.Classify(mod,Xh);

    podh := ML_Core.Analysis.Classification.Accuracy(predsh,Yh);

    doctrn := docsent(preds,dat_secn);
    doctst := docsent(predsh,dat_h);

    docX := doctrn.docavg;
    docY := doctrn.labtru;
    docXh := doctst.docavg;
    docYh := doctst.labtru;

    docmod := plainblr.getModel(docX,docY);

    docpredsh := plainblr.Classify(docmod,docXh);

    docpodh := ML_Core.Analysis.Classification.Accuracy(docpredsh,docYh);

    result := MODULE
        EXPORT s := secn;
        EXPORT h := podh;
        EXPORT dh := docpodh;
    END;
    RETURN result;
END;