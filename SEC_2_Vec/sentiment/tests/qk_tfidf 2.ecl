IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
IMPORT TextVectors as tv;
IMPORT tv.Types;

#OPTION('outputLimit',1750);

srec := sentiment.sent_model.sveclblrec;
modrec := Types.TextMod;

sents := DATASET(WORKUNIT('W20200710-041732','Result 1'),srec);
model := DATASET(WORKUNIT('W20200710-041732','Result 2'),modrec);

tsents := PROJECT(sents,TRANSFORM(Types.Sentence,SELF.sentId := LEFT.sentId,SELF.text := LEFT.text));
//tsents_small := tsents(sentId%10=0);
//tsents_small := tsents(sentId%10=0);

//ssn := sentiment.sent_setup_norm(tsents_small,model);
ssn := sentiment.sent_setup_norm(tsents(),model);

//OUTPUT(ssn.sembed_grp_experimental,NAMED('tfidf_some'));
//OUTPUT(tsents,ALL,NAMED('tsents_all'));
//tfidfnorm := ssn.tfidf_norm;
tfidfnorm := ssn.tfidf_norm;
tfidf := ssn.sembed_grp_experimental;
// normrec := RECORDOF(tfidfnorm);
//tfnormno0 := tfidfnorm(tfidf_score != 0);
//tfbigpart := tfidfnorm[..10000000];
//tfbigno0s := tfbigpart(tfidf_score != 0);
// tfidf_allsort := SORT(tfidfnorm,sentId);
// tfidf_sentgrp := GROUP(tfidf_allsort,sentId);

// weirdrec := RECORD
//     DATASET(normrec) non0rows;
// END;

// weirdrec no0grps_T(normrec l,DATASET(normrec) lr) := TRANSFORM
//     SELF.non0rows := lr(tfidf_score!=0);
// END;

// tfidf_no0s := ROLLUP(tfidf_sentgrp,GROUP,no0grps_T(LEFT,ROWS(LEFT)));

//OUTPUT(COUNT(tfbigpart));
//OUTPUT(tfbigno0s);
//OUTPUT(tfidfnorm[..10000000],ALL,NAMED('tfidfnorm'));
//OUTPUT(COUNT(tfnormno0));
//OUTPUT(tfidfnorm);
//OUTPUT(tfidf,ALL,NAMED('tfidf_all'));
//OUTPUT(tfnormno0,ALL,NAMED('tfnormno0'));
OUTPUT(tfidfnorm);
OUTPUT(tfidf);
//OUTPUT(tfidf_no0s[..2]);