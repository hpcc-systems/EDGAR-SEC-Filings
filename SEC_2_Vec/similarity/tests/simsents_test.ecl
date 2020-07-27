IMPORT STD;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM SEC_2_Vec.similarity;
IMPORT TextVectors as tv;
IMPORT * FROM tv.internal.svUtils;
IMPORT * FROM Types;

tmod := tv.types.textmod;
tvec := tv.types.t_Vector;

sentrec := RECORD
    UNSIGNED8 sentId;
    STRING text;
    STRING label;
    STRING fname;
END;

sen := DATASET(WORKUNIT('W20200704-032755','Result 1'),sentrec);
mod := DATASET(WORKUNIT('W20200704-032755','rawsents_model'),tmod);

modsents := mod(typ=2);
sampsent_raw := JOIN(sen,modsents,LEFT.sentId = RIGHT.id);
ssrec := RECORD
    UNSIGNED8 sentId := sampsent_raw.sentId;
    STRING text := sampsent_raw.text;
    STRING label := sampsent_raw.label;
    STRING fname := sampsent_raw.fname;
    UNSIGNED1 typ := sampsent_raw.typ;
    UNSIGNED8 id := sampsent_raw.id;
    tvec vec := sampsent_raw.vec;
END;

sampsent := TABLE(sampsent_raw,ssrec);

tickrec := RECORD
    STRING tick;
END;

get_tick(STRING f) := FUNCTION
    parts := STD.Str.SplitWords(f,'_',FALSE);
    RETURN parts[1];
END;

tickrec tick_T(ssrec s) := TRANSFORM
    SELF.tick := get_tick(s.fname);
END;

tickonly := PROJECT(sampsent,tick_T(LEFT));

tick_sort := SORT(tickonly,tick);
ticks := DEDUP(tick_sort,tick);

tick1 := ticks[1].tick;
tick2 := ticks[2].tick;

get_doc(DATASET(ssrec) s,INTEGER C) := FUNCTION
    fnsonly := RECORD
        STRING fname := s.fname;
    END;

    fnonly:= TABLE(s,fnsonly);
    fn_sort  := SORT(fnonly,fname);
    fns := DEDUP(fn_sort,fname);

    RETURN s(fname=fns[C].fname);
END;


get_two_docs(DATASET(ssrec) s,STRING t1,STRING t2,INTEGER C1,INTEGER C2) := FUNCTION
    comp1sents := s(get_tick(fname)=t1);
    comp2sents := s(get_tick(fname)=t2);

    result := MODULE
        EXPORT res1 := get_doc(comp1sents,C1);
        EXPORT res2 := get_doc(comp2sents,C2);
    END;

    RETURN result;
END;

simrec := RECORD
    STRING sent1;
    STRING sent2;
    REAL8 cossim;
END;

simrec sentsentcomp(DATASET(ssrec) s,STRING t1,STRING t2,INTEGER C1,INTEGER C2) := FUNCTION

    docs := get_two_docs(s,t1,t2,C1,C2);
    doc1sent := docs.res1;
    doc2sent := docs.res2;

    simrec sentsent_T(ssrec s1,ssrec s2) := TRANSFORM
        SELF.sent1 := s1.text;
        SELF.sent2 := s2.text;
        SELF.cossim:= POWER(cosineSim(s1.vec,s2.vec,100),2.0);
    END;

    //sentcomp := JOIN(doc1sent,doc2sent,LEFT.id = RIGHT.id,sentsent_T(LEFT,RIGHT));
    sentcomp := JOIN(doc1sent,doc2sent,TRUE,sentsent_T(LEFT,RIGHT),ALL);

    RETURN sentcomp;
END;

out := sentsentcomp(sampsent,tick1,tick1,1,2);

OUTPUT(out);