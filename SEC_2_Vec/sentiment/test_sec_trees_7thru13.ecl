IMPORT LearningTrees as LT;
IMPORT * FROM LT;
IMPORT ML_Core.Types as CTypes;
IMPORT LogisticRegression as LR;
IMPORT * FROM SEC_2_Vec.sentiment.tests;

//we have generated Classification Forest models for 
//sectors 1,2, and 3 at depths of 100,50,25, and 10 
//in a previous work unit. now we can compare them.

//first define model record type so we can load
Layout_Model2 := CTypes.Layout_Model2;
nf := CTypes.NumericField;
df := CTypes.DiscreteField;
conrec := LR.Types.Binomial_Confusion_Summary;

secs := sectors.sectorlist;

//load sector 7 models
sec7_100 := DATASET(WORKUNIT('W20200717-033205','mod100'),Layout_Model2);
sec7_50 := DATASET(WORKUNIT('W20200717-033205','mod50'),Layout_Model2);
sec7_25 := DATASET(WORKUNIT('W20200717-033205','mod25'),Layout_Model2);
sec7_10 := DATASET(WORKUNIT('W20200717-033205','mod10'),Layout_Model2);

//load sector 8 models
sec8_100 := DATASET(WORKUNIT('W20200717-033951','mod100'),Layout_Model2);
sec8_50 := DATASET(WORKUNIT('W20200717-033951','mod50'),Layout_Model2);
sec8_25 := DATASET(WORKUNIT('W20200717-033951','mod25'),Layout_Model2);
sec8_10 := DATASET(WORKUNIT('W20200717-033951','mod10'),Layout_Model2);

//load sector 9 models
sec9_100 := DATASET(WORKUNIT('W20200717-034352','mod100'),Layout_Model2);
sec9_50 := DATASET(WORKUNIT('W20200717-034352','mod50'),Layout_Model2);
sec9_25 := DATASET(WORKUNIT('W20200717-034352','mod25'),Layout_Model2);
sec9_10 := DATASET(WORKUNIT('W20200717-034352','mod10'),Layout_Model2);

//load sector 10 models
sec10_100 := DATASET(WORKUNIT('W20200717-034522','mod100'),Layout_Model2);
sec10_50 := DATASET(WORKUNIT('W20200717-034522','mod50'),Layout_Model2);
sec10_25 := DATASET(WORKUNIT('W20200717-034522','mod25'),Layout_Model2);
sec10_10 := DATASET(WORKUNIT('W20200717-034522','mod10'),Layout_Model2);

//load sector 11 models
sec11_100 := DATASET(WORKUNIT('W20200717-035021','mod100'),Layout_Model2);
sec11_50 := DATASET(WORKUNIT('W20200717-035021','mod50'),Layout_Model2);
sec11_25 := DATASET(WORKUNIT('W20200717-035021','mod25'),Layout_Model2);
sec11_10 := DATASET(WORKUNIT('W20200717-035021','mod10'),Layout_Model2);

//load sector 12 models
sec12_100 := DATASET(WORKUNIT('W20200717-035410','mod100'),Layout_Model2);
sec12_50 := DATASET(WORKUNIT('W20200717-035410','mod50'),Layout_Model2);
sec12_25 := DATASET(WORKUNIT('W20200717-035410','mod25'),Layout_Model2);
sec12_10 := DATASET(WORKUNIT('W20200717-035410','mod10'),Layout_Model2);

//load sector 13 models
sec13_100 := DATASET(WORKUNIT('W20200717-065711','mod100'),Layout_Model2);
sec13_50 := DATASET(WORKUNIT('W20200717-065711','mod50'),Layout_Model2);
sec13_25 := DATASET(WORKUNIT('W20200717-065711','mod25'),Layout_Model2);
sec13_10 := DATASET(WORKUNIT('W20200717-065711','mod10'),Layout_Model2);

