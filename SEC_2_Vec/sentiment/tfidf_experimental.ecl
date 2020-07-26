IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT TextVectors as tv;
IMPORT * FROM Types;
IMPORT ML_Core;

t_Vector := tv.Types.t_Vector;
TextMod := tv.Types.TextMod;
Sentence := tv.Types.Sentence;
wordExt := tv.Types.wordExt;
WordList := tv.Types.WordList;
SentInfo := tv.Types.SentInfo;

//EXPORT tfidf_experimental(DATASET(TextMod) mod,DATASET(Sentence) sent,UNSIGNED2 vecLen,UNSIGNED4 wordNGRAMS) := FUNCTION
EXPORT DATASET(trainrec) tfidf_experimental(DATASET(TextMod) mod,DATASET(sveclblrec) svec,UNSIGNED2 vecLen,UNSIGNED4 wordNGRAMS) := FUNCTION

    sent := PROJECT(svec,TRANSFORM(Sentence,SELF.sentId := LEFT.sentId,SELF.text := LEFT.text));

    //Multiplying vectors by a real number
    t_Vector vecmult(t_Vector v,REAL8 x) := BEGINC++
        #body
        //size32_t N = lenV;
        size32_t N = lenV/sizeof(double);
        __lenResult = (size32_t) (N * sizeof(double));
        double *wout = (double*) rtlMalloc(__lenResult);
        __isAllResult = false;
        __result = (void *) wout;
        double *vv = (double *) v;
        double xx = (double) x;
        for (unsigned i = 0; i < N; i++)
        {
          wout[i] = vv[i] * xx;
        }
    ENDC++;

    corp := tv.Internal.Corpus(wordNGrams := wordNGrams);

    wl := corp.sent2wordList(sent);

    sp := sent_prep(sent);

    tfscorerec := RECORD
        UNSIGNED8 sentId;
        STRING text;
        REAL8 tscore;
    END;

    tfscorerec getWords(WordList w,UNSIGNED c) := TRANSFORM
        SELF.sentId := w.sentId;
        SELF.text := w.words[c];
        SELF.tscore := sp.tfidf(w.words[c],sent(sentId=SELF.sentId)[1].text);
    END;

    allWords := NORMALIZE(wl,COUNT(LEFT.words),getWords(LEFT,COUNTER));
    allWordsD := DISTRIBUTE(allWords, HASH32(text));
    modD := DISTRIBUTE(mod, HASH32(text));

    sentWords0 := JOIN(allWordsD,modD,LEFT.text = RIGHT.text,TRANSFORM(SentInfo,SELF.sentId := LEFT.sentId,
                                                                                SELF.vec := vecmult(RIGHT.vec,LEFT.tscore),
                                                                                SELF := LEFT),LOCAL);

    sentWords := SORT(DISTRIBUTE(sentWords0,sentId),sentId,LOCAL);
    SentInfo doRollup(sentInfo lr, sentInfo rr) := TRANSFORM
        SELF.vec := lr.vec + rr.vec;
        SELF.sentId := lr.sentId;
        SELF.text := '';
    END;

    sentOut0 := ROLLUP(sentWords,doRollup(LEFT,RIGHT),sentId,LOCAL);

    sentD := DISTRIBUTE(sent,sentId);
    sentOut := JOIN(sentOut0,sentD,LEFT.sentId = RIGHT.sentId,TRANSFORM(RECORDOF(LEFT),
                                                                    SELF.vec := tv.Internal.svUtils.calcSentVector(LEFT.vec,vecLen),
                                                                    SELF.text := RIGHT.text,
                                                                    SELF := RIGHT), LOCAL);

    //RETURN sentOut;      
    out := JOIN(sentOut,svec,LEFT.sentId = RIGHT.sentId,TRANSFORM(trainrec,SELF.id := LEFT.sentId,SELF.text := LEFT.text,SELF.vec := LEFT.vec,SELF.label := RIGHT.label,SELF.fname := RIGHT.fname));

    RETURN out;
END;