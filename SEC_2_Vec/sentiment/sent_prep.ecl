IMPORT STD;
IMPORT Internal.tokenutils as tu;
IMPORT * FROM TextVectors;
IMPORT * FROM SEC_2_Vec;
TextMod := Types.TextMod;

//Used to prepare for tfidf calculations
//PARAMETERS:
//
// tsents (a list of sentences, the training corpus)
//
//INITIALIZED DATASETS:
//
// sentences (the input tsents)
// sents (just the sentences without the id nos.)
// dSentences (the input tsents with a different recordtype)
// dCleaned (dSentences, with cleaning rules applied to sentences)
// dSplit (dCleaned prepared for token counting)
// dLexicon (dSplit converted into a lexicon of tokens being used)
// n (number of sentences being used)
// tf() (term frequency is the incidence of a given term in a given document)
// df() (document frequency is the number of sentences a given term appears in)
// idf() (inverse document frequency is a calculation used to quantify the
// incidence of the term across the corpus)
// tfidf() (tf-idf score quantifies the relevance of the given term in the given
// sentence based on that term's overall frequency across all sentences and within
// the given sentence)
EXPORT sent_prep(DATASET(Types.Sentence) tsents) := MODULE

  EXPORT sentences := tsents;

  EXPORT sents := TABLE(sentences,{STRING text := sentences.text});

  EXPORT dSentences := TABLE(sentences,{UNSIGNED id := sentences.sentId,STRING txt := sentences.text});

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