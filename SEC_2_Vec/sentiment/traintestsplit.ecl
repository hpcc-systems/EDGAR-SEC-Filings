IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT sectors from SEC_2_Vec.sentiment;

EXPORT traintestsplit(DATASET(sent_model.trainrec) d,STRING split_on = 'filename',INTEGER split_n = 2) := FUNCTION

    //we could perform our train test split on
    //'sentId', 'filename', or 'ticker'. For now we
    //assume we will not be interested in any
    //other split types

    sentid_out_trn := d(id % split_n != 0);
    sentid_out_tst := d(id % split_n = 0);
    
    fnames := SET(DEDUP(d,fname),fname);
    cnt_f := TRUNCATE(COUNT(fnames)/2);
    fname_out_trn := d(fname NOT IN fnames[..cnt_f]);
    fname_out_tst := d(fname IN fnames[cnt_f+1..]);

    dedup_d := DEDUP(d,fname);
    tickrec := RECORD
        STRING ticker;
    END;
    tickrec tick_T(sent_model.trainrec tr) := TRANSFORM
        SELF.ticker := get_tick(tr.fname);
    END;
    ticks := SET(DEDUP(PROJECT(dedup_d,tick_T(LEFT)),ticker),ticker);
    cnt_t := TRUNCATE(COUNT(ticks)/2);
    ticks_out_trn := d(get_tick(fname) NOT IN ticks[..cnt_t]);
    ticks_out_tst := d(get_tick(fname) IN ticks[cnt_t+1..]);

    traindat := CASE(split_on,
        'sentId' => sentid_out_trn,
        'filename' => fname_out_trn,
        'ticker' => ticks_out_trn);
    
    testdat := CASE(split_on,
        'sentId' => sentid_out_tst,
        'filename' => fname_out_tst,
        'ticker' => ticks_out_tst);
    
    result := MODULE
        EXPORT trn := traindat;
        EXPORT tst := testdat;
    END;
    RETURN result;
END;