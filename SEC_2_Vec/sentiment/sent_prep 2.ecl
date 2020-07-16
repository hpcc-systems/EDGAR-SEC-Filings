IMPORT STD;
IMPORT tokenutils as tu;
IMPORT * FROM TextVectors;
IMPORT * FROM SEC_2_Vec;
TextMod := Types.TextMod;

//EXPORT sent_prep(STRING docPath) := MODULE
EXPORT sent_prep(DATASET(Types.Sentence) tsents) := MODULE
//   EXPORT sentences := secvec_input(docPath);

//   EXPORT sents := TABLE(sentences,{STRING text := sentences.text});

//   EXPORT dSentences := TABLE(sentences,{UNSIGNED id := sentences.sentId,STRING txt := sentences.text});
  
//   EXPORT dSequenced := ML.Docs.Tokenize.Enumerate(dSentences);

//   EXPORT dCleaned := ML.Docs.Tokenize.Clean(dSentences);

//   EXPORT dSplit := ML.Docs.Tokenize.Split(dCleaned);

//   EXPORT dLexicon := ML.Docs.Tokenize.Lexicon(dSplit);

//   EXPORT n := COUNT(dSentences);


//   //FIXME: are we counting through sentences too many times?
//   EXPORT tf(STRING term,STRING document) := FUNCTION
//     REAL8 tf_indoc := STD.Str.CountWords(document,term,TRUE)-1;
//     RETURN tf_indoc;
//   END;

//   EXPORT df(STRING term) := FUNCTION
//     df_val := dLexicon(word = STD.Str.ToUpperCase(term))[1].total_docs;
//     RETURN df_val;
//   END;

//   EXPORT idf(STRING term) := FUNCTION
//     REAL8 idf_term := log(n/df(term)) + 1;
//     RETURN idf_term;
//   END;

//   EXPORT tfidf(STRING term,STRING document) := FUNCTION
//     REAL8 tf_idf := tf(term,document) * idf(term);
//     RETURN tf_idf;
//   END;
// END;
//EXPORT sent_prep(TextVectors.Types.Sentence sentences) := MODULE
  
  //EXPORT sentences := secvec_input(docPath);
  EXPORT sentences := tsents;

  EXPORT sents := TABLE(sentences,{STRING text := sentences.text});

  EXPORT dSentences := TABLE(sentences,{UNSIGNED id := sentences.sentId,STRING txt := sentences.text});
  
  EXPORT dSequenced := tu.Tokenize.Enumerate(dSentences);

  EXPORT dCleaned := tu.Tokenize.Clean(dSentences);

  EXPORT dSplit := tu.Tokenize.Split(dCleaned);

  EXPORT dLexicon := tu.Tokenize.Lexicon(dSplit);

  EXPORT n := COUNT(dSentences);


  //FIXME: are we counting through sentences too many times?
  EXPORT tf(STRING term,STRING document) := FUNCTION
    REAL8 tf_indoc := STD.Str.CountWords(document,term,TRUE)-1;
    RETURN tf_indoc;
  END;

  EXPORT df(STRING term) := FUNCTION
    df_val := dLexicon(word = STD.Str.ToUpperCase(term))[1].total_docs;
    RETURN df_val;
  END;

  EXPORT idf(STRING term) := FUNCTION
    REAL8 idf_term := log(n/df(term)) + 1;
    RETURN idf_term;
  END;

  EXPORT tfidf(STRING term,STRING document) := FUNCTION
    REAL8 tf_idf := tf(term,document) * idf(term);
    RETURN tf_idf;
  END;
END;