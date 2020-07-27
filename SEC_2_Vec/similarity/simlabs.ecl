IMPORT STD;
IMPORT SEC_2_Vec;
IMPORT ML_Core;
IMPORT ML_Core.Types as mlTypes;
IMPORT * FROM SEC_2_Vec;
IMPORT similarity from SEC_2_Vec;
IMPORT Types as secTypes;
IMPORT * from secTypes;

nf := mlTypes.NumericField;
df := mlTypes.DiscreteField;
docsim := similarity.docsim;

EXPORT simlabs(DATASET(trainrec) traindat,STRING method='add') := MODULE
    EXPORT get_ticker(STRING f) := FUNCTION
        parts := STD.Str.SplitWords(f,'_',FALSE);
        tick := parts[1];
        RETURN tick;
    END;

    EXPORT tickrec := RECORD
        STRING fname;
        STRING ticker;
    END;

    EXPORT fname_bytick := FUNCTION
        helpertickrec := RECORD
            STRING fname  := traindat.fname;
            STRING ticker := get_ticker(traindat.fname);
        END;

        tickds := TABLE(traindat,helpertickrec);

        ticksdedup := DEDUP(SORT(tickds,tickds.ticker),tickds.ticker);
        fnames := DEDUP(SORT(tickds,tickds.fname),tickds.fname);
        ticks := SET(ticksdedup,ticksdedup.ticker);
        RETURN fnames;
    END;

    EXPORT comprec := RECORD
        INTEGER sid;
        STRING fname;
        STRING ticker;
        REAL8 similarity;
    END;

    EXPORT dat_from_name(STRING fn) := FUNCTION
        RETURN traindat(fname=fn);
    END;

    EXPORT comprec simsentcomp := FUNCTION

        comprec addsimfield_T(tickrec t) := TRANSFORM
            SELF.sid := 0;
            SELF.fname := t.fname;
            SELF.ticker := t.ticker;
            SELF.similarity := -1.0;
        END;

        starter := PROJECT(fname_bytick,addsimfield_T(LEFT));

        // comprec comproll_T(comprec sl,comprec sr,INTEGER C) := TRANSFORM
        //     SELF.fname := RIGHT.fname;

        // END;

        comprec successive_sim_T(comprec l,comprec r) := TRANSFORM
            SELF.sid := L.sid + 1;
            SELF.fname := r.fname;
            SELF.ticker := r.ticker;
            SELF.similarity := IF(l.ticker = r.ticker,docsim(dat_from_name(l.fname),dat_from_name(r.fname),method),r.similarity);
        END;

        out := ITERATE(starter,successive_sim_T(LEFT,RIGHT),LOCAL);
        RETURN out;
    END;


    //for each tick, act on records
    //get similarity scores for consecutive filings
    //result should be sentiment labels paired with similarity labels

    EXPORT grablabel(STRING fname) := FUNCTION
        parts := STD.Str.SplitWords(fname,'_',FALSE);
        labelxml := parts[4];
        parts2 := STD.Str.SplitWords(labelxml,'.',FALSE);
        label := parts2[1];
        RETURN label;
    END;

    EXPORT simlabelrec := RECORD
        INTEGER sid;
        STRING fname;
        REAL8 similarity;
        STRING label
    END;

    EXPORT sim_and_labels := FUNCTION
        ssc := simsentcomp;

        simlabelrec simlabel_T(comprec cr) := TRANSFORM
            SELF.sid := cr.sid;
            SELF.fname := cr.fname;
            SELF.similarity := cr.similarity;
            SELF.label := grablabel(cr.fname);
        END;    

        out := PROJECT(ssc,simlabel_T(LEFT));

        RETURN out;    
    END;

    EXPORT getFields := FUNCTION
        sal := sim_and_labels;
        ind := PROJECT(sal,TRANSFORM(nf,SELF.wi := 1,
                                        SELF.id := LEFT.sid,
                                        SELF.number := 1,
                                        SELF.value := LEFT.similarity));
        dep := PROJECT(sal,TRANSFORM(df,SELF.wi := 1,
                                        SELF.id := LEFT.sid,
                                        SELF.number := 1,
                                        SELF.value := (INTEGER4) LEFT.label));

        result := MODULE
            EXPORT x := ind;
            EXPORT y := dep;
        END;
        RETURN result;
    END;
END;