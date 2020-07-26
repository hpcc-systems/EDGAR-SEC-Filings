IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
IMPORT TextVectors as tv;
IMPORT tv.Types;
IMPORT SEC_2_Vec.sentiment;
IMPORT * FROM sentiment;
IMPORT * FROM EDGAR_Extract.Text_Tools;

srec := sentiment.sent_model.sveclblrec;

EXPORT sector_tfidf(DATASET(srec) dat,DATASET(Types.TextMod) bigmod) := MODULE

    secs := sectors.sectorlist;

    EXPORT tfn(INTEGER n) := FUNCTION
        secn := secs[n];

        secticksn := SET(sectors.sectorticker(sector=secn),ticker);

        secdat := dat(get_tick(fname) IN secticksn);

        Types.Sentence makesents_T(srec tr) := TRANSFORM
            SELF.sentId := tr.sentId;
            SELF.text := tr.text;
        END;

        tsents := PROJECT(secdat,makesents_T(LEFT));

        RETURN tfidf_experimental(bigmod(typ=1),tsents,100,1);
    END;
END;