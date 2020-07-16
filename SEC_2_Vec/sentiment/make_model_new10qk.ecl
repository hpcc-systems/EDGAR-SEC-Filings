IMPORT STD;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM ML_Core;
IMPORT TextVectors as tv;
IMPORT LogisticRegression as LR;
IMPORT LearningTrees AS LT;
IMPORT * FROM LT;
IMPORT sectors from SEC_2_Vec.sentiment.tests;
IMPORT * FROM EDGAR_Extract.Text_Tools;

//#OPTION('outputLimit',150);
#OPTION('outputLimit',2000);

trainrec := sent_model.trainrec;

path10k := '~ncf::edgarfilings::raw::labels_allsecs_all_10k';
path10q := '~ncf::edgarfilings::raw::plainlabel_allsecs_all';

//svl := secvec_input_lbl(path10q,path10k,TRUE,'plain');
svl := secvec_input_lbl(path10q,path10k,TRUE,'s&p');

dat := sent_model.trn10q10klbl_van(svl);
//ff := sent_model.getFields(dat);
//X := ff.NUMF;
//Y := ff.DSCF;
dat1 := dat[..10000];
dat2 := dat[10001..20000];
dat3 := dat[20001..30000];
dat4 := dat[30001..40000];
dat5 := dat[40001..];
dat123 := dat1+dat2+dat3;
dat234 := dat2+dat3+dat4;
dat124 := dat1+dat2+dat4;
dat134 := dat1+dat3+dat4;

secs := sectors.sectorlist;

sector_tick(INTEGER sec_n) := FUNCTION
    RETURN dat(get_tick(fname) IN SET(sectors.sectorticker(sector=secs[sec_n]),ticker));
END;
sec1 := sector_tick(1);
sec2 := sector_tick(2);
sec3 := sector_tick(3);

CF := LT.ClassificationForest(50,0,25);

//mod := CF.GetModel(X,Y);
ff1 := sent_model.getFields(dat1);
ff2 := sent_model.getFields(dat2);
ff3 := sent_model.getFields(dat3);
ff4 := sent_model.getFields(dat4);
ff5 := sent_model.getFields(dat5);
ff123 := sent_model.getFields(dat123);
ff234 := sent_model.getFields(dat234);
ff124 := sent_model.getFields(dat124);
ff134 := sent_model.getFields(dat134);

ff_sec1 := sent_model.getFields(sec1);
ff_sec2 := sent_model.getFields(sec2);
ff_sec3 := sent_model.getFields(sec3);

X1 := ff1.NUMF;
Y1 := ff1.DSCF;
X2 := ff2.NUMF;
Y2 := ff2.DSCF;
X3 := ff3.NUMF;
Y3 := ff3.DSCF;
X4 := ff4.NUMF;
Y4 := ff4.DSCF;
X5 := ff5.NUMF;
Y5 := ff5.DSCF;
X123 := ff123.NUMF;
Y123 := ff123.DSCF;
X234 := ff234.NUMF;
Y234 := ff234.DSCF;
X124 := ff124.NUMF;
Y124 := ff124.DSCF;
X134 := ff134.NUMF;
Y134 := ff134.DSCF;
//X1234 := ff1234.NUMF;
//Y1234 := ff1234.DSCF;

X_sec1 := ff_sec1.NUMF;
Y_sec1 := ff_sec1.DSCF;
X_sec2 := ff_sec2.NUMF;
Y_sec2 := ff_sec2.DSCF;
X_sec3 := ff_sec3.NUMF;
Y_sec3 := ff_sec3.DSCF;

//mod12 := CF.GetModel(X12,Y12);
//mod13 := CF.GetModel(X13,Y13);
//mod14 := CF.GetModel(X14,Y14);
//mod23 := CF.GetModel(X23,Y23);
//mod24 := CF.GetModel(X24,Y24);
//mod34 := CF.GetModel(X34,Y34);
mod123 := CF.GetModel(X123,Y123);
mod234 := CF.GetModel(X234,Y234);
mod124 := CF.GetModel(X124,Y124);
mod134 := CF.GetModel(X134,Y134);
mod_sec1 := CF.GetModel(X_sec1,Y_sec1);
mod_sec2 := CF.GetModel(X_sec2,Y_sec2);
mod_sec3 := CF.GetModel(X_sec3,Y_sec3);
//mod1234 := CF.GetModel(X1234,Y1234);
//mod1245 := CF.GetModel

preds123 := CF.Classify(mod123,X123);
preds234 := CF.Classify(mod234,X234);
preds124 := CF.Classify(mod124,X124);
preds134 := CF.Classify(mod134,X134);
preds_sec1 := CF.Classify(mod_sec1,X_sec1);
preds_sec2 := CF.Classify(mod_sec2,X_sec2);
preds_sec3 := CF.Classify(mod_sec3,X_sec3);
// preds1234 := CF.Classify(mod1234,X1234);

// preds1234_5 := CF.Classify(mod1234,X5);

// preds123_5 := CF.Classify(mod123,X5);


// preds234_5 := CF.Classify(mod234,X5);
// preds124_5 := CF.Classify(mod124,X5);
// preds134_5 := CF.Classify(mod134,X5);

//precon := LR.Confusion(Y,preds);
//con := LR.BinomialConfusion(precon);

precon123 := LR.Confusion(Y123,preds123);
con123 := LR.BinomialConfusion(precon123);
precon234 := LR.Confusion(Y234,preds234);
con234 := LR.BinomialConfusion(precon234);
precon124 := LR.Confusion(Y124,preds124);
con124 := LR.BinomialConfusion(precon124);
precon134 := LR.Confusion(Y134,preds134);
con134 := LR.BinomialConfusion(precon134);
precon_sec1 := LR.Confusion(Y_sec1,preds_sec1);
con_sec1 := LR.BinomialConfusion(precon_sec1);
precon_sec2 := LR.Confusion(Y_sec2,preds_sec2);
con_sec2 := LR.BinomialConfusion(precon_sec2);
precon_sec3 := LR.Confusion(Y_sec3,preds_sec3);
con_sec3 := LR.BinomialConfusion(precon_sec3);
// precon1234 := LR.Confusion(Y1234,preds1234);
// con1234 := LR.BinomialConfusion(precon1234);

// precon1234_5 := LR.Confusion(Y5,preds1234_5);
// con1234_5 := LR.BinomialConfusion(precon1234_5);

//OUTPUT(dat,NAMED('plain_van_10q10k'));
//OUTPUT(con,NAMED('tree_model_confusion'));
OUTPUT(con123);
OUTPUT(con234);
OUTPUT(con124);
OUTPUT(con134);
OUTPUT(con_sec1);
OUTPUT(con_sec2);
OUTPUT(con_sec3);
OUTPUT(mod123);
OUTPUT(mod234);
OUTPUT(mod124);
OUTPUT(mod134);
OUTPUT(mod_sec1);
OUTPUT(mod_sec2);
OUTPUT(mod_sec3);