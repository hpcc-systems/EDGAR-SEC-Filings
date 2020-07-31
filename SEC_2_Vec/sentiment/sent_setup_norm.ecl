IMPORT STD;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT TextVectors as tv;
IMPORT * FROM Types;
IMPORT * FROM Internal.svUtils;

t_Vector := tv.Types.t_Vector;
Sentence := tv.Types.Sentence;
TextMod := tv.Types.TextMod;

//**DEPRECATED, USE TFIDF.ECL**
//
//the sentiment setup module.
//runs prep for tfidf weighted
//vector calculation.
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
// normed_ds (a normalized dataset of word-sentence pairs, including the sentence id nos.)
// tfidf_norm (sets up a normalized ds with all word-sentence combos, the appropriate tfidf_score, and the appropriate word vector multiplied by that tfidf_score)
// tfidf_norm_exp (sets up a normalized ds with all word-sentId combos, as well as the product of the appropriate tfidf score and word vector)
// sembed_grp_experimental(1-6) (contains a number of approaches to totaling the vectors in tfidf_norm)
// sembed_grp_experimental7 (approaches the totaling procedure in sembed_grp_experimental by dealing with each vector entry separately, no performance improvements)
// sembed_grp_experimental8 (calculates the tfidf vectors by treating each row in the normalized dataset as a nested record, and then acts on any two datasets)
// sembed_grp_experimental9 (calculates the same as nest_tfidf, with nested records, but starts by turning each row into a full set of the sentence vectors with 0 vectors everywhere
// but where that given row is defined)
// sembed_grp_experimental10 (uses a similar syntax as calcsentvector from TextVectors to try to convert tfidf_norm into tfidf sentence vectors)

