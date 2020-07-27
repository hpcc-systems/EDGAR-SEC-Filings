IMPORT Types as secTypes;
IMPORT * FROM secTypes;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.similarity;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT LogisticRegression as LR;
IMPORT ML_Core;
IMPORT ML_Core.Types as mlTypes;


EXPORT qoq_secmod_n(STRING veclbltype = 'pl_vn',INTEGER n) := FUNCTION//,STRING spliton='ticker') := FUNCTION
    pl_vn := DATASET(WORKUNIT('W20200726-092906','plain_vanilla'),trainrec);
    pl_tf := DATASET(WORKUNIT('W20200726-092906','plain_tfidf'),trainrec);
    secn := sectors.sectorlist[n];
    v := CASE(veclbltype, 'pl_vn' => pl_vn, 'pl_tf' => pl_tf, 'sp_vn' => lbljoin(pl_vn), 'sp_tf' => lbljoin(pl_tf));
    pv := v(get_tick(fname) in sectors.ticksn(n));

    dat := traintestsplit(pv,'ticker',2);
    dat_secn := dat.trn;
    dat_h := dat.tst;

    sl_secn := simlabs(dat_secn,'add');
    sl_h := simlabs(dat_h,'add');

    sal_secn := sl_secn.sim_and_labels;
    sal_h := sl_h.sim_and_labels;

    ff_secn := sl_secn.getFields;
    ff_h := sl_h.getFields;

    Xtrn := ff_secn.x;
    Ytrn := ff_secn.y;

    Xtst := ff_h.x;
    Ytst := ff_h.y;

    plainblr := LR.BinomialLogisticRegression();

    mod := plainblr.getmodel(Xtrn,Ytrn);
    predsh := plainblr.Classify(mod,Xtst);

    pod := ML_Core.Analysis.Classification.Accuracy(predsh,Ytst);

    result := MODULE
        EXPORT p := pod[1].pod;
        EXPORT pe := pod[1].pode;
        EXPORT s := sal_secn;
        EXPORT sh := sal_h; 
    END;
    RETURN result;
END;