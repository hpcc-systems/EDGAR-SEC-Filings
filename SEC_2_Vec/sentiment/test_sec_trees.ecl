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

//load sector 1 models
sec1_100 := DATASET(WORKUNIT('W20200717-031009','mod100'),Layout_Model2);
sec1_50 := DATASET(WORKUNIT('W20200717-031009','mod50'),Layout_Model2);
sec1_25 := DATASET(WORKUNIT('W20200717-031009','mod25'),Layout_Model2);
sec1_10 := DATASET(WORKUNIT('W20200717-031009','mod10'),Layout_Model2);

//load sector 2 models
sec2_100 := DATASET(WORKUNIT('W20200717-031358','mod100'),Layout_Model2);
sec2_50 := DATASET(WORKUNIT('W20200717-031358','mod50'),Layout_Model2);
sec2_25 := DATASET(WORKUNIT('W20200717-031358','mod25'),Layout_Model2);
sec2_10 := DATASET(WORKUNIT('W20200717-031358','mod10'),Layout_Model2);

//load sector 3 models
sec3_100 := DATASET(WORKUNIT('W20200717-031757','mod100'),Layout_Model2);
sec3_50 := DATASET(WORKUNIT('W20200717-031757','mod50'),Layout_Model2);
sec3_25 := DATASET(WORKUNIT('W20200717-031757','mod25'),Layout_Model2);
sec3_10 := DATASET(WORKUNIT('W20200717-031757','mod10'),Layout_Model2);

//load sector 4 models
sec4_100 := DATASET(WORKUNIT('W20200717-031928','mod100'),Layout_Model2);
sec4_50 := DATASET(WORKUNIT('W20200717-031928','mod50'),Layout_Model2);
sec4_25 := DATASET(WORKUNIT('W20200717-031928','mod25'),Layout_Model2);
sec4_10 := DATASET(WORKUNIT('W20200717-031928','mod10'),Layout_Model2);

//load sector 5 models
sec5_100 := DATASET(WORKUNIT('W20200717-032158','mod100'),Layout_Model2);
sec5_50 := DATASET(WORKUNIT('W20200717-032158','mod50'),Layout_Model2);
sec5_25 := DATASET(WORKUNIT('W20200717-032158','mod25'),Layout_Model2);
sec5_10 := DATASET(WORKUNIT('W20200717-032158','mod10'),Layout_Model2);

//load sector 6 models
sec6_100 := DATASET(WORKUNIT('W20200717-032759','mod100'),Layout_Model2);
sec6_50 := DATASET(WORKUNIT('W20200717-032759','mod50'),Layout_Model2);
sec6_25 := DATASET(WORKUNIT('W20200717-032759','mod25'),Layout_Model2);
sec6_10 := DATASET(WORKUNIT('W20200717-032759','mod10'),Layout_Model2);

X1 := DATASET(WORKUNIT('W20200717-024513','X_sec1'),nf);
Y1 := DATASET(WORKUNIT('W20200717-024513','Y_sec1'),df);
X2 := DATASET(WORKUNIT('W20200717-024513','X_sec2'),nf);
Y2 := DATASET(WORKUNIT('W20200717-024513','Y_sec2'),df);
X3 := DATASET(WORKUNIT('W20200717-024513','X_sec3'),nf);
Y3 := DATASET(WORKUNIT('W20200717-024513','Y_sec3'),df);
X4 := DATASET(WORKUNIT('W20200717-024513','X_sec4'),nf);
Y4 := DATASET(WORKUNIT('W20200717-024513','Y_sec4'),df);
X5 := DATASET(WORKUNIT('W20200717-024513','X_sec5'),nf);
Y5 := DATASET(WORKUNIT('W20200717-024513','Y_sec5'),df);
X6 := DATASET(WORKUNIT('W20200717-024513','X_sec6'),nf);
Y6 := DATASET(WORKUNIT('W20200717-024513','Y_sec6'),df);

CF1 := ClassificationForest(50,0,100);
CF2 := ClassificationForest(50,0,50);
CF3 := CLassificationForest(50,0,25);
CF4 := ClassificationForest(50,0,10);

//CF1 preds
preds1_100 := CF1.Classify(sec1_100,X1);
preds2_100 := CF1.Classify(sec2_100,X2);
preds3_100 := CF1.Classify(sec3_100,X3);
preds4_100 := CF1.Classify(sec4_100,X4);
preds5_100 := CF1.Classify(sec5_100,X5);
preds6_100 := CF1.Classify(sec6_100,X6);

//CF2 preds
preds1_50 := CF2.Classify(sec1_50,X1);
preds2_50 := CF2.Classify(sec2_50,X2);
preds3_50 := CF2.Classify(sec3_50,X3);
preds4_50 := CF2.Classify(sec4_50,X4);
preds5_50 := CF2.Classify(sec5_50,X5);
preds6_50 := CF2.Classify(sec6_50,X6);

