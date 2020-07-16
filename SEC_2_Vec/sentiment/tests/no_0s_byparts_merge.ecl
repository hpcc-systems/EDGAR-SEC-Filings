IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
IMPORT TextVectors as tv;
IMPORT tv.Types;
IMPORT * FROM SEC_2_Vec.sentiment.tests;

#OPTION('outputLimit',1750);
#OPTION('minimizeSpillSize',TRUE);

srec := sentiment.sent_model.sveclblrec;
modrec := Types.TextMod;

sents := DATASET(WORKUNIT('W20200710-041732','Result 1'),srec);
model := DATASET(WORKUNIT('W20200710-041732','Result 2'),modrec);

tsents := PROJECT(sents,TRANSFORM(Types.Sentence,SELF.sentId := LEFT.sentId,SELF.text := LEFT.text));

ssn := sentiment.sent_setup_norm(tsents,model);

tfidfnorm := ssn.tfidf_norm;

tfrec := RECORDOF(tfidfnorm);
tfdsrec := RECORD
    DATASET(tfrec) dspart;
END;
intrec := RECORD
    INTEGER i;
END;

DATASET(tfdsrec) sep_parts(DATASET(tfrec) tfr,INTEGER size=50000) := FUNCTION
    ct := COUNT(tfr);
    N := (INTEGER) ((ct-(ct%size))/size)+1;
    tfdsrec parts_T(intrec ix) := TRANSFORM
        part := tfr[1+(ix.i-1)*size..MIN([size*ix.i,ct])];
        SELF.dspart := part(tfidf_score>0);
    END;
    count_unn := nlist.first_n(ct);
    count_off := TABLE(count_unn,{INTEGER i := count_unn.i});
    out := PROJECT(count_off,parts_T(LEFT));
    RETURN out;
END;

OUTPUT(sep_parts(tfidfnorm)[1]);