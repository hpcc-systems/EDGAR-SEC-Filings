IMPORT ML_Core;
IMPORT SEC_2_Vec.sentiment.sent_model;
IMPORT * FROM Types;

//This function outputs a NumericField
//for predicting overall doc sentiment
//from sentence classifications
//It also returns the 'true' labels
//
//PARAMETERS:
// preds (a DiscreteField dataset of the
// predicted sentence classifications)
// lbldata (a trainrec dataset of the
// sentence vectors being predicted on)
//
//INITIALIZED DATASETS:
// docavg (a NumericField dataset of
// averaged predictions from preds,
// one value per document)
// labtru (a DiscreteField dataset of
// the expected 'true' labels for
// each document)

nf := ML_Core.Types.NumericField;
df := ML_Core.Types.DiscreteField;

EXPORT docsent(DATASET(df) preds,DATASET(trainrec) lbldata) := MODULE

    SHARED midrec := RECORD(df)
        STRING fname;
    END;
    
    midrec att_fnames_T(df p) := TRANSFORM
        SELF.fname := lbldata(id=p.id)[1].fname;
        SELF := p;
    END;

    withnames := PROJECT(preds,att_fnames_T(LEFT));

    sortnames := SORT(withnames,fname);
    SHARED groupname := GROUP(sortnames,fname);

    EXPORT DATASET(nf) docavg := FUNCTION
        nf rollout_T(midrec l,DATASET(midrec) ls) := TRANSFORM
            SELF.value := AVE(ls,ls.value);
            SELF.id := MIN(SORT(ls,id),ls.id);
            SELF := l;
        END;

        out_nums := ROLLUP(groupname,GROUP,rollout_T(LEFT,ROWS(LEFT)));
        RETURN out_nums;
    END;
    
    EXPORT DATASET(df) labtru := FUNCTION
        df rolllab_T(midrec l,DATASET(midrec) ls) := TRANSFORM
            SELF.wi := 1;
            SELF.id := MIN(SORT(ls,id),ls.id);
            SELF.number := 1;
            SELF.value := l.value;
        END;

        out_labs := ROLLUP(groupname,GROUP,rolllab_T(LEFT,ROWS(LEFT)));
        RETURN out_labs;
    END;
END;