EXPORT sent_setup_norm(DATASET(Sentence) tsents,DATASET(TextMod) bigmod,REAL8 tfidf_score_cutoff = 10.0) := MODULE
  
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

  SHARED sentrec := RECORD
      UNSIGNED8 sentId := spsent.sentId;
      STRING      text := spsent.text;
  END;

  EXPORT words  := TABLE(lex,{STRING word := lex.word});
  EXPORT docus  := TABLE(sp.sentences,sentrec);

  //CREATING NORMALIZED word-sentence dataset
  EXPORT normed_ds := NORMALIZE(words,COUNT(spsent),TRANSFORM(normrec,
                                              SELF.word := LEFT.word,
                                              SELF.sentId := docus[COUNTER].sentId,
                                              SELF.text := docus[COUNTER].text));
  
  //normalized word-sentence combinations,
  //summing word vectors on a given sentence
  //gives the tf-idf weighted sentence vector
  EXPORT tfidf_norm := FUNCTION
    nds := normed_ds;
    wrec tfscoreno0withvec_T(normrec nr) := TRANSFORM
      tscore := sp.tfidf(STD.Str.ToLowerCase(nr.word),nr.text);
      int_ts0 := TRUNCATE(tscore/tfidf_score_cutoff);
      SELF.word := IF(int_ts0=0,SKIP,nr.word);
      SELF.sentId := IF(int_ts0=0,SKIP,nr.sentId);
      SELF.text := IF(int_ts0=0,SKIP,nr.text);
      SELF.tfidf_score := IF(int_ts0=0,SKIP,tscore);
      SELF.w_Vector := IF(int_ts0=0,[SKIP],vecmult(wmod(STD.Str.ToLowerCase(text)=STD.Str.ToLowerCase(nr.word))[1].vec,tscore));
    END;
    out_norm := PROJECT(nds,tfscoreno0withvec_T(LEFT));
    RETURN out_norm;
  END;

  //used in some experimental versions
  //of final vector combination steps,
  //modeled after the distributed approach
  //found in TextVectors: calcsentvector,sent2vector
  EXPORT tfidf_norm_exp := FUNCTION
    optrec tfscoreno0(normrec nr) := TRANSFORM
      tscore := sp.tfidf(STD.Str.ToLowerCase(nr.word),nr.text);
      int_ts0 := TRUNCATE(tscore/tfidf_score_cutoff);
      SELF.sentId := IF(int_ts0=0,SKIP,nr.sentId);
      SELF.text := IF(int_ts0=0,SKIP,nr.word);
      SELF.w_Vector := IF(int_ts0=0,[SKIP],vecmult(wmod(STD.Str.ToLowerCase(text)=STD.Str.ToLowerCase(nr.word))[1].vec,tscore));
    END;
    out_norm := PROJECT(normed_ds,tfscoreno0(LEFT));
    RETURN out_norm;
  END;

  SHARED DATASET(wrec) iter_vecs(DATASET(wrec) r) := FUNCTION
    wrec i_v(wrec l,wrec r,INTEGER C) := TRANSFORM
      SELF.w_Vector := IF(C=1,r.w_Vector,addvecs(l.w_Vector,r.w_Vector));
      SELF := r;
    END;
    RETURN ITERATE(r,i_v(LEFT,RIGHT,COUNTER),LOCAL);
  END;

  SHARED t_Vector get_tot_vec(DATASET(wrec) r) := FUNCTION
    itvecs := iter_vecs(r);
    L_iter := COUNT(itvecs);
    totvec := itvecs[L_iter].w_Vector;
    RETURN tv.Internal.svUtils.normalizeVector(totvec);
  END;

  EXPORT sembed_grp_experimental1 := FUNCTION
    svb_cpy := tfidf_norm;

    //This is the first approach: group rollup with local iterate
    svb_ordered := SORT(svb_cpy,svb_cpy.sentId);
    svb_grp := GROUP(svb_ordered,sentId);

    wrec grproll(wrec L,DATASET(wrec) R) := TRANSFORM
      SELF.word := L.word;
      SELF.sentId := L.sentId;
      SELF.text := L.text;
      SELF.tfidf_score := L.tfidf_score;
      SELF.w_Vector := get_tot_vec(R);
    END;

    out := ROLLUP(svb_grp,GROUP,grproll(LEFT,ROWS(LEFT)));

    RETURN out;
  END;

  EXPORT sembed_grp_experimental2 := FUNCTION
    svb_cpy := tfidf_norm;

    //This is the second approach: project with local iterate
    wrec exp_proj_T(INTEGER C) := TRANSFORM
      sentdat := svb_cpy(sentId = C);
      SELF.word := sentdat[1].word;
      SELF.sentId := C;
      SELF.text := sentdat[1].text;
      SELF.tfidf_score := sentdat[1].tfidf_score;
      SELF.w_Vector := get_tot_vec(sentdat);
    END;

    out := PROJECT(spsent,exp_proj_T(COUNTER));
    RETURN out;
  END;

    //This is the third approach: replace local iterate in any previous approach with rollup.
    //TODO: experiment with this as LOCAL rollup?
  EXPORT sembed_grp_experimental3 := FUNCTION
    svb_cpy := tfidf_norm;

    t_Vector roll_tot_vec(DATASET(wrec) r) := FUNCTION
      wrec rtv_T(wrec lr,wrec rr) := TRANSFORM
        SELF.w_Vector := tv.Internal.svUtils.normalizeVector(addvecs(lr.w_Vector,rr.w_Vector));
        SELF := rr;
      END;
      RETURN ROLLUP(r,TRUE,rtv_T(LEFT,RIGHT)).w_Vector;
    END;

    wrec exp_roll_T(INTEGER C) := TRANSFORM
      sentdat := svb_cpy(sentId = C);
      SELF.word := sentdat[1].word;
      SELF.sentId := C;
      SELF.text := sentdat[1].text;
      SELF.tfidf_score := sentdat[1].tfidf_score;
      SELF.w_Vector := roll_tot_vec(sentdat);
    END;

    out := PROJECT(spsent,exp_roll_T(COUNTER));
    RETURN out;
  END;

  EXPORT sembed_grp_experimental4 := FUNCTION
    svb_cpy := tfidf_norm;

    //This is the fourth approach: call calcSentVector during
    //project across spsent. Calls in the rollsets helper script
    //to concatenate word vectors for input to calcSentVector
    wrec optimal_T(Sentence s) := TRANSFORM
      words_in_sent := svb_cpy(sentId=s.sentId);
      SELF.word := words_in_sent[1].word;
      SELF.sentId := s.sentId;
      SELF.text := s.text;
      SELF.tfidf_score := words_in_sent[1].tfidf_score;
      SELF.w_Vector := tv.Internal.svUtils.calcSentVector(rollsets(words_in_sent),veclen);//SET(words_in_sent,words_in_sent.w_Vector);
    END;

    out := PROJECT(spsent,optimal_T(LEFT));

    RETURN out;
  END;

  EXPORT sembed_grp_experimental5 := FUNCTION
    //This is the fifth approach: use the AGGREGATE
    //function to group the word vectors appropriately
    //and then aggregate on the addvecs() function
    out := AGGREGATE(tfidf_norm,wrec,TRANSFORM(wrec,
                                    SELF.word := LEFT.word,
                                    SELF.sentId := LEFT.sentId,
                                    SELF.text := LEFT.text,
                                    SELF.tfidf_score := LEFT.tfidf_score,
                                    SELF.w_Vector := addvecs(LEFT.w_Vector,RIGHT.w_Vector)),
                                    LEFT.sentId);

    RETURN out;
  END;

  EXPORT sembed_grp_experimental6 := FUNCTION
    svb_cpy := tfidf_norm_exp;

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
  EXPORT sembed_grp_experimental7 := FUNCTION

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

  //This is the eighth approach. In order to better distribute the problem,
  //and avoid the initial sort on sentId, we will mdoify the algorithm to
  //take in nested records rather than regular records. We therefore need a
  //nested record type
  SHARED nestrec := RECORD
    DATASET(wrec) nestrow;
  END;

  SHARED nestrec2 := RECORD
    DATASET(optrec) nestrow;
  END;

  EXPORT sembed_grp_experimental8 := FUNCTION

    nestform := PROJECT(tfidf_norm,TRANSFORM(nestrec,SELF.nestrow := ROW(LEFT,TRANSFORM(wrec,SELF := LEFT))));

    wrec iter_vecs(wrec l,wrec r,INTEGER C) := TRANSFORM
      SELF.w_Vector := IF(C=1,r.w_Vector,addvecs(l.w_Vector,r.w_Vector));
      SELF := r;
    END;

    t_Vector get_tot_vec(DATASET(wrec) r) := FUNCTION
      itvecs := ITERATE(r,iter_vecs(LEFT,RIGHT,COUNTER),LOCAL);
      L_iter := COUNT(itvecs);
      totvec := itvecs[L_iter].w_Vector;
      RETURN tv.Internal.svUtils.normalizeVector(totvec);
    END;

    nestf(nestrec nl,nestrec nr) := FUNCTION
      both := nl.nestrow + nr.nestrow;
      out := AGGREGATE(both,wrec,TRANSFORM(wrec,SELF.w_Vector := LEFT.w_Vector+RIGHT.w_Vector,SELF := LEFT),both.sentId,LOCAL);                                        
      RETURN out;
    END;

    pre := AGGREGATE(nestform[..1000],nestrec,TRANSFORM(nestrec,SELF.nestrow := nestf(LEFT,RIGHT)),
                                              TRANSFORM(nestrec,SELF.nestrow := nestf(RIGHT1,RIGHT2)))[1].nestrow;

    out := PROJECT(pre,TRANSFORM(wrec,SELF.w_Vector := tv.Internal.svUtils.calcSentVector(LEFT.w_Vector,100),SELF := LEFT));

    RETURN out;
  END;


  //this is the ninth approach. Similar to the eighth approach but instead of performing sorts each time the pairs of records are
  //combined, we start by turning each normalized row into a set of all sentences that is 'empty' or contains 0 vectors except
  //on the sentId for the corresponding row of the normalized dataset. This seems like it blows up our already huge memory even
  //larger, but hopefully the lack of sorting will provide a performance improvement.
  EXPORT sembed_grp_experimental9 := FUNCTION

    DATASET(optrec) emptyrowset(wrec tfrow) := FUNCTION
      empty := PROJECT(spsent,TRANSFORM(optrec,SELF.w_Vector:=IF(LEFT.sentId=tfrow.sentId,tfrow.w_Vector,vecmult(tfrow.w_Vector,0.0)),SELF := LEFT));
      RETURN empty;
    END;

    DATASET(optrec) addrowsets(DATASET(optrec) lr,DATASET(optrec) rr) := FUNCTION
      out := PROJECT(lr,TRANSFORM(optrec,SELF.w_Vector := addvecs(LEFT.w_Vector,rr(sentId=LEFT.sentId)[1].w_Vector),SELF := LEFT));
      RETURN out;
    END;

    empties := PROJECT(tfidf_norm,TRANSFORM(nestrec2,SELF.nestrow := emptyrowset(LEFT)));

    out := AGGREGATE(empties,nestrec2,TRANSFORM(nestrec2,SELF.nestrow := addrowsets(LEFT.nestrow,RIGHT.nestrow)),TRANSFORM(nestrec2,SELF.nestrow := addrowsets(RIGHT1.nestrow,RIGHT2.nestrow)))[1];
    RETURN out;
  END;

  EXPORT sembed_grp_experimental10 := FUNCTION
    sentWords := SORT(DISTRIBUTE(tfidf_norm_exp,sentId),sentId,LOCAL);
    optrec doRollup(optrec lr,optrec rr) := TRANSFORM
      SELF.w_Vector := lr.w_Vector + rr.w_Vector;
      SELF.sentId := lr.sentId;
      SELF.text := '';
    END;

    sentOut0 := ROLLUP(sentWords,doRollup(LEFT,RIGHT),sentId,LOCAL);

    sentD := DISTRIBUTE(spsent,sentId);
    
    sentOut := JOIN(sentOut0,sentD,LEFT.sentId = RIGHT.sentId, TRANSFORM(RECORDOF(LEFT),
                                                                          SELF.w_Vector := tv.Internal.svUtils.calcSentVector(LEFT.w_Vector,vecLen),
                                                                          SELF.text := RIGHT.text,
                                                                          SELF := RIGHT), LOCAL);
    RETURN sentOut;
  END;
END;