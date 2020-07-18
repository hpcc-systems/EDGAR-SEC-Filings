IMPORT ML_Core;
IMPORT SEC_2_Vec.sentiment;
IMPORT * FROM sentiment;
IMPORT * FROM sentiment.tests;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT LogisticRegression as LR;

trec := sentiment.sent_model.trainrec;

EXPORT secmod_n(INTEGER n,STRING approach='plain') := FUNCTION
    secs := sectors.sectorlist;
    secn := secs[n];

    secticksn := SET(sectors.sectorticker(sector=secn),ticker);

    // wu1 := DATASET(WORKUNIT('W20200711-042721','plain_label_vanilla_data'),trec);
    // wu2 := DATASET(WORKUNIT('W20200711-064253','sandp_label_vanilla_data'),trec);
    wu1 := DATASET(WORKUNIT('W20200712-032452','plain_label_vanilla_data'),trec);
    wu2 := DATASET(WORKUNIT('W20200713-063347','sandp_label_vanilla_data'),trec);


    //plainlblvn := DATASET(WORKUNIT('W20200711-042721','plain_label_vanilla_data'),trec);
    //plainlblvn := DATASET(wu,trec);
    lblvn := IF(approach='plain',wu1,wu2);

    dat_secn_all := lblvn(get_tick(fname) in secticksn);
    dat_secn := dat_secn_all(id%2=0);
    dat_h := dat_secn_all(id%2=1);

    plain := sent_model.getFields(dat_secn);

    X := plain.NUMF;
    Y := plain.DSCF;

    plainh := sent_model.getFields(dat_h);

    Xh := plainh.NUMF;
    Yh := plainh.DSCF;

    plainblr := LR.BinomialLogisticRegression();

    modpl := plainblr.getModel(X,Y);

    conpl := LR.BinomialConfusion(plainblr.Report(modpl,X,Y));

    preds := plainblr.Classify(modpl,X);
    predsh := plainblr.Classify(modpl,Xh);

    podpl := ML_Core.Analysis.Classification.Accuracy(preds,Y);
    podplh := ML_Core.Analysis.Classification.Accuracy(predsh,Yh);

    result := MODULE
        EXPORT s := secn;
        EXPORT c := conpl;
        EXPORT p := podpl;
        EXPORT h := podplh;
    END;
    RETURN result;
END;