//CF3 preds
preds1_25 := CF3.Classify(sec1_25,X1);
preds2_25 := CF3.Classify(sec2_25,X2);
preds3_25 := CF3.Classify(sec3_25,X3);
preds4_25 := CF3.Classify(sec4_25,X4);
preds5_25 := CF3.Classify(sec5_25,X5);
preds6_25 := CF3.Classify(sec6_25,X6);

//CF4 preds
preds1_10 := CF4.Classify(sec1_10,X1);
preds2_10 := CF4.Classify(sec2_10,X2);
preds3_10 := CF4.Classify(sec3_10,X3);
preds4_10 := CF4.Classify(sec4_10,X4);
preds5_10 := CF4.Classify(sec5_10,X5);
preds6_10 := CF4.Classify(sec6_10,X6);

//plainblr := LR.BinomialLogisticRegression();

precon1_100 := LR.Confusion(Y1,preds1_100);
con1_100 := LR.BinomialConfusion(precon1_100);
precon2_100 := LR.Confusion(Y2,preds2_100);
con2_100 := LR.BinomialConfusion(precon2_100);
precon3_100 := LR.Confusion(Y3,preds3_100);
con3_100 := LR.BinomialConfusion(precon3_100);
precon4_100 := LR.Confusion(Y4,preds4_100);
con4_100 := LR.BinomialConfusion(precon4_100);
precon5_100 := LR.Confusion(Y5,preds5_100);
con5_100 := LR.BinomialConfusion(precon5_100);
precon6_100 := LR.Confusion(Y6,preds6_100);
con6_100 := LR.BinomialConfusion(precon6_100);

precon1_50 := LR.Confusion(Y1,preds1_50);
con1_50 := LR.BinomialConfusion(precon1_50);
precon2_50 := LR.Confusion(Y2,preds2_50);
con2_50 := LR.BinomialConfusion(precon2_50);
precon3_50 := LR.Confusion(Y3,preds3_50);
con3_50 := LR.BinomialConfusion(precon3_50);
precon4_50 := LR.Confusion(Y4,preds4_50);
con4_50 := LR.BinomialConfusion(precon4_50);
precon5_50 := LR.Confusion(Y5,preds5_50);
con5_50 := LR.BinomialConfusion(precon5_50);
precon6_50 := LR.Confusion(Y6,preds6_50);
con6_50 := LR.BinomialConfusion(precon6_50);

precon1_25 := LR.Confusion(Y1,preds1_25);
con1_25 := LR.BinomialConfusion(precon1_25);
precon2_25 := LR.Confusion(Y2,preds2_25);
con2_25 := LR.BinomialConfusion(precon2_25);
precon3_25 := LR.Confusion(Y3,preds3_25);
con3_25 := LR.BinomialConfusion(precon3_25);
precon4_25 := LR.Confusion(Y4,preds4_25);
con4_25 := LR.BinomialConfusion(precon4_25);
precon5_25 := LR.Confusion(Y5,preds5_25);
con5_25 := LR.BinomialConfusion(precon5_25);
precon6_25 := LR.Confusion(Y6,preds6_25);
con6_25 := LR.BinomialConfusion(precon6_25);

precon1_10 := LR.Confusion(Y1,preds1_10);
con1_10 := LR.BinomialConfusion(precon1_10);
precon2_10 := LR.Confusion(Y2,preds2_10);
con2_10 := LR.BinomialConfusion(precon2_10);
precon3_10 := LR.Confusion(Y3,preds3_10);
con3_10 := LR.BinomialConfusion(precon3_10);
precon4_10 := LR.Confusion(Y4,preds4_10);
con4_10 := LR.BinomialConfusion(precon4_10);
precon5_10 := LR.Confusion(Y5,preds5_10);
con5_10 := LR.BinomialConfusion(precon5_10);
precon6_10 := LR.Confusion(Y6,preds6_10);
con6_10 := LR.BinomialConfusion(precon6_10);

conset := [con1_100,con1_50,con1_25,con1_10,
        con2_100,con2_50,con2_25,con2_10,
        con3_100,con3_50,con3_25,con3_10,
        con4_100,con4_50,con4_25,con4_10,
        con5_100,con5_50,con5_25,con5_10,
        con6_100,con6_50,con6_25,con6_10];

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

outrec acc_T(idrec C) := TRANSFORM
    SELF.sector := secs[TRUNCATE((C.i-1)/4)];
    SELF.depth := depth[(C.i%4)+1];
    SELF.acc := conset[C.i][1].accuracy;
END;

cid1 := DATASET(24,TRANSFORM(idrec,SELF.i := 0));
cidx := ITERATE(cid1,TRANSFORM(idrec,SELF.i := LEFT.i+1));

out := PROJECT(cidx,acc_T(LEFT));

OUTPUT(out);