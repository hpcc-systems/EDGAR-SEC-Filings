IMPORT * FROM Types;
IMPORT TextVectors as tv;
IMPORT * FROM Internal.svUtils;

t_Vector := tv.Types.t_Vector;

//takes a set of sentence vectors
//and converts to 'document vectors'
//by averaging vecs from same filename
//
//PARAMETERS:
// sents (dataset of type trainrec, sentence vectors to model from)
//
//RETURNS:
// doc_model() (dataset of type trainrec, one vector for each fname.
// current implementation averages sent vecs)

EXPORT doc_model(DATASET(trainrec) sents) := FUNCTION

    out := AGGREGATE(sents,trainrec,TRANSFORM(trainrec,SELF.vec := addvecs(LEFT.vec,RIGHT.vec),
                                                        SELF := LEFT),LEFT.fname,LOCAL);

    RETURN PROJECT(out,TRANSFORM(trainrec,SELF.vec := tv.Internal.svUtils.normalizeVector(LEFT.vec),SELF := LEFT));
END;