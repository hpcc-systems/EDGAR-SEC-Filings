IMPORT STD;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT TextVectors as tv;
IMPORT tv.Types;
t_Vector := Types.t_Vector;


//the sentiment setup module.
//runs prep for tfidf weighted vector calculation.
//
//PARAMETERS:
// tsents (a list of sentences with ids for which we calculate vectors)
// bigmod (a full copy of a trained TextMod)
// tfidf_score_cutoff (a threshold at which to not include entries with lower
//                     tfidf_scores. Default is 10, raise to lower compute
//                     time but decrease usefulness)
//
//INITIALIZED DATASETS:
// sp (outputs sent_prep module evaluated on docPath)
// lex (outputs sent_prep.dLexicon)
// spsent (outputs sent_prep.sentences) -- numbered training sentences format
// wmod (word vectors from input model after removing some problem tokens)
// words (lex subset down to just the field 'word')
// docus (spsent formally assigned record sentrec)
// tfidf_norm (sets up a normalized ds with all word-sentence combos, the appropriate tfidf_score, and the appropriate word vector multiplied by that tfidf_score)
// sembed_grp_experimental (contains a number of approaches to totaling the vectors in tfidf_norm)
// matrixtfidf (approaches the totaling procedure in sembed_grp_experimental by dealing with each vector entry separately, no performance improvements)
//
//INITIALIZED RECORD TYPES:
// sentrec (used to format spsent -> docus) same format as numbered training sentences
// normrec (the record format of the normalized dataset before tfidf_score calculation or attaching vectors)
// wrec (used to extend tfrec to contain w_Vector for calculating weighted vectors)
// optrec (used in an experimental final step to add up vectors without bringing along text data; text is reattached later)

