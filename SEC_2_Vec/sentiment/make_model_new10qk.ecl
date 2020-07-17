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
//svlsp := secvec_input_lbl(path10q,path10k,TRUE,'s&p');
spdat := DATASET(WORKUNIT('W20200713-063347','sandp_label_vanilla_data'),trainrec);

secs := sectors.sectorlist;

sector_tick(INTEGER sec_n) := FUNCTION
    datn := spdat(get_tick(fname) IN SET(sectors.sectorticker(sector=secs[sec_n]),ticker));
    ff_secn := sent_model.getFields(datn);
    RETURN ff_secn;
END;

// sec1 := sector_tick(1);
// sec2 := sector_tick(2);
// sec3 := sector_tick(3);
// sec4 := sector_tick(4);
// sec5 := sector_tick(5);
// sec6 := sector_tick(6);
sec7 := sector_tick(7);
sec8 := sector_tick(8);
sec9 := sector_tick(9);
sec10 := sector_tick(10);
sec11 := sector_tick(11);
sec12 := sector_tick(12);

X_sec7 := sec7.NUMF;
Y_sec7 := sec7.DSCF;
X_sec8 := sec8.NUMF;
Y_sec8 := sec8.DSCF;
X_sec9 := sec9.NUMF;
Y_sec9 := sec9.DSCF;
X_sec10 := sec10.NUMF;
Y_sec10 := sec10.DSCF;
X_sec11 := sec11.NUMF;
Y_sec11 := sec11.DSCF;
X_sec12 := sec12.NUMF;
Y_sec12 := sec12.DSCF;

OUTPUT(secs[7]);
OUTPUT(secs[8]);
OUTPUT(secs[9]);
OUTPUT(secs[10]);
OUTPUT(secs[11]);
OUTPUT(secs[12]);
OUTPUT(X_sec7,ALL,NAMED('X_sec7'));
OUTPUT(Y_sec7,ALL,NAMED('Y_sec7'));
OUTPUT(X_sec8,ALL,NAMED('X_sec8'));
OUTPUT(Y_sec8,ALL,NAMED('Y_sec8'));
OUTPUT(X_sec9,ALL,NAMED('X_sec9'));
OUTPUT(Y_sec9,ALL,NAMED('Y_sec9'));
OUTPUT(X_sec10,ALL,NAMED('X_sec10'));
OUTPUT(Y_sec10,ALL,NAMED('Y_sec10'));
OUTPUT(X_sec11,ALL,NAMED('X_sec11'));
OUTPUT(Y_sec11,ALL,NAMED('Y_sec11'));
OUTPUT(X_sec12,ALL,NAMED('X_sec12'));
OUTPUT(Y_sec12,ALL,NAMED('Y_sec12'));