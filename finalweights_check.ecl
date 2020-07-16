IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;

path := '~ncf::edgarfilings::raw::tech10qs_group';

//rawsents := SEC_2_Vec.secvec_input(path);

//rawrec := RECORD
//    UNSIGNED8 sentId := rawsents.sentId;
//    STRING    text   := rawsents.text;
//END;
//trainSentences := TABLE(rawsents,rawrec);
//sv := SEC_2_Vec.SentenceVectors_modified();

//OUTPUT(sv.GetModel_finalweights(trainSentences));

OUTPUT(Stage_Learn.Stage1(path));