X7 := DATASET(WORKUNIT('W20200717-024906','X_sec7'),nf);
Y7 := DATASET(WORKUNIT('W20200717-024906','Y_sec7'),df);
X8 := DATASET(WORKUNIT('W20200717-024906','X_sec8'),nf);
Y8 := DATASET(WORKUNIT('W20200717-024906','Y_sec8'),df);
X9 := DATASET(WORKUNIT('W20200717-024906','X_sec9'),nf);
Y9 := DATASET(WORKUNIT('W20200717-024906','Y_sec9'),df);
X10 := DATASET(WORKUNIT('W20200717-024906','X_sec10'),nf);
Y10 := DATASET(WORKUNIT('W20200717-024906','Y_sec10'),df);
X11 := DATASET(WORKUNIT('W20200717-024906','X_sec11'),nf);
Y11 := DATASET(WORKUNIT('W20200717-024906','Y_sec11'),df);
X12 := DATASET(WORKUNIT('W20200717-024906','X_sec12'),nf);
Y12 := DATASET(WORKUNIT('W20200717-024906','Y_sec12'),df);
X13 := DATASET(WORKUNIT('W20200717-065422','X_sec13'),nf);
Y13 := DATASET(WORKUNIT('W20200717-065422','Y_sec13'),df);

CF1 := ClassificationForest(50,0,100);
CF2 := ClassificationForest(50,0,50);
CF3 := CLassificationForest(50,0,25);
CF4 := ClassificationForest(50,0,10);

//CF1 preds
preds7_100 := CF1.Classify(sec7_100,X7);
preds8_100 := CF1.Classify(sec8_100,X8);
preds9_100 := CF1.Classify(sec9_100,X9);
preds10_100 := CF1.Classify(sec10_100,X10);
preds11_100 := CF1.Classify(sec11_100,X11);
preds12_100 := CF1.Classify(sec12_100,X12);
preds13_100 := CF1.Classify(sec13_100,X13);

//CF2 preds
preds7_50 := CF2.Classify(sec7_50,X7);
preds8_50 := CF2.Classify(sec8_50,X8);
preds9_50 := CF2.Classify(sec9_50,X9);
preds10_50 := CF2.Classify(sec10_50,X10);
preds11_50 := CF2.Classify(sec11_50,X11);
preds12_50 := CF2.Classify(sec12_50,X12);
preds13_50 := CF2.Classify(sec13_50,X13);

//CF3 preds
preds7_25 := CF3.Classify(sec7_25,X7);
preds8_25 := CF3.Classify(sec8_25,X8);
preds9_25 := CF3.Classify(sec9_25,X9);
preds10_25 := CF3.Classify(sec10_25,X10);
preds11_25 := CF3.Classify(sec11_25,X11);
preds12_25 := CF3.Classify(sec12_25,X12);
preds13_25 := CF3.Classify(sec13_25,X13);

//CF4 preds
preds7_10 := CF4.Classify(sec7_10,X7);
preds8_10 := CF4.Classify(sec8_10,X8);
preds9_10 := CF4.Classify(sec9_10,X9);
preds10_10 := CF4.Classify(sec10_10,X10);
preds11_10 := CF4.Classify(sec11_10,X11);
preds12_10 := CF4.Classify(sec12_10,X12);
preds13_10 := CF4.Classify(sec13_10,X13);

//plainblr := LR.BinomialLogisticRegression();

precon7_100 := LR.Confusion(Y7,preds7_100);
con7_100 := LR.BinomialConfusion(precon7_100);
precon8_100 := LR.Confusion(Y8,preds8_100);
con8_100 := LR.BinomialConfusion(precon8_100);
precon9_100 := LR.Confusion(Y9,preds9_100);
con9_100 := LR.BinomialConfusion(precon9_100);
precon10_100 := LR.Confusion(Y10,preds10_100);
con10_100 := LR.BinomialConfusion(precon10_100);
precon11_100 := LR.Confusion(Y11,preds11_100);
con11_100 := LR.BinomialConfusion(precon11_100);
precon12_100 := LR.Confusion(Y12,preds12_100);
con12_100 := LR.BinomialConfusion(precon12_100);
precon13_100 := LR.Confusion(Y13,preds13_100);
con13_100 := LR.BinomialConfusion(precon13_100);

precon7_50 := LR.Confusion(Y7,preds7_50);
con7_50 := LR.BinomialConfusion(precon7_50);
precon8_50 := LR.Confusion(Y8,preds8_50);
con8_50 := LR.BinomialConfusion(precon8_50);
precon9_50 := LR.Confusion(Y9,preds9_50);
con9_50 := LR.BinomialConfusion(precon9_50);
precon10_50 := LR.Confusion(Y10,preds10_50);
con10_50 := LR.BinomialConfusion(precon10_50);
precon11_50 := LR.Confusion(Y11,preds11_50);
con11_50 := LR.BinomialConfusion(precon11_50);
precon12_50 := LR.Confusion(Y12,preds12_50);
con12_50 := LR.BinomialConfusion(precon12_50);
precon13_50 := LR.Confusion(Y13,preds13_50);
con13_50 := LR.BinomialConfusion(precon13_50);

