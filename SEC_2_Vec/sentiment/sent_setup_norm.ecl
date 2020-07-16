IMPORT STD;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT TextVectors as tv;
IMPORT tv.Types;
t_Vector := Types.t_Vector;


//the sentiment setup module.
//runs sentiment prep, which involves training Word2Vec on the given path location
//INITIALIZED DATASETS:
// sp (outputs sent_prep module evaluated on docPath)
// lex (outputs sent_prep.dLexicon)
// spsent (outputs sent_prep.sentences) -- numbered training sentences format
// words (lex subset down to just the field 'word')
// docus (spsent formally assigned record sentrec)
// tfidf_step1 (sets up each word in the lexicon with a table of all the training sentences)
//INITIALIZED RECORD TYPES:
// sentrec (used to format spsent -> docus) same format as numbered training sentences
// step1rec (used to format words -> tfidf_step1) each word paired with all of docus
// tfrec (used to extend docus to contain tfidf_score in tfidf_all)
// wrec (used to extend tfrec to contain w_Vector for calculating weighted vectors)
// tfidfrec (similar to step1rec, but docs field is DATASET(tfrec) rather than DATASET(docus))
// svecrec (contains a word and its vectorized embedding)

//EXPORT sent_setup_norm(STRING docPath) := MODULE
//EXPORT sent_setup_norm(STRING docPath,Types.TextMod mod) := MODULE
EXPORT sent_setup_norm(DATASET(Types.Sentence) tsents,DATASET(Types.TextMod) bigmod) := MODULE
  
  //EXPORT tmod := DATASET(mod,DATASET(Types.TextMod));

  //EXPORT sp     := sent_prep(docPath);
  EXPORT sp := sent_prep(tsents);
  EXPORT lex    := sp.dLexicon;
  EXPORT spsent := sp.sentences;

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

  //Redoing tfidf calculation for NORMALIZED form
  EXPORT tfnormrec := RECORD
    STRING word;
    UNSIGNED8 sentId;
    STRING sentence;
    REAL8 tfidf_score;
  END;

  EXPORT wrec := RECORD
    STRING word;
    UNSIGNED8 sentId;
    STRING text;
    REAL8 tfidf_score;
    t_Vector w_Vector;
  END;
  
  EXPORT tfidf_norm := FUNCTION
    nds := normed_ds;

    // tfnormrec_table := RECORD
    //   STRING word := nds.word;
    //   UNSIGNED8 sentId := nds.sentId;
    //   STRING sentence := nds.text;
    //   REAL8 tfidf_score := sp.tfidf(STD.Str.ToLowerCase(nds.word),nds.text);
    // END;

    // out_norm := TABLE(nds,tfnormrec_table);

    //experimental version that auto-collapses 0 scores
    tfnormrec_exp := RECORD
      STRING word;
      UNSIGNED8 sentId;
      STRING sentence;
      REAL8 tfidf_score;
    END;

    tfnormrec_exp tfscoreno0_T(normrec nr) := TRANSFORM
      tscore := sp.tfidf(STD.Str.ToLowerCase(nr.word),nr.text);
      int_ts0 := TRUNCATE(tscore/50.0);
      SELF.word := IF(int_ts0=0,SKIP,nr.word);
      SELF.sentId := IF(int_ts0=0,SKIP,nr.sentId);
      SELF.sentence := IF(int_ts0=0,SKIP,nr.text);
      SELF.tfidf_score := IF(int_ts0=0,SKIP,tscore);
    END;
      // drow1 := PROJECT(nr,TRANSFORM(tfnormrec_exp,SELF.word := LEFT.word,
      //                                             SELF.sentId := LEFT.sentId,
      //                                             SELF.sentence := LEFT.text,
      //                                             SELF.tfidf_score := sp.tfidf(STD.Str.ToLowerCase(LEFT.word),LEFT.text)));
      // drow2 := DATASET([],tfnormrec_exp);
      // SELF := IF(tscore!=0,drow1,drow2);
      // SELF.word := drow.word;
      // SELF.sentId := drow.sentId;
      // SELF.sentence := drow.text;
      // SELF.tfidf_score := drow.tfidf_score;
    //END;

    //out_norm_exp := PROJECT(nds,tfscoreno0_T(LEFT));

    //RETURN out_norm(tfidf_score > 0.0);

    //secondary experimental version that auto-collapses 0 scores, this time using ROLLUP syntax
    // tfidf_allsort := SORT(out_norm,sentId);
    // tfidf_sentgrp := GROUP(tfidf_allsort,sentId);
    
    // outrec := RECORDOF(out_norm);

    // weirdrec := RECORD
    //   DATASET(outrec) non0rows;
    // END;

    // weirdrec no0grps_T(outrec l,DATASET(outrec) lr) := TRANSFORM
    //   SELF.non0rows := lr(tfidf_score!=0);
    // END;

    // tfidf_no0s := ROLLUP(tfidf_sentgrp,GROUP,no0grps_T(LEFT,ROWS(LEFT)));
    
    out_norm := PROJECT(nds,tfscoreno0_T(LEFT));

    RETURN out_norm;
    //RETURN tfidf_no0s;
  END;

  //norm version of vector/tfidf join
  // FIXME: Does this need to be different from the original?
  EXPORT tf_withvecs_norm := FUNCTION
    //sv := tv.SentenceVectors();
    //mod := sv.GetModel(spsent);
    mod := bigmod;

    w2v := RECORD
      STRING word := mod.text;
      t_Vector vec:= mod.vec;
    END;

    wordvec_simp := TABLE(mod,w2v);

    wrec att_vec_T(tfnormrec tfn) := TRANSFORM
      SELF.w_Vector := wordvec_simp(STD.Str.ToLowerCase(word) = STD.Str.ToLowerCase(tfn.word))[1].vec;
      SELF.text := tfn.sentence;
      SELF := tfn;
    END;

    combo := PROJECT(tfidf_norm,att_vec_T(LEFT));

    //combo := JOIN(wordvec_simp,tfidf_norm,STD.Str.ToLowerCase(LEFT.word) = STD.Str.ToLowerCase(RIGHT.word));
    RETURN combo;
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

  //Normed version of weighting
  //All we need to do is multiply
  //each row's t_Vector by tfidf_score
  EXPORT sent_vecs_byword_norm := FUNCTION

    twn := tf_withvecs_norm;

    weightrec := RECORD
      STRING word := twn.word;
      UNSIGNED8 sentId := twn.sentId;
      STRING text := twn.text;
      REAL8 tfidf_score := twn.tfidf_score;
      t_Vector w_Vector := vecmult(twn.w_Vector,twn.tfidf_score);
    END;

    weighted := TABLE(twn,weightrec);
    RETURN weighted;
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

  EXPORT absmaxmin(t_Vector v) := FUNCTION
    vecasds := DATASET(v,{REAL8 val});
    vdsrec := RECORD
      REAL8 val;
    END;
    vdsrec absT(vdsrec vds) := TRANSFORM
      SELF.val := ABS(vds.val);
    END;
    absds := PROJECT(vecasds,absT(LEFT));
    RETURN [MAX(absds,absds.val),MIN(absds,absds.val)];
  END;

  EXPORT normalvec(t_Vector v) := FUNCTION
    vecasds := DATASET(v,{REAL8 val});
    vdsrec := RECORD
      REAL8 val;
    END;
    vdsrec squareT(vdsrec vds) := TRANSFORM
      SELF.val := vds.val * vds.val;
    END;
    allsq := PROJECT(vecasds,squareT(LEFT));
    norm := SQRT(SUM(allsq,allsq.val));
    RETURN IF(norm>0.0,vecmult(v,1.0/norm),v);
  END;

  EXPORT rescaleplain(t_Vector invec) := FUNCTION
    inds := DATASET(invec,{REAL8 val});
    inrec := RECORD
        REAL8 val;
    END;
    inrec abs_T(inrec v) := TRANSFORM
        SELF.val := ABS(v.val);
    END;
    absds := PROJECT(inds,abs_T(LEFT));
    maxab := MAX(absds,absds.val);
    RETURN IF(maxab=0.0,invec,vecmult(invec,1.0/maxab));
  END;

  EXPORT sembed_grp_experimental := FUNCTION
    svb_cpy := sent_vecs_byword_norm;
    
    //svb_no0 := svb_cpy(tfidf_score>0);
    //svb_no0 := svb_cpy(tfidf_score>0.0);
    //svb_no0 := svb_cpy(tfidf_score>0);
    //trying without removing 0s...
    svb_no0 := svb_cpy;

    svb_ordered := SORT(svb_no0,svb_no0.sentId);
    svb_grp := GROUP(svb_ordered,sentId);
    //svb_sid := DEDUP(svb_no0,sentId);

    //svbrec := RECORDOF(svb_no0);

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

    wrec grproll(wrec L,DATASET(wrec) R) := TRANSFORM
      SELF.word := L.word;
      SELF.sentId := L.sentId;
      SELF.text := L.text;
      SELF.tfidf_score := L.tfidf_score;
      SELF.w_Vector := get_tot_vec(R);
    END;

    // wrec grpproj(wrec L) := TRANSFORM
    //   SELF.word := L.word;
    //   SELF.sentId := L.sentId;
    //   SELF.text := L.text;
    //   SELF.tfidf_score := L.tfidf_score;
    //   SELF.w_Vector := get_tot_vec(svb_no0(sentId=L.sentId));
    // END;

    out := ROLLUP(svb_grp,GROUP,grproll(LEFT,ROWS(LEFT)));
    //out := PROJECT(svb_sid,grpproj(LEFT),LOCAL);

    //outrec := RECORDOF(out_tot);

    // wrec norm_T(wrec d) := TRANSFORM
    //   SELF.word := d.word;
    //   SELF.sentId := d.sentId;
    //   SELF.text := d.text;
    //   SELF.tfidf_score := d.tfidf_score;
    //   SELF.w_Vector := tv.Internal.svUtils.normalizeVector(d.w_Vector);
    // END;

    // out := PROJECT(out_tot,norm_T(LEFT));

    RETURN out;
  END;
END;