IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM SEC_2_Vec.sentiment.tests;
IMPORT TextVectors as tv;
IMPORT tv.Types;
IMPORT * FROM EDGAR_Extract.Text_Tools;
t_Vector := Types.t_Vector;

#OPTION('outputLimit',1000);

srec := sentiment.sent_model.sveclblrec;
modrec := Types.TextMod;
trainrec := sentiment.sent_model.trainrec;

N := 2;
secn := sectors.sectorlist[N];

sents := DATASET(WORKUNIT('W20200710-041732','Result 1'),srec);
model := DATASET(WORKUNIT('W20200710-041732','Result 2'),modrec);

optrec := RECORD
    UNSIGNED8 sentId;
    STRING text;
    t_Vector w_Vector;
END;

trainrec plv_T(srec s,modrec m) := TRANSFORM
    stmt := get_tick(s.fname) in SET(sectors.sectorticker(sector=secn),ticker);
    SELF.id := IF(stmt,m.id,SKIP);
    SELF.text := IF(stmt,m.text,SKIP);
    SELF.vec := IF(stmt,m.vec,[SKIP]);
    SELF.label := IF(stmt,s.label,SKIP);
    SELF.fname := IF(stmt,s.fname,SKIP);
END;

//tfidf_read := DATASET(WORKUNIT('W20200719-060033','Result 1'),optrec);
tfidf_read := DATASET(WORKUNIT('W20200719-090512','Result 1'),optrec);


plvan := JOIN(sents,model(typ=2),LEFT.sentId=RIGHT.id,plv_T(LEFT,RIGHT));
        
pltfi := JOIN(sents,tfidf_read,LEFT.sentId=RIGHT.sentId,
                TRANSFORM(trainrec,
                SELF.id := RIGHT.sentId,
                SELF.text := RIGHT.text,
                SELF.vec := RIGHT.w_Vector,
                SELF.label := LEFT.label,
                SELF.fname := LEFT.fname));

IMPORT LogisticRegression as LR;
IMPORT ML_Core;

ffvan := sent_model.getFields(plvan);
fftfi := sent_model.getFields(pltfi);

Xvan := ffvan.NUMF;
Yvan := ffvan.DSCF;
Xtfi := fftfi.NUMF;
Ytfi := fftfi.DSCF;

plainblr := LR.BinomialLogisticRegression();

mod_van := plainblr.GetModel(Xvan,Yvan);
mod_tfi := plainblr.GetModel(Xtfi,Ytfi);

preds_van := plainblr.Classify(mod_van,Xvan);
preds_tfi := plainblr.Classify(mod_tfi,Xtfi);

con_van := ML_Core.Analysis.Classification.Accuracy(preds_van,Yvan);
con_tfi := ML_Core.Analysis.Classification.Accuracy(preds_tfi,Ytfi);

OUTPUT(con_van);
OUTPUT(con_tfi);