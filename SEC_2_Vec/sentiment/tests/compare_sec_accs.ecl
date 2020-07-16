IMPORT LogisticRegression as LR;
IMPORT * FROM SEC_2_Vec.sentiment.tests;
//IMPORT * FROM SEC_2_Vec.similarity;

conrec := LR.Types.Binomial_Confusion_Summary;
//We have run workunits with sector model results for plain labeling scheme and s&p
//Now seek to collect convenient list of these accuracies for comparison

#OPTION('outputLimit',500);

//plain label models
wu1 := 'W20200713-063856';
//s&p label models
wu2 := 'W20200713-064131';

idrec := RECORD
    INTEGER i;
END;

twelve := DATASET([1,2,3,4,5,6,7,8,9,10,11,12],idrec);

secaccrec := RECORD
    STRING sector;
    REAL8 acc;
END;

secaccrec acc_T(idrec j,STRING approach) := TRANSFORM
    n := secmod_n(j.i,approach);
    SELF.sector := n.s;
    SELF.acc := n.c[1].accuracy;
END;



plain := PROJECT(twelve,acc_T(LEFT,'plain'));
sandp := PROJECT(twelve,acc_T(LEFT,'s&p'));

//we also want to t-test the difference in means
// m1 := AVE(plain,plain.acc);
// m2 := AVE(sandp,sandp.acc);

//var1 := VARIANCE(plain,acc);
//var2 := VARIANCE(sandp,acc);

// c1 := COUNT(plain);
// c2 := COUNT(sandp);

//diffmean := mean1-mean2;
//stderr := SQRT((var1/c1) + (var2/c2));

//tscore := diffmean/stderr;

OUTPUT(plain);
OUTPUT(sandp);
//OUTPUT(tscore);
//OUTPUT(diffmean);