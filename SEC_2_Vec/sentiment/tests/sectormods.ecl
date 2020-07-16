IMPORT SEC_2_Vec.sentiment;
IMPORT * FROM sentiment;
IMPORT * FROM sentiment.tests;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT LogisticRegression as LR;

trec := sentiment.sent_model.trainrec;

secs := sectors.sectorlist;
sec1 := secs[1];

secticks1 := SET(sectors.sectorticker(sector=sec1),ticker);

plainlblvn := DATASET(WORKUNIT('W20200711-042721','plain_label_vanilla_data'),trec);

dat_sec1 := plainlblvn(get_tick(fname) in secticks1);

plain := sent_model.getFields(dat_sec1);

X := plain.NUMF;
Y := plain.DSCF;

plainblr := LR.BinomialLogisticRegression();

modpl := plainblr.getModel(X,Y);

conpl := LR.BinomialConfusion(plainblr.Report(modpl,X,Y));

OUTPUT(sec1);
OUTPUT(secticks1);
OUTPUT(conpl);