EXPORT sent_setup_norm(DATASET(Types.Sentence) tsents,DATASET(Types.TextMod) bigmod,REAL8 tfidf_score_cutoff = 10.0) := MODULE
  
  EXPORT sp := sent_prep(tsents);
  EXPORT lex    := sp.dLexicon;
  EXPORT spsent := sp.sentences;

  wordmod := bigmod(typ=1);

  PATTERN num := PATTERN('[0-9]');
  PATTERN nwd := (ANY NOT IN [num])+;
  PATTERN alpha := PATTERN('[a-zA-Z]');
  PATTERN allowed := (ANY IN [alpha,' ','[\']']);
  PATTERN goodwords := alpha+;// allowed*;
  RULE numcat := goodwords;

  tv.Types.TextMod losenums_T(tv.Types.TextMod tr) := TRANSFORM
    condition := MATCHED(goodwords);
    SELF.typ := IF(condition,tr.typ,SKIP);
    SELF.id := IF(condition,tr.id,SKIP);
    SELF.text := IF(condition,tr.text,SKIP);
    SELF.vec := IF(condition,tr.vec,[SKIP]);
  END;

  EXPORT wmod := PARSE(wordmod,text,numcat,losenums_T(LEFT),WHOLE);
  SHARED veclen := COUNT(wmod[1].vec);

  EXPORT sentrec := RECORD
      UNSIGNED8 sentId := spsent.sentId;
      STRING      text := spsent.text;
  END;

  EXPORT words  := TABLE(lex,{STRING word := lex.word});
  EXPORT docus  := TABLE(sp.sentences,sentrec);

  //CREATING NORMALIZED word-sentence dataset
  EXPORT normrec := RECORD
    STRING word;
    UNSIGNED8 sentId;
    STRING text;
  END;

  EXPORT normed_ds := NORMALIZE(words,COUNT(spsent),TRANSFORM(normrec,
                                              SELF.word := LEFT.word,
                                              SELF.sentId := docus[COUNTER].sentId,
                                              SELF.text := docus[COUNTER].text));

  EXPORT wrec := RECORD
    STRING word;
    UNSIGNED8 sentId;
    STRING text;
    REAL8 tfidf_score;
    t_Vector w_Vector;
  END;

  //used in some experimental versions
  //of final vector combination steps,
  //modeled after the distributed approach
  //found in TextVectors: calcsentvector,sent2vector
  EXPORT optrec := RECORD
    UNSIGNED8 sentId;
    STRING text;
    t_Vector w_Vector;
  END;

  //Multiplying vectors by a real number
  EXPORT t_Vector vecmult(t_Vector v,REAL8 x) := BEGINC++
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
  
  EXPORT tfidf_norm := FUNCTION
    nds := normed_ds;

    //switch from opt to wrec version based
    //on whichever approach you are trying
    //for the final step; if wrec just
    //uncomment word,tfidf_score
    optrec tfscoreno0withvec_T(normrec nr) := TRANSFORM
    //wrec tfscoreno0withvec_T(normrec nr) := TRANSFORM
      tscore := sp.tfidf(STD.Str.ToLowerCase(nr.word),nr.text);
      int_ts0 := TRUNCATE(tscore/tfidf_score_cutoff);
      //SELF.word := IF(int_ts0=0,SKIP,nr.word);
      SELF.sentId := IF(int_ts0=0,SKIP,nr.sentId);
      SELF.text := IF(int_ts0=0,SKIP,nr.text);
      //SELF.tfidf_score := IF(int_ts0=0,SKIP,tscore);
      SELF.w_Vector := IF(int_ts0=0,[SKIP],vecmult(wmod(STD.Str.ToLowerCase(text)=STD.Str.ToLowerCase(nr.word))[1].vec,tscore));
    END;

    out_norm := PROJECT(nds,tfscoreno0withvec_T(LEFT));

    RETURN out_norm;
  END;

  //C++ function for adding t_Vector sets element-wise
  EXPORT t_Vector addvecs(t_Vector v1,t_Vector v2) := BEGINC++
    #body
    //size32_t N = lenV1;
    size32_t N = lenV1/sizeof(double);
    __lenResult = (size32_t) (N*sizeof(double));
    double *wout = (double *) rtlMalloc(__lenResult);
    __isAllResult = false;
    __result = (void *) wout;
    double *vv1 = (double *) v1;
    double *vv2 = (double *) v2;

    for (unsigned i = 0; i < N; i++)
    {
      wout[i] = vv1[i]+vv2[i];
    }
  ENDC++;

  EXPORT sembed_grp_experimental := FUNCTION
    svb_cpy := tfidf_norm;

    //This is the first approach: group rollup with local iterate
    // svb_ordered := SORT(svb_cpy,svb_cpy.sentId);
    // svb_grp := GROUP(svb_ordered,sentId);

    // wrec iter_vecs(wrec l,wrec r,INTEGER C) := TRANSFORM
    //   SELF.w_Vector := IF(C=1,r.w_Vector,addvecs(l.w_Vector,r.w_Vector));
    //   SELF := r;
    // END;

    // t_Vector get_tot_vec(DATASET(wrec) r) := FUNCTION
    //   itvecs := ITERATE(r,iter_vecs(LEFT,RIGHT,COUNTER),LOCAL);
    //   L_iter := COUNT(itvecs);
    //   totvec := itvecs[L_iter].w_Vector;
    //   RETURN tv.Internal.svUtils.normalizeVector(totvec);
    // END;

    // wrec grproll(wrec L,DATASET(wrec) R) := TRANSFORM
    //   SELF.word := L.word;
    //   SELF.sentId := L.sentId;
    //   SELF.text := L.text;
    //   SELF.tfidf_score := L.tfidf_score;
    //   SELF.w_Vector := get_tot_vec(R);
    // END;

    // out := ROLLUP(svb_grp,GROUP,grproll(LEFT,ROWS(LEFT)));

    //This is the second approach: project with local iterate
    // wrec exp_proj_T(INTEGER C) := TRANSFORM
    //   sentdat := svb_cpy(sentId = C);
    //   SELF.word := sentdat[1].word;
    //   SELF.sentId := C;
    //   SELF.text := sentdat[1].text;
    //   SELF.tfidf_score := sentdat[1].tfidf_score;
    //   SELF.w_Vector := get_tot_vec(sentdat);
    // END;

    // out := PROJECT(spsent,exp_proj_T(COUNTER));

    //This is the third approach: replace local iterate in any previous approach with rollup.
    //TODO: experiment with this as LOCAL rollup?
    // t_Vector roll_tot_vec(DATASET(wrec) r) := FUNCTION
    //   wrec rtv_T(wrec lr,wrec rr) := TRANSFORM
    //     SELF.w_Vector := tv.Internal.svUtils.normalizeVector(addvecs(lr.w_Vector,rr.w_Vector));
    //     SELF := rr;
    //   END;
    //   RETURN ROLLUP(r,TRUE,rtv_T(LEFT,RIGHT)).w_Vector;
    // END;

    //This is the fourth approach: call calcSentVector during
    //project across spsent. Calls in the rollsets helper script
    //to concatenate word vectors for input to calcSentVector
    // wrec optimal_T(Types.Sentence s) := TRANSFORM
    //   words_in_sent := svb_cpy(sentId=s.sentId);
    //   SELF.word := words_in_sent[1].word;
    //   SELF.sentId := s.sentId;
    //   SELF.text := s.text;
    //   SELF.tfidf_score := words_in_sent[1].tfidf_score;
    //   SELF.w_Vector := tv.Internal.svUtils.calcSentVector(rollsets(words_in_sent),veclen);//SET(words_in_sent,words_in_sent.w_Vector);
    // END;

    // out := PROJECT(spsent,optimal_T(LEFT));

    //This is the fifth approach: use the AGGREGATE
    //function to group the word vectors appropriately
    //and then aggregate on the addvecs() function
    // out := AGGREGATE(tfidf_norm,wrec,TRANSFORM(wrec,
    //                                 SELF.word := LEFT.word,
    //                                 SELF.sentId := LEFT.sentId,
    //                                 SELF.text := LEFT.text,
    //                                 SELF.tfidf_score := LEFT.tfidf_score,
    //                                 SELF.w_Vector := addvecs(LEFT.w_Vector,RIGHT.w_Vector)),
    //                                 LEFT.sentId);

    //This is the sixth approach. Follows the distributed
    //approach in TextVectors.SentenceVectors.sent2vector
    svbsortD := SORT(DISTRIBUTE(svb_cpy,sentId),sentId,LOCAL);
    optrec roll_T(optrec lw,optrec rw) := TRANSFORM
      SELF.w_Vector := lw.w_Vector + rw.w_Vector;
      SELF.sentId := lw.sentId;
      SELF.text := '';
    END;

    rollout := ROLLUP(svbsortD,roll_T(LEFT,RIGHT),sentId,LOCAL);

    sentD := DISTRIBUTE(spsent,sentId);

    out := JOIN(rollout,sentD,LEFT.sentId = RIGHT.sentId,
                  TRANSFORM(optrec,
                  SELF.w_Vector := tv.Internal.svUtils.calcSentVector(LEFT.w_Vector,veclen),
                  SELF.text := RIGHT.text,
                  SELF := LEFT),LOCAL);

    RETURN out;
  END;

  //This is the seventh approach, and while experimental
  //it appears to function identically. It attempts to
  //improve performance by separating and then repackaging
  //word vectors, while keeping track of which dimension
  //each value corresponds to (similar to NumericField)
  EXPORT matrixtfidf := FUNCTION

    svb_cpy := tfidf_norm;

    longrec := RECORD
      UNSIGNED8 sentId;
      UNSIGNED2 dim;
      REAL8 value;
    END;

    longrec long_T(INTEGER C) := TRANSFORM
      Cr := TRUNCATE(C/100);
      SELF.sentId := svb_cpy[Cr].sentId;
      SELF.dim := (UNSIGNED2) (C%100)+1;
      SELF.value := svb_cpy[Cr].w_Vector[SELF.dim];
    END;

    longform := DATASET(COUNT(tfidf_norm)*100,long_T(COUNTER));

    longD := SORT(DISTRIBUTE(longform,dim),dim,sentId,LOCAL);

    longrec longroll_T(longrec ll,longrec rl) := TRANSFORM
      SELF.sentId := ll.sentId;
      SELF.dim := ll.dim;
      SELF.value := ll.value + rl.value;
    END;

    roll_long := ROLLUP(longD,longroll_T(LEFT,RIGHT),sentId,LOCAL);

    roll_longD := SORT(DISTRIBUTE(roll_long,sentId),sentId,LOCAL);

    out := DATASET(COUNT(spsent),TRANSFORM(optrec,
                            SELF.sentId := spsent[COUNTER].sentId,
                            SELF.text := spsent[COUNTER].text,
                            SELF.w_Vector := SET(roll_longD[1+(COUNTER-1)*100..COUNTER*100],value)));

    RETURN out;

  END;
END;