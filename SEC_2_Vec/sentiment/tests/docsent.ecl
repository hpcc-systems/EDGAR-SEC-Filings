IMPORT ML_Core;
IMPORT ML_Core.Types;
IMPORT SEC_2_Vec.sentiment.sent_model;

//This function outputs a NumericField
//for predicting overall doc sentiment
//from sentence classifications
//It also returns the 'true' labels

EXPORT docsent(DATASET(Types.DiscreteField) preds,DATASET(sent_model.trainrec) lbldata) := MODULE

    SHARED midrec := RECORD(Types.DiscreteField)
        STRING fname;
    END;
    
    midrec att_fnames_T(Types.DiscreteField p) := TRANSFORM
        SELF.fname := lbldata(id=p.id)[1].fname;
        SELF := p;
    END;

    withnames := PROJECT(preds,att_fnames_T(LEFT));

    sortnames := SORT(withnames,fname);
    SHARED groupname := GROUP(sortnames,fname);

    EXPORT DATASET(Types.NumericField) docavg := FUNCTION
        Types.NumericField rollout_T(midrec l,DATASET(midrec) ls) := TRANSFORM
            SELF.value := AVE(ls,ls.value);
            SELF.id := MIN(SORT(ls,id),ls.id);
            SELF := l;
        END;

        out_nums := ROLLUP(groupname,GROUP,rollout_T(LEFT,ROWS(LEFT)));
        RETURN out_nums;
    END;
    
    EXPORT DATASET(Types.DiscreteField) labtru := FUNCTION
        Types.DiscreteField rolllab_T(midrec l,DATASET(midrec) ls) := TRANSFORM
            SELF.wi := 1;
            SELF.id := MIN(SORT(ls,id),ls.id);
            SELF.number := 1;
            SELF.value := l.value;
        END;

        out_labs := ROLLUP(groupname,GROUP,rolllab_T(LEFT,ROWS(LEFT)));
        RETURN out_labs;
    END;
END;