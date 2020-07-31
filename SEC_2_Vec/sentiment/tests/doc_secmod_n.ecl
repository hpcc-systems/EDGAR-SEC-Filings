IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT LogisticRegression as LR;
IMPORT ML_Core.Analysis.Classification as ml_ac;
IMPORT * FROM Types;
IMPORT LearningTrees as LT;

EXPORT doc_secmod_n(STRING veclbltype = 'pl_vn',INTEGER n,STRING spliton='ticker',STRING mtyp='BLR') := FUNCTION
    pl_vn := DATASET(WORKUNIT('W20200726-092906','plain_vanilla'),trainrec);
    pl_tf := DATASET(WORKUNIT('W20200726-092906','plain_tfidf'),trainrec);

    secn := sectors.sectorlist[n];

    v := CASE(veclbltype, 'pl_vn' => pl_vn, 'pl_tf' => pl_tf, 'sp_vn' => lbljoin(pl_vn), 'sp_tf' => lbljoin(pl_tf));
    pv := v(get_tick(fname) in sectors.ticksn(n));

    dat_all := doc_model(pv);
    dat := traintestsplit(dat_all,spliton,2);

    dat_trn := dat.trn;
    dat_tst := dat.tst;

    ff := sent_model.getFields(dat_trn);
    ff_tst := sent_model.getFields(dat_tst);

    X := ff.NUMF;
    Y := ff.DSCF;
    Xh := ff_tst.NUMF;
    Yh := ff_tst.DSCF;

    plainblr := LR.BinomialLogisticRegression();
    CF := LT.ClassificationForest();

    modtyp := IF(mtyp='BLR',plainblr,CF);

    mod := modtyp.GetModel(X,Y);

    preds := modtyp.Classify(mod,X);
    predsh := modtyp.Classify(mod,Xh);

    pod := ml_ac.Accuracy(preds,Y);
    podh := ml_ac.Accuracy(predsh,Yh);

    result := MODULE
        EXPORT p_in := pod[1].pod;
        EXPORT pe_in := pod[1].pode;
        EXPORT p_out := podh[1].pod;
        EXPORT pe_out := podh[1].pode;
    END;

    RETURN result;
END;