IMPORT STD;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM ML_Core;
IMPORT TextVectors as tv;
IMPORT LogisticRegression as LR;
IMPORT LearningTrees AS LT;
IMPORT * FROM LT;
IMPORT sectors from SEC_2_Vec.sentiment.tests;
IMPORT * FROM EDGAR_Extract.Text_Tools;

//#OPTION('outputLimit',150);
#OPTION('outputLimit',2000);

nf := ML_Core.Types.NumericField;
df := ML_Core.Types.DiscreteField;

CF1 := ClassificationForest(50,0,100);
CF2 := ClassificationForest(50,0,50);
CF3 := ClassificationForest(50,0,25);
CF4 := ClassificationForest(50,0,10);

X := DATASET(WORKUNIT('W20200717-065422','X_sec13'),nf);
Y := DATASET(WORKUNIT('W20200717-065422','Y_sec13'),df);

mod1 := CF1.GetModel(X,Y);
mod2 := CF2.GetModel(X,Y);
mod3 := CF3.GetModel(X,Y);
mod4 := CF4.GetModel(X,Y);

OUTPUT(mod1,ALL,NAMED('mod100'));
OUTPUT(mod2,ALL,NAMED('mod50'));
OUTPUT(mod3,ALL,NAMED('mod25'));
OUTPUT(mod4,ALL,NAMED('mod10'));