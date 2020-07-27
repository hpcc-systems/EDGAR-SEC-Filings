IMPORT ML_Core;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM SEC_2_Vec.sentiment.tests;

#OPTION('outputLimit',2000);

sam := sents_and_mod;
model := sam.m;
sents := sam.p;

pl_vn := sam.t;
pl_tf := tfidf_experimental(model(typ=1),sents,100,1);

OUTPUT(pl_vn,ALL,NAMED('plain_vanilla'));
OUTPUT(pl_tf,ALL,NAMED('plain_tfidf'));