precon7_25 := LR.Confusion(Y7,preds7_25);
con7_25 := LR.BinomialConfusion(precon7_25);
precon8_25 := LR.Confusion(Y8,preds8_25);
con8_25 := LR.BinomialConfusion(precon8_25);
precon9_25 := LR.Confusion(Y9,preds9_25);
con9_25 := LR.BinomialConfusion(precon9_25);
precon10_25 := LR.Confusion(Y10,preds10_25);
con10_25 := LR.BinomialConfusion(precon10_25);
precon11_25 := LR.Confusion(Y11,preds11_25);
con11_25 := LR.BinomialConfusion(precon11_25);
precon12_25 := LR.Confusion(Y12,preds12_25);
con12_25 := LR.BinomialConfusion(precon12_25);
precon13_25 := LR.Confusion(Y13,preds13_25);
con13_25 := LR.BinomialConfusion(precon13_25);

precon7_10 := LR.Confusion(Y7,preds7_10);
con7_10 := LR.BinomialConfusion(precon7_10);
precon8_10 := LR.Confusion(Y8,preds8_10);
con8_10 := LR.BinomialConfusion(precon8_10);
precon9_10 := LR.Confusion(Y9,preds9_10);
con9_10 := LR.BinomialConfusion(precon9_10);
precon10_10 := LR.Confusion(Y10,preds10_10);
con10_10 := LR.BinomialConfusion(precon10_10);
precon11_10 := LR.Confusion(Y11,preds11_10);
con11_10 := LR.BinomialConfusion(precon11_10);
precon12_10 := LR.Confusion(Y12,preds12_10);
con12_10 := LR.BinomialConfusion(precon12_10);
precon13_10 := LR.Confusion(Y13,preds13_10);
con13_10 := LR.BinomialConfusion(precon13_10);

conconrec := RECORD
    DATASET(conrec) conrow;
END;

secrec := RECORD
    STRING sector;
END;

secds := DATASET(secs,secrec);

conset := [con7_100,con7_50,con7_25,con7_10,
            con8_100,con8_50,con8_25,con8_10,
            con9_100,con9_50,con9_25,con9_10,
            con10_100,con10_50,con10_25,con10_10,
            con11_100,con11_50,con11_25,con11_10,
            con12_100,con12_50,con12_25,con12_10,
            con13_100,con13_50,con13_25,con13_10];

conds := DATASET([{con7_100},{con7_50},{con7_25},{con7_10},
        {con8_100},{con8_50},{con8_25},{con8_10},
        {con9_100},{con9_50},{con9_25},{con9_10},
        {con10_100},{con10_50},{con10_25},{con10_10},
        {con11_100},{con11_50},{con11_25},{con11_10},
        {con12_100},{con12_50},{con12_25},{con12_10},
        {con13_100},{con13_50},{con13_25},{con13_10}],conconrec);

depth := [100,50,25,10];

outrec := RECORD
    STRING sector;
    INTEGER depth;
    REAL8 acc;
END;

idrec := RECORD
    INTEGER i;
END;

idstrt := RECORD
    INTEGER i := 0;
END;

cidrec := RECORD
    INTEGER i;
    STRING sector;
    INTEGER depth;
    REAL8 acc;
END;

cidrec acc_T(cidrec C,cidrec Cr) := TRANSFORM
    SELF.i := Cr.i;
    SELF.sector := secs[7+TRUNCATE((Cr.i-1)/4)];
    SELF.depth := depth[Cr.i%4+1];
    SELF.acc := conset[Cr.i][1].accuracy;
END;

cid1 := DATASET(28,TRANSFORM(cidrec,SELF.i := 0,SELF.sector := '',SELF.depth := 0,SELF.acc := 0.0));


cidx := ITERATE(cid1,TRANSFORM(cidrec,SELF.i := LEFT.i+1,SELF := LEFT));

out := ITERATE(cidx,acc_T(LEFT,RIGHT));

OUTPUT(out);