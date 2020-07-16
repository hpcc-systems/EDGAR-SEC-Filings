IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM ML_Core;
IMPORT TextVectors as tv;
IMPORT LogisticRegression AS LR;
trainrec := sent_model.trainrec;

#OPTION('outputLimit',1500);

path := '~ncf::edgarfilings::raw::plainlabel_allsecs_all';

//dat := sent_model.trndata_wlbl(path,TRUE,'s&p');

rawsents_all := secvec_input_lbl(path,TRUE,'s&p');

//rawsents := rawsents_all[..1000];
rawsents := rawsents_all;//[..20000];

tsentrec := RECORD
    UNSIGNED8 sentId := rawsents.sentId;
    STRING text := rawsents.text;
END;

tsents := TABLE(rawsents,tsentrec);

sv := tv.SentenceVectors(100,0.0005,0,0,5,.05,.00005);

mod := sv.getModel(tsents);

OUTPUT(rawsents);
OUTPUT(mod,ALL,NAMED('rawsents_model'));