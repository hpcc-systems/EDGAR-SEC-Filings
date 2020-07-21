IMPORT STD;
IMPORT SEC_2_Vec.sentiment;
IMPORT * FROM sentiment;
IMPORT * FROM ML_Core;
IMPORT TextVectors as tv;
IMPORT LogisticRegression as LR;
IMPORT LearningTrees AS LT;
IMPORT * FROM LT;
IMPORT sectors from SEC_2_Vec.sentiment;
IMPORT * FROM EDGAR_Extract.Text_Tools;

trainrec := sent_model.trainrec;
nf := ML_Core.Types.NumericField;
df := ML_Core.Types.DiscreteField;
crec := ML_Core.Types.Classify_Result;

EXPORT tree_test_pipeline(STRING approach='plain') := MODULE
    path10k := '~ncf::edgarfilings::raw::labels_allsecs_all_10k';
    path10q := '~ncf::edgarfilings::raw::plainlabel_allsecs_all';

    EXPORT Tree_Param_Comparison := RECORD
        STRING sector;
        REAL8 acc100;
        REAL8 acc50;
        REAL8 acc25;
        REAL8 acc10;
    END;

    SHARED secrec := RECORD
        STRING sector;
    END;

    SHARED idrec := RECORD
        INTEGER i;
    END;

    EXPORT dat := IF(approach='plain',sentiment.tests.plainlblvn,sentiment.tests.sandplblvn);

    secs := sectors.sectorlist;

    CF1 := LT.ClassificationForest(50,0,100);
    CF2 := LT.ClassificationForest(50,0,50);
    CF3 := LT.ClassificationForest(50,0,25);
    CF4 := LT.ClassificationForest(50,0,10);

    sector_tick(INTEGER sec_n) := FUNCTION
        datn := dat(get_tick(fname) IN SET(sectors.sectorticker(sector=secs[sec_n]),ticker));
        ff_secn := sent_model.getFields(datn);
        X := ff_secn.NUMF;
        Y := ff_secn.DSCF;
        mod1 := CF1.GetModel(X,Y);
        mod2 := CF2.GetModel(X,Y);
        mod3 := CF3.GetModel(X,Y);
        mod4 := CF4.GetModel(X,Y);
        preds1 := CF1.Classify(mod1,X);
        preds2 := CF2.Classify(mod2,X);
        preds3 := CF3.Classify(mod3,X);
        preds4 := CF4.Classify(mod4,X);
        
        makecon(DATASET(df) yy,DATASET(df) cr) := FUNCTION
            precon := LR.Confusion(yy,cr);
            con := LR.BinomialConfusion(precon);
            RETURN con;
        END;

        con1 := makecon(Y,preds1);
        con2 := makecon(Y,preds2);
        con3 := makecon(Y,preds3);
        con4 := makecon(Y,preds4);

        result := MODULE
            EXPORT acc1 := con1[1].accuracy;
            EXPORT acc2 := con2[1].accuracy;
            EXPORT acc3 := con3[1].accuracy;
            EXPORT acc4 := con4[1].accuracy;
        END;
        RETURN result;
    END;

    //zrds := DATASET(COUNT(secs),TRANSFORM(idrec,SELF.i:=0));
    //ctds := ITERATE(zrds,TRANSFORM(idrec,SELF.i := LEFT.i + 1));

    Tree_Param_Comparison out_T(INTEGER i) := TRANSFORM
        SELF.sector := secs[i];
        accres := sector_tick(i);
        SELF.acc100 := accres.acc1;
        SELF.acc50 := accres.acc2;
        SELF.acc25 := accres.acc3;
        SELF.acc10 := accres.acc4;
    END;

    //EXPORT comparison := PROJECT(ctds,out_T(LEFT));
    EXPORT comparison := DATASET(COUNT(secs),out_T(COUNTER));
END;