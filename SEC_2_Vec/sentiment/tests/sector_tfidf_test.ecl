IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM SEC_2_Vec.sentiment.tests;
IMPORT TextVectors as tv;
IMPORT tv.Types;
t_Vector := Types.t_Vector;

#OPTION('outputLimit',1000);

srec := sentiment.sent_model.sveclblrec;
modrec := Types.TextMod;

sents := DATASET(WORKUNIT('W20200710-041732','Result 1'),srec);
model := DATASET(WORKUNIT('W20200710-041732','Result 2'),modrec);

basicind := sector_tfidf(sents,model);
out := basicind.tfn(2);

OUTPUT(out,ALL);