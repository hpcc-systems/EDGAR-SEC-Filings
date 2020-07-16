/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2017 HPCC Systems.  All rights reserved.
############################################################################## */
IMPORT TextVectors.Types;
IMPORT TextVectors.internal as int;
IMPORT Std.Str;
IMPORT Std.system.Thorlib;
IMPORT int.svUtils AS Utils;
IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;

t_TextId := Types.t_TextId;
t_Sentence := Types.t_Sentence;
t_Vector := Types.t_Vector;
t_Word := Types.t_Word;
t_WordId := Types.t_WordId;
t_SentId := Types.t_SentId;
TextMod := Types.TextMod;
Vector := Types.Vector;
Word := Types.Word;
WordInfo := Types.WordInfo;
WordList := Types.WordList;
Sentence := Types.Sentence;
SentInfo := Types.SentInfo;
SliceExt := Types.SliceExt;
TrainStats := Types.TrainStats;
t_ModRecType := Types.t_ModRecType;
Closest := Types.Closest;
WordExt := Types.WordExt;

mappingRec := RECORD
  t_Word orig;
  t_Word new;
END;

node := Thorlib.node();
nNodes := Thorlib.nodes();

/**
  * Module to learn and manipulate sentence and word vectors.  <p>It implements the Sent2Vec algorithm
  * from "Unsupervised Learning of Sentence Embeddings using Compositional n-Gram Features" by
  * Matteo Pagliardini, Prakhar Gupta and Martin Jaggi (https://arxiv.org/abs/1703.02507)
  *
  * <p>Text vectors reduce words, paragraphs, sentences or phrases to a vector of numbers that are best
  * thought of as coordinates in N-dimensional space.  A typical vector size of 100 provides coordinates
  * in 100 dimensional space.  Vectorization takes advantage of a linguistic theory that says that "a
  * word is known by the company it keeps".  This suggests that words that tend to occur in the same
  * context (i.e. with the same surrounding words) have a similar meaning.  This is known as "contextual
  * meaning", which is very difficult to distinguish from our inherent understanding of "meaning".
  * Assuming we have a large Corpus (i.e. the set of all the text in our domain -- e.g. All of wikipedia,
  * all medical journals), "contextual meaning" and "meaning" are nearly synonymous. Consider two words
  * that are always found in the exact same context: It would be surprising if those two words were
  * not very closely related since there is, in effect, nothing that can be (or at least has been) said
  * of one that can't be (hasn't been) said about the other.
  * <p>Vectors that are close together (in N dimensional space) will have similar contextual meaning.
  * Thus, synonyms can be readily found for words, and sentences can be identified as similar, even when
  * they use very different wording.
  * 
  * <p>Sentence Vectors is a very fast mechanism (compared to other mechanisms) for learning high-quality
  * vectors for both words and sentences.  Sentences are vectorized by taking the average vector for
  * all of the words in the sentence.  Word and Sentence Vectors can be used in a number of ways:
  * - They form low-dimensional representations that can be used as input features to supervised
  *   machine learning
  *   tasks (e.g. to categorize the meaning of a sentence).  The attributes GetWordVectors() and
  *   GetSentVectors() can be used to extract the learned vectors.
  * - Words can be analyzed for similarity of meaning by utilizing ClosestWords() or by retrieving the
  *   vectors and calling Similarity().
  * - A sentence not in the training set can be compared to sentences in the training set using
  *   ClosestSentences() or by retrieving the vectors and calling Similarity().
  * - Word analogies of the form A is to B as C is to ? can be solved by calling WordAnalogy().
  * - Collections of words can be analyzed to find outliers using FindLeastSimilar().
  * <p>Sentence Vectors can be configured to incorporate word order and multi-word concepts using
  * the wordNGrams feature.  When set to one, only individual words are considered, while when set
  * to 3, one, two, and three word phrases are all considered words.  In this way a phrase like
  * "traffic light" can have a very different meaning than either "traffic" or "light", and can also
  * have a very different meaning from "light traffic".  "New York Times" can have a different meaning
  * than "new", "york" or "times", as well as a different meaning than "New York" or "York Times".
  * With wordNGrams set to 1, compound words as well as word order cannot be distinguished.  This can
  * be useful for corpora that contain very terse cryptic sentences which may be equally valid in any
  * order, and without compound word usage.
  *
  * <p>Sentence Vectors are trained using a specialized Neural Network that is task-optimized.  Batch
  * Synchronous Stochastic Gradient Descent is used to parallelize the neural network training across
  * the HPCC Cluster.
  *
  * @param vecLen The length in bytes of the sentence and word vectors to be learned (default 100).
  * @param trainToLoss Stop training when the average Loss level reaches this level.
  *        This is the recommended method of controlling training duration. The Default .05
  *        (i.e. 5 percent loss) seems to give
  *        good results.
  * @param numEpochs The maximum number of times to loop through the full set of training data. Each
  *                  pass through the training data is known as an Epoch.  Default 0 (recommended)
  *                  means no fixed number of epochs.  Will use trainToLoss and noProgressEpochs
  *                  to terminate.
  *                  Note that the larger the corpus, the lower this
  *                  value can become.  For an extremely large corpus, a single Epoch may be
  *                  enough.
  * @param batchSize The number of word pairs to process before synchronizing weights across
  *                   the nodes during Stochastic Gradient Descent (SGD) (Default 0 -- auto assign --
  *                   recommended).  Note that
  *                   larger values imply longer periods between synchronization of weights across
  *                   nodes.  Larger values also speed up the training as less time is spent
  *                   synchronizing.  If the network fails to converge, this may be set too high.
  * @param negSamples The number of random negative samples to generate for each positive sample
  *                    (default 10).  This may be reduced to as little as 2 for an extremely large
  *                    corpus.
  * @param learningRate The rate at which the neural network learns (default .1).
  * @param discardThreshold The threshold of word frequency below which each occurrence of the word
  *                         will be trained on.  For frequencies above this level, the word will be
  *                         stochastically discarded to reduce over-training of common words and to
  *                         speed up training (default .0001).
  * @param minOccurs Words that occur below this number of times in the corpus will be ignored
  *                   (default 10).  Rare words with few occurrences in the corpus generally add
  *                   little to the accuracy and can significantly extend training time.
  * @param wordNGrams The maximum size NGrams to consider.  For example, 3 would cause all
  *                     Unigrams, Bigrams, and Trigrams to be used (Default 1 -- Unigrams only).
  * @param dropoutK The number of NGrams to randomly drop from a sentence (per Sent2Vec paper).  Default 3.
  * @param noProgressEpochs Controls early stopping of training.  Determines how many Epochs can go
  *                     by without progress before training is terminated.  There is generally no
  *                     advantage to continue training once we fail to make progress on each epoch,
  *                     since accuracy does not typically go up with overtraining.
  * @param maxTextDistance This implementation provides an advanced feature that handles comparison
  *                     sentences with words that were not found in the trained vocabulary.  The
  *                     system attempts to match previously unseen words to words in the vocabulary
  *                     using edit distance.  The goal is to handle typos, misspellings, and
  *                     initialisms (e.g. 'dog' vs 'dogs').  Edit distance allows for character
  *                     level inserts, removals, or replacements.  If this number is too high,
  *                     unrelated words may be matched.  If too low, typos may not be mapped
  *                     (Default 3).  Zero implies no edit distance matching, in which case
  *                     unseen words will be ignored.
  * @param maxNumDistance If a number was seen that was not in the vocabulary, the system will
  *                     attempt a numeric match rather than an edit distance match.  The numbers
  *                     10 and 100 have an edit distance of only 1 (i.e. add a zero), yet the
  *                     meaning can be vastly different.  For numeric words, we use the actual
  *                     numeric distance instead of edit distance.  For example, if this parameter
  *                     is set to 9, then 43 will match to 50 if it is the closest number.
  *                     A value of zero disables numeric matching (Default 9).
  * @param saveSentences Set to TRUE to save the training sentences in the model. It should always
  *                        be set to TRUE if you plan to call GetClosestSentences(...).  Setting
  *                        to FALSE will result in a smaller model with only the word vectors
  *                        (default TRUE).
  */
