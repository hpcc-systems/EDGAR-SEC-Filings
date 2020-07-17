outrec := RECORD
    STRING sector;
    INTEGER depth;
    REAL8 acc;
END;

first6 := DATASET(WORKUNIT('W20200717-070636','Result 1'),outrec);
last6 := DATASET(WORKUNIT('W20200717-071106','Result 1'),outrec);

all12 := first6+last6;
IMPORT * FROM SEC_2_Vec.sentiment.tests;

OUTPUT(all12);
OUTPUT(sectors.sectorlist);