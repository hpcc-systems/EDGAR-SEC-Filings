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

    vecLen := COUNT(sents[1].vec);
    out := AGGREGATE(sents,trainrec,TRANSFORM(trainrec,SELF.vec := addvecs(LEFT.vec,RIGHT.vec),
                                                        SELF := LEFT),TRANSFORM(trainrec,SELF.vec := addvecs(RIGHT1.vec,RIGHT2.vec), SELF := RIGHT1),LEFT.fname);

    sentFiles := SORT(DISTRIBUTE(sents,HASH32(fname)),fname,LOCAL);

    trainrec doRollup(trainrec lr,trainrec rr) := TRANSFORM
        SELF.vec := lr.vec + rr.vec;
        SELF.id := lr.id;
        SELF := lr;
    END;

    fileOut0 := ROLLUP(sentFiles,doRollup(LEFT,RIGHT),fname,LOCAL);

    fileOut := PROJECT(fileOut0,TRANSFORM(trainrec,SELF.vec := tv.Internal.svUtils.calcSentVector(LEFT.vec,vecLen),
                                                SELF := LEFT));

    RETURN fileOut;
END;