EXPORT SentenceVectors_modified(UNSIGNED2 vecLen=100,
                      REAL trainToLoss = .05,
                      UNSIGNED4 numEpochs= 0,
                      UNSIGNED4 batchSize=0,
                      UNSIGNED4 negSamples=10,
                      REAL4 learningRate=.1,
                      REAL4 discardThreshold = .0001,
                      UNSIGNED4 minOccurs = 10,
                      UNSIGNED4 wordNGrams = 1,
                      UNSIGNED4 dropoutK = 3,
                      UNSIGNED4 noProgressEpochs = 1,
                      UNSIGNED4 maxTextDistance = 3,
                      UNSIGNED4 maxNumDistance = 9,
                      BOOLEAN saveSentences=TRUE) := MODULE
  // Calibration constant (heuristic) for adjusting batch size
  SHARED calConst := 25;
  /**
    * Extract the word vectors from the trained weights
    */
  SHARED computeWordVectors(DATASET(SliceExt) slices, DATASET(WordInfo) words,
																SET OF UNSIGNED shape) := FUNCTION
    w := Weights_modified(shape);  // Module to manage weights
    // As an optimization, we only convert half of the weight slices
    // since the word vectors are always in the first half
    firstHalf := ROUNDUP(w.nSlices / 2);
    allWeights := w.slices2Linear(slices(sliceId <= firstHalf ));
    // Extract the vectors for each word.  Words should be evenly distributed at this point.
    WordInfo getVectors(WordInfo wrd) := TRANSFORM
      // The weights that form the word vector are the layer 1 weights.  j is the wordId
      // and i is the term number of the word vector.  The terms of the word vector are
      // contiguous, so we only need to know the start and end indexes.
      startIndx := w.toFlatIndex(1, wrd.wordId, 1);
      endIndx := startIndx + shape[2] - 1;
      SELF.vec := Utils.normalizeVector(allWeights.weights[startIndx .. endIndx]);
      SELF := wrd;
    END;
    wordsWithVecs := PROJECT(words, getVectors(LEFT), LOCAL);
    RETURN wordsWithVecs;
  END;
  // This function is an alternative to computeWordVectors above.  I need to compare the two
  // to see which one performs better -- TODO*
  SHARED computeWordVectorsNew(DATASET(SliceExt) slices, DATASET(WordInfo) words,
																	SET OF UNSIGNED shape) := FUNCTION
    w := Weights_modified(shape);  // Module to manage weights
    // Extract the vectors for each word.  Words should be evenly distributed at this point.
    WordInfo getVectors(WordInfo wi) := TRANSFORM
      // The weights that form the word vector are the layer 1 weights.  j is the wordId
      // and i is the term number of the word vector.  The terms of the word vector are
      // contiguous, so we only need to know the start and end indexes.
      startIndx := w.toFlatIndex(1, wi.wordId, 1);
      endIndx := startIndx + shape[2] - 1;
      // The weights might span slices.
      startSlice := (startIndx - 1) DIV w.sliceSize + 1;
      endSlice := (endIndx - 1) DIV w.sliceSize + 1;
      // Get the start and end positions within the slice.
      locStart := (startIndx-1) % w.sliceSize + 1;
      locEnd := (endIndx - 1) % w.sliceSize + 1;
      // If the start slice is the same as the end slice, extract the weights from
      // that slice.  If different, concatenate the weights from the end of the start
      // slice and the beginning of the end slice.
      locSlices := slices(nodeId = node);
      slice1 := locSlices(sliceId = startSlice)[1].weights[locStart .. locEnd];
      slice2 := locSlices(sliceId = startSlice)[1].weights[locStart ..] + 
                locSlices(sliceId = endSlice)[1].weights[.. locEnd];
      vecWeights := IF(startSlice = endSlice, slice1, slice2);
      // Normalize the weights to get the word vector
      SELF.vec := Utils.normalizeVector(vecWeights);
      SELF := wi;
    END;
    wordsWithVecs := PROJECT(words, getVectors(LEFT), LOCAL);
    RETURN wordsWithVecs;
  END;
  /**
    * Convert the vectorized vocabulary into the word portion of the model.
    */
  SHARED DATASET(TextMod) makeWordModel(DATASET(WordInfo) words) := FUNCTION
    modOut := PROJECT(words, TRANSFORM(TextMod, SELF.typ := Types.t_ModRecType.Word,
                          SELF.id := LEFT.wordId, SELF := LEFT), LOCAL);
    RETURN modOut;
  END;
  /**
    * Convert the set of vectorized sentences into the sentence portion of the model.
    */
  SHARED DATASET(TextMod) makeSentModel(DATASET(SentInfo) sent) := FUNCTION
    modOut := PROJECT(sent, TRANSFORM(TextMod, SELF.typ := Types.t_ModRecType.Sentence,
                          SELF.id := LEFT.sentId, SELF := LEFT), LOCAL);
    RETURN modOut;
  END;
  /**
    * Try to find the closest match between an input set of words and words that are in the
    * vocabulary using Edit Distance and Numeric Distance.
    */ 
  SHARED DATASET(mappingRec) findClosestMatch(DATASET(TextMod) mod, DATASET(mappingRec) words) := FUNCTION
    distRec := RECORD(mappingRec)
      UNSIGNED4 eDist;
    END;
    wordsN := words(Utils.isNumeric(orig));
    wordsT := words(Utils.isNumeric(orig)=FALSE);
    d0T := JOIN(wordsT, mod(Utils.isNumeric(text)=FALSE), TRUE,
                      TRANSFORM(distRec, SELF.eDist := Str.EditDistance(LEFT.orig, RIGHT.text),
                      SELF.new := RIGHT.text, SELF := LEFT), ALL);
    d0N := JOIN(wordsN, mod(Utils.isNumeric(text)), TRUE,
                      TRANSFORM(distRec, SELF.eDist := Utils.numDistance(LEFT.orig, RIGHT.text),
                      SELF.new := RIGHT.text, SELF := LEFT), ALL);
    d0TF := d0T(eDist <= maxTextDistance);
    d0NF := d0N(eDist <= maxNumDistance);
    d0 := d0TF + d0NF;
    d0D := DISTRIBUTE(d0, HASH32(orig));
    d1 := SORT(d0D, orig, eDist, LOCAL);
    d2 := DEDUP(d1, orig);
    d3 := PROJECT(d2, mappingRec, LOCAL);
    out := DISTRIBUTE(d3, HASH32(orig));
    RETURN out;
  END;
  /**
    * Map any words not found in the model to the closest word in the model.
    * Return the original words if already in the model, otherwise, try to
    * map the word to a word in the model.  Leave out any words that can't be
    * mapped.
    */
  SHARED mapWords(DATASET(TextMod) mod, DATASET(WordExt) allWords) := FUNCTION
    // First find unique words to avoid repeating expensive mapping operation
    //  Allwords should be distributed by HASH32(text) at this point
    //  mod should also be distributed by HASH32(text).
    allWordsD := DISTRIBUTE(allWords, HASH32(text));
    modD := DISTRIBUTE(mod, HASH32(text));
    allWordsS := SORT(allWordsD, text, LOCAL);
    // Find unique
    words := DEDUP(allWordsS, text, LOCAL);
    // Join the unique words with the model.  If a word is not in the model, find the closest
    // word to it in typographic edit distance.
    wordsM0 := JOIN(words, modD, LEFT.text = RIGHT.text,
                TRANSFORM(mappingRec, SELF.orig := LEFT.text,
                  SELF.new := RIGHT.text),
               LEFT OUTER, LOCAL);
    missing := wordsM0(LENGTH(new) = 0);
    found := findClosestMatch(mod, missing);
    good := wordsM0(LENGTH(new) != 0);
    wordsM := good + found;
    // Now map the changes back into a new version of allWords
    mapped := JOIN(allWordsD, wordsM, LEFT.text = RIGHT.orig,
                      TRANSFORM(WordExt, SELF.text := RIGHT.new,
                                  SELF := LEFT), LOCAL);
    // Re DISTRIBUTE since some of the text may have changed.
    RETURN DISTRIBUTE(mapped, HASH32(text));
  END;
  /**
    * Convert a sentence into a sentence vector based on the words in the sentence and
    * the words in the model.
    */
  SHARED SentInfo sent2vector(DATASET(TextMod) mod, DATASET(Sentence) sent, UNSIGNED2 vecLen,
                          BOOLEAN mapMissingWords = TRUE) := FUNCTION
    // Should ultimately optimize with C++
    corp := int.Corpus(wordNGrams := wordNGrams);
    // Get the tokenized sentence
    wl := corp.sent2wordList(sent);
    wordExt getWords(WordList w, UNSIGNED c) := TRANSFORM
      SELF.sentId := w.sentId;
      SELF.text := w.words[c];
    END;
    // Create a separate record for each word
    allWords := NORMALIZE(wl, COUNT(LEFT.words), getWords(LEFT, COUNTER));
    allWordsD := DISTRIBUTE(allWords, HASH32(text));
    modD := DISTRIBUTE(mod, HASH32(text));
    // If requested, map any words not in the model to the closest approximation
    allWordsM := IF(mapMissingWords, mapWords(modD, allWordsD), allWordsD);
    // Get the word vectors for each word from the model
    sentWords0 := JOIN(allWordsM, modD, LEFT.text = RIGHT.text,
                        TRANSFORM(SentInfo, SELF.sentId := LEFT.sentId,
                            SELF.vec := RIGHT.vec,
                            SELF := LEFT),
                        LOCAL);
    // Redistribute by sentence id
    sentWords := SORT(DISTRIBUTE(sentWords0, sentId), sentId, LOCAL);
    SentInfo doRollup(sentInfo lr, SentInfo rr) := TRANSFORM
      SELF.vec := lr.vec + rr.vec;
      SELF.sentId := lr.sentId;
      SELF.text := '';
    END;
    // Accumulate all of the word vectors into a single long vector
    sentOut0 := ROLLUP(sentWords, doRollup(LEFT, RIGHT), sentId, LOCAL);
    // Now reduce the concatenated word vectors to a single word vector, and restore the original
    // sentence text.
    sentD := DISTRIBUTE(sent, sentId);
    sentOut := JOIN(sentOut0, sentD, LEFT.sentId = RIGHT.sentId, TRANSFORM(RECORDOF(LEFT),
                              SELF.vec := Utils.calcSentVector(LEFT.vec, vecLen),
                              SELF.text := RIGHT.text,
                              SELF := RIGHT), LOCAL);
    RETURN sentOut;
  END;
  /**
    * Find the closest word(s) to each of a given set of test words.
    * <p>Test words are specified as WordInfo records
    * (i.e. words with their associated vectors).
    * <p>Excludes the test word as a possible match.
    * Returns N closest matches for each test word. Optionally includes
    * NGrams (N > 1) as possible matches.
    */
  SHARED DATASET(Closest) closestWordVectors(DATASET(TextMod) mod, DATASET(WordInfo) words,
                                            UNSIGNED1 N=1, BOOLEAN showNGrams=FALSE) := FUNCTION
    // Similarity Record
    simRec := RECORD
      t_WordId id;
      t_Word text;
      t_Word otherWord;
      REAL4 similarity;
    END;
    // Transform to calculate Cosine Similarity
    simRec getSim(WordInfo word, TextMod modWord) := TRANSFORM
      SELF.text := word.text;
      SELF.similarity := Utils.cosineSim(word.vec, modWord.vec, vecLen);
      SELF.id := word.wordId;
      SELF.otherWord := modWord.text;
    END;
    // Only use the word portion of the model and optionally include NGrams.
    modW := IF(showNGrams, mod(typ = t_ModRecType.word),
                      mod(typ = t_ModRecType.word AND text[1] != '_'));
    sim0 := JOIN(words, modW, LEFT.text != RIGHT.text, getSim(LEFT, RIGHT), ALL);
    sim0D := DISTRIBUTE(sim0, id);
    sim1 := SORT(sim0D, id, -similarity, LOCAL);
    sim2 := DEDUP(sim1, id, KEEP N, LOCAL);
    // Roll up the best matches to return on record for each test word, containing
    // a set of best matches and the similarity for each.
    sim3 := PROJECT(sim2, TRANSFORM(Closest, SELF.closest := [LEFT.otherWord],
                                        SELF.similarity := [LEFT.similarity],
                                        SELF := LEFT), LOCAL);
    sim := ROLLUP(sim3, TRANSFORM(RECORDOF(LEFT),
                                        SELF.closest := LEFT.closest + RIGHT.closest,
                                        SELF.similarity := LEFT.similarity + RIGHT.similarity,
                                        SELF := LEFT), id, LOCAL);
    RETURN sim;
  END;
  
  /**
    * Train and return a model.  The model consists of a word portion, containing
    * all the words in the vocabulary along with their vectors, and a sentence portion
    * containing all of the sentences in the corpus along with their vectors.
    * @param sentences The sentences comprising the corpus to be trained in Types.Sentence
		* 									format.
    * @return A model in DATASET(TextMod) format.
		* @see Types.Sentence
    */
  EXPORT DATASET(SliceExt) GetModel_finalweights(DATASET(Sentence) sentences) := FUNCTION
    // Pre-process the corpus to determine vocabulary and training data
    corp := int.Corpus(sentences, wordNGrams, discardThreshold, minOccurs, dropoutK);
    vocabulary := corp.Vocabulary;
    trainDat := corp.GetTraining;
    trainCount := COUNT(trainDat);
    vocabSize := corp.vocabSize;
    // Set the shape of the neural network:
    // - input layer = vocabSize
    // - hidden layer = size of word / sentence vectors
    // - output layer = vocabSize
    nnShape := [vocabSize, vecLen, vocabSize];
    // If the default batchSize is zero (default -- auto), automatically calculate
    // a reasonable value.
    // nWeights = # of weights = 2 * vocabSize * vecLen
    // ud = Update Density = # of weights per batch / # of weights = 2 * vecLen * (1 + negSamp) * batchSize * nNodes /
    //      (2 * veclen * vocabSize) = (1 + negSamp) * batchSize * nNodes / vocabSize
    // We want to adjust batchSize such that ud = calConst.
    // batchSize = calConst * vocabSize / ((1+ negSamp) * nNodes)
    batchSizeCalc := (UNSIGNED4)(calConst * vocabSize) / ((1 + negSamples) * nNodes);
    batchSizeAdj := IF(batchSize = 0, batchSizeCalc, batchSize);
    // Set up the neural network and do stochastic gradient descent to train
    // the network.
    nn := int.SGD(nnShape, trainToLoss, numEpochs, batchSizeAdj, learningRate, negSamples, noProgressEpochs);
    finalWeights := nn.Train_Dupl(trainDat);
    // Now extract the final weights for the first layer as the word vectors
    wVecs := computeWordVectors(finalWeights, vocabulary, nnShape);
    // And produce the word portion of the model.
    wMod := makeWordModel(wVecs);
    // Calculate a vector for each sentence in the corpus to produce the sentence portion
    // of the model
    sVecs := sent2vector(wMod, corp.Sentences, vecLen, mapMissingWords := FALSE);
    sMod := makeSentModel(sVecs);
    // Concatenate the two portions, unless saveSentences is FALSE.
    mod := IF(saveSentences, wMod + sMod, wMod);
    RETURN finalWeights;
  END;

  EXPORT DATASET(TextMod) GetModel_custom(DATASET(Sentence) sentences, DATASET(SliceExt) startweight) := FUNCTION
    // Pre-process the corpus to determine vocabulary and training data
    corp := int.Corpus(sentences, wordNGrams, discardThreshold, minOccurs, dropoutK);
    vocabulary := corp.Vocabulary;
    trainDat := corp.GetTraining;
    trainCount := COUNT(trainDat);
    vocabSize := corp.vocabSize;
    // Set the shape of the neural network:
    // - input layer = vocabSize
    // - hidden layer = size of word / sentence vectors
    // - output layer = vocabSize
    nnShape := [vocabSize, vecLen, vocabSize];
    // If the default batchSize is zero (default -- auto), automatically calculate
    // a reasonable value.
    // nWeights = # of weights = 2 * vocabSize * vecLen
    // ud = Update Density = # of weights per batch / # of weights = 2 * vecLen * (1 + negSamp) * batchSize * nNodes /
    //      (2 * veclen * vocabSize) = (1 + negSamp) * batchSize * nNodes / vocabSize
    // We want to adjust batchSize such that ud = calConst.
    // batchSize = calConst * vocabSize / ((1+ negSamp) * nNodes)
    batchSizeCalc := (UNSIGNED4)(calConst * vocabSize) / ((1 + negSamples) * nNodes);
    batchSizeAdj := IF(batchSize = 0, batchSizeCalc, batchSize);
    // Set up the neural network and do stochastic gradient descent to train
    // the network.
    nn := SGD_modified(nnShape, trainToLoss, numEpochs, batchSizeAdj, learningRate, negSamples, noProgressEpochs);

    finalWeights := nn.Train_Dupl_custom(trainDat,startweight);
    // Now extract the final weights for the first layer as the word vectors
    wVecs := computeWordVectors(finalWeights, vocabulary, nnShape);
    // And produce the word portion of the model.
    wMod := makeWordModel(wVecs);
    // Calculate a vector for each sentence in the corpus to produce the sentence portion
    // of the model
    sVecs := sent2vector(wMod, corp.Sentences, vecLen, mapMissingWords := FALSE);
    sMod := makeSentModel(sVecs);
    // Concatenate the two portions, unless saveSentences is FALSE.
    mod := IF(saveSentences, wMod + sMod, wMod);
    RETURN mod;
  END;

  /**
    * Return the parameters under which the model was generated.  This function
    * should only be called during the training phase, or when the module was
    * invoked with the same parameters used in the training phase.  It may return
    * incorrect information if called with a previously persisted model when the
    * module was invoked e.g. with default values.
    * @param mod A model as previously returned from GetModel.
    * @return A DATASET(Types.TrainStats) containing a single record.
		* @see Types.TrainStats
    */
  EXPORT GetTrainStats(DATASET(TextMod) mod) := FUNCTION
    vocabSize := COUNT(mod(typ=t_ModRecType.word));
    nSentences := COUNT(mod(typ=t_ModRecType.sentence));
    shape := [vocabSize, vecLen, vocabSize];
    w := Weights_modified(shape);  // Module to manage weights
    batchSizeCalc := (UNSIGNED4)(calConst * vocabSize) / ((1 + negSamples) * nNodes);
    batchSizeAdj := IF(batchSize = 0, batchSizeCalc, batchSize);
    TrainStats getStats(TrainStats t) := TRANSFORM
      SELF.vecLen := vecLen;
      SELF.nWeights := w.nWeights;
      SELF.nSlices := w.nSlices;
      SELF.sliceSize := w.sliceSize;
      SELF.nWords :=vocabSize;
      SELF.nSentences := nSentences; 
      SELF.maxNGramSize := wordNGrams;
      SELF.nEpochs := numEpochs;
      SELF.negSamples := negSamples;
      SELF.batchSize := batchSizeAdj;
      SELF.minOccurs := minOccurs;
      SELF.maxTextDist := maxTextDistance;
      SELF.maxNumDist := maxNumDistance;
      SELF.discardThreshold := discardThreshold;
      SELF.learningRate := learningRate;
      // Updates per batch per node
      SELF.upbPerNode := SELF.batchSize * (1 + negSamples) * 2 * SELF.vecLen;
      // Updates per batch
      SELF.upb := SELF.upbPerNode * nNodes;
      SELF.updateDensity := SELF.upb / SELF.nWeights;
      SELF.udPerNode := SELF.upbPerNode / SELF.nWeights;
    END;
    stats := DATASET([{0}], TrainStats);
    statsOut := PROJECT(stats, getStats(LEFT));
    RETURN statsOut;
  END;
  /**
    * Obtain sentence vectors for a set of sentences given a previously trained model.
    * @param mod A model as previously returned from GetModel
    * @param sentences The set of sentences to vectorize in Types.Sentence format.
    * @return A DATASET(SentInfo) containing the vectors for each sentence.
		* @see Types.Sentence
		* @see Types.SentInfo
    */
  EXPORT DATASET(SentInfo) GetSentVectors(DATASET(TextMod) mod, DATASET(Sentence) sentences) := FUNCTION
    modW := mod(typ=t_ModRecType.word);
    RETURN sent2vector(modW, sentences, vecLen);
  END;
  /**
    * Obtain word vectors for a set of words.
    * @param mod A model as previously returned from GetModel
    * @param words The set of words to vectorize in Types.Word format.
    * @return A DATASET(Types.WordInfo) containing the vectors for each word.
		* @see Types.Word
		* @see Types.WordInfo
    */
  EXPORT DATASET(WordInfo) GetWordVectors(DATASET(TextMod) mod, DATASET(Word) words) := FUNCTION
    wordsL := PROJECT(words, TRANSFORM(RECORDOF(LEFT), SELF.text := Str.ToLowerCase(LEFT.text),
                                                            SELF := LEFT), LOCAL);
    wordsD := DISTRIBUTE(wordsL, HASH32(text));
    modD := DISTRIBUTE(mod(typ=t_ModRecType.word), HASH32(text));
    vecs := JOIN(wordsD, modD, LEFT.text = RIGHT.text, TRANSFORM(WordInfo,
                                          SELF.vec := RIGHT.vec, SELF.wordId := LEFT.id,
                                          SELF := LEFT),
                                        LEFT OUTER, LOCAL);
    RETURN vecs;
  END;
  /**
    * Find the closest words in the training set, given a set of words.
    * <p>For each word in the provided set, find the most similar words in the training
    * set.  Note that the requested word is never returned.  It is filtered out of the
		* results and only words close to but not equal to that word are returned.
    * @param mod A model as returned from GetModel.
    * @param words A dataset of Types.Word with the words to be matched.
    * @param N The number of closest matches to return (Default 1).
    * @param showNGrams True if NGrams (n greater than 1) are to be considered in the matching
    *                   (Default FALSE).
    * @return A dataset of Types.Closest showing the closest words to each test word
    *         as well as their numeric similarity (i.e. Cosine Similarity).
		* @see Types.Closest
    */
  EXPORT DATASET(Closest) ClosestWords(DATASET(TextMod) mod, DATASET(Word) words,
                                  UNSIGNED1 N=1, BOOLEAN showNGrams=FALSE) := FUNCTION
    modW := mod(typ=t_ModRecType.word);
    wordsD := DISTRIBUTE(words, HASH32(text));
    modD := DISTRIBUTE(modW, HASH32(text));
    wi := JOIN(wordsD, modD, LEFT.text = RIGHT.text, TRANSFORM(WordInfo,
                      SELF.wordId := LEFT.id, SELF.vec := RIGHT.vec, SELF := LEFT), LOCAL);
    RETURN closestWordVectors(modW, wi, N, showNGrams := showNGrams); 
  END;
  /**
    * Find the outlier(s) given a set of words.
    * <p>Implements "One of these things is not like the other".
    * @param mod A model as returned from GetModel.
    * @param words A list of words from which to find the least similar.
    * @param N The number of least similar words to return (Default 1).
    * @return A list of words (Types.Word) in order of increasing similarity.
		* @see Types.Word
    */
  EXPORT DATASET(Word) LeastSimilarWords(DATASET(TextMod) mod, DATASET(Word) words, UNSIGNED1 N=1) := FUNCTION
    // Similarity record
    simRec := RECORD
      t_WordId id;
      t_Word text;
      t_Word otherWord;
      REAL4 similarity;
    END;
    // Transform to compute the similarity.
    simRec getSim(WordInfo word, TextMod modWord) := TRANSFORM
      SELF.text := word.text;
      SELF.similarity := Utils.cosineSim(word.vec, modWord.vec, vecLen);
      SELF.id := word.wordId;
      SELF.otherWord := modWord.text;
    END;
    wordsD := DISTRIBUTE(words, HASH32(text));
    // Only use the word portion of the model.
    modW := mod(typ=t_ModRecType.word);
    modD := DISTRIBUTE(modW, HASH32(text));
    // Find the similarity for each test word to every other test word
    wi := JOIN(wordsD, modD, LEFT.text = RIGHT.text, TRANSFORM(WordInfo,
                      SELF.wordId := LEFT.id, SELF.vec := RIGHT.vec, SELF := LEFT), LOCAL);
    lsim0 := JOIN(wi, modW, LEFT.text != RIGHT.text, getSim(LEFT, RIGHT), ALL);
    lsim0D := DISTRIBUTE(lsim0, id);
    // Find the sum of each words similarity to all of the other words
    lsim1 := TABLE(lsim0D, {id, text, totalSim := SUM(GROUP, similarity)}, id, text, LOCAL);
    // Find the word that is the least similar to all other words.
    lsim2 := SORT(lsim1, totalSim);
    lsim3 := lsim2[..N];
    lsim := PROJECT(lsim3, TRANSFORM(Word, SELF.id := LEFT.id, SELF.text := LEFT.text), LOCAL);
    RETURN lsim;
  END;
  /**
    * Solves an analogy of the form: A is to B as C is to ?
    * @param A The main word.
    * @param B The 'isTo' word.
    * @param C The 'as' word.
    * @param N The number of best matches to return (Default 1).
    * @param showNGrams TRUE to include NGrams (N greater than 1) in the list of solutions.
    * @return A set of best solutions in Types.Closest format.
		* @see Types.Closest
    */
  EXPORT DATASET(Closest) WordAnalogy(DATASET(TextMod) mod, STRING A,
                                  STRING B, STRING C, UNSIGNED2 N=1,
                                  BOOLEAN showNGrams=FALSE) := FUNCTION
    words := DATASET([{1, A}, {2, B}, {3, C}], Word);
    wi := GetWordVectors(mod, words);
    // A - B + C
    target0 := Utils.addVecs(Utils.addVecs(wi[1].vec, wi[2].vec, -1), wi[3].vec);
    // Normalize the resulting vector to form a unit vector.
    target := Utils.normalizeVector(target0);
    // Use C as the text so that we don't return that word as the answer.
    targetWord := DATASET([{1, C, 1, 0, target}], WordInfo);
    closest0 := closestWordVectors(mod, targetWord, N, showNGrams := showNGrams);
    // Now remove the text of C to avoid confusion.  Replace with the analogy statement.
    analogyText := A + ' is to ' + B + ' as ' + C + ' is to: ';
    closest := PROJECT(closest0, TRANSFORM(RECORDOF(LEFT), SELF.text := analogyText, SELF := LEFT), LOCAL);
    RETURN closest;
  END;
  /**
    * Find the closest sentence or sentences for each test sentence.
    * @param mod A model as returned from GetModel.
    * @param sentences The list of test sentences in Types.Sentence format.
    * @param N The number of closest matches to return for each test sentence.
    * @return A list of closest matches for each test sentence in Types.Closest
    *         format.
		* @see Types.Closest
		* @see Types.Sentence
    */
  EXPORT DATASET(Closest) ClosestSentences(DATASET(TextMod) mod,
                      DATASET(Sentence) sentences, UNSIGNED1 N=1) := FUNCTION
    trainSentences0 := DISTRIBUTE(mod(typ=t_ModRecType.sentence));
    trainSentences := ASSERT(trainSentences0, EXISTS(trainSentences0), 'No sentence vectors in model.  Set module parameter' +
                              ' saveSentences to TRUE');
    sentencesD := DISTRIBUTE(sentences);
    // Generate a vector for each test sentence.
    si := GetSentVectors(mod, sentencesD);
    // Similarity Record
    simRec := RECORD
      t_SentId id;
      t_Sentence text;
      t_Sentence otherSent;
      REAL4 similarity;
    END;
    // Transform to calculate similarity
    simRec getSim(TextMod modSent, SentInfo sent) := TRANSFORM
      SELF.text := sent.text;
      SELF.similarity := Utils.cosineSim(sent.vec, modSent.vec, vecLen);
      SELF.id := sent.sentId;
      SELF.otherSent := modSent.text;
    END;
    // Compute the Cosine Similarity between each test sentence and each
    // of the sentences in the training corpus.
    sim0 := JOIN(trainSentences, si, TRUE, getSim(LEFT, RIGHT), ALL);
    sim1 := DISTRIBUTE(sim0, id);
    sim2 := SORT(sim1, id, -similarity, LOCAL);
    // Get the N most similar.
    sim3 := DEDUP(sim2, id, KEEP N, LOCAL);
    // Roll up to a single record for each test sentence, with a set of
    // closest sentences in each record.
    sim4 := PROJECT(sim3, TRANSFORM(Closest, SELF.closest := [LEFT.otherSent],
                                    SELF.similarity := [LEFT.similarity],
                                    SELF := LEFT), LOCAL);
    sim := ROLLUP(sim4, TRANSFORM(RECORDOF(LEFT),
                                    SELF.closest := LEFT.closest + RIGHT.closest,
                                        SELF.similarity := LEFT.similarity + RIGHT.similarity,
                                        SELF := LEFT), id, LOCAL);
    RETURN sim;
  END;
  /**
    * Compute the similarity level between two word or sentence vectors.
    * <p>The Cosine Similarity of the two vectors is returned.  This is a number between -1 and 1, where
    * 1 implies exact similarity, zero implies orthogonality (i.e. non-correlation) meaning the words are
    * unrelated.  Negative values imply a sort of inverse correlation, although they do not necessarily
    * imply antonymity.  Note that this is a symmetric function so the order of the vectors is not significant.
    * 
    * @param vec1 The first vector in Types.t_Vector format.
    * @param vec2 The second vector in Types.t_Vector format.
    * @return The Cosine Similarity between the two vectors.
		* @see Types.t_Vector
    */
  EXPORT REAL4 Similarity(t_Vector vec1, t_Vector vec2) := FUNCTION
    RETURN Utils.cosineSim(vec1, vec2, COUNT(vec1));
  END;
END;