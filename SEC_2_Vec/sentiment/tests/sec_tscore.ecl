IMPORT * FROM SEC_2_Vec.sentiment;

wurec := RECORD
    STRING wu;
END;

secrec := RECORD
    STRING sector;
END;

wus := DATASET([{'W20200713-064429'},
          {'W20200713-063131'},
          {'W20200713-054128'},
          {'W20200712-195524'},
          {'W20200712-190112'},
          {'W20200712-184741'},
          {'W20200711-092701'}],wurec);



secaccrec := RECORD
    STRING sector;
    REAL8 acc;
END;

wu_pl1 := DATASET(WORKUNIT(wus[1].wu,'Result 1'),secaccrec);
wu_sp1 := DATASET(WORKUNIT(wus[1].wu,'Result 2'),secaccrec);
wu_pl2 := DATASET(WORKUNIT(wus[2].wu,'Result 1'),secaccrec);
wu_sp2 := DATASET(WORKUNIT(wus[2].wu,'Result 2'),secaccrec);
wu_pl3 := DATASET(WORKUNIT(wus[3].wu,'Result 1'),secaccrec);
wu_sp3 := DATASET(WORKUNIT(wus[3].wu,'Result 2'),secaccrec);
wu_pl4 := DATASET(WORKUNIT(wus[4].wu,'Result 1'),secaccrec);
wu_sp4 := DATASET(WORKUNIT(wus[4].wu,'Result 2'),secaccrec);
wu_pl5 := DATASET(WORKUNIT(wus[5].wu,'Result 1'),secaccrec);
wu_sp5 := DATASET(WORKUNIT(wus[5].wu,'Result 2'),secaccrec);
wu_pl6 := DATASET(WORKUNIT(wus[6].wu,'Result 1'),secaccrec);
wu_sp6 := DATASET(WORKUNIT(wus[6].wu,'Result 2'),secaccrec);
wu_pl7 := DATASET(WORKUNIT(wus[7].wu,'Result 1'),secaccrec);
wu_sp7 := DATASET(WORKUNIT(wus[7].wu,'Result 2'),secaccrec);

wu_pl := DATASET([{wu_pl1},{wu_pl2},{wu_pl3},{wu_pl4},{wu_pl5},{wu_pl6},{wu_pl7}],{DATASET(secaccrec) secacc});
wu_sp := DATASET([{wu_sp1},{wu_sp2},{wu_sp3},{wu_sp4},{wu_sp5},{wu_sp6},{wu_sp7}],{DATASET(secaccrec) secacc});

secdsrec := RECORD
    REAL8 acc_pl;
    REAL8 acc_sp;
END;

secs := DATASET(sectors.sectorlist,secrec);

tsrec := RECORD
    STRING sector;
    REAL8 secmean_pl;
    REAL8 secvar_pl;
    REAL8 secmean_sp;
    REAL8 secvar_sp;
END;

seven := DATASET([1,2,3,4,5,6,7],{INTEGER i});

DATASET(secdsrec) sec_ds(STRING s) := FUNCTION
    secdsrec out_T(INTEGER C) := TRANSFORM
        pl := wu_pl[C].secacc;//DATASET(WORKUNIT(w.wu,'Result 1'),secaccrec);
        SELF.acc_pl := pl(sector=s)[1].acc;
        sp := wu_sp[C].secacc;//DATASET(WORKUNIT(w.wu,'Result 2'),secaccrec);
        SELF.acc_sp := sp(sector=s)[1].acc;
    END;

    RETURN PROJECT(seven,out_T(LEFT.i));
END;

tsrec tscore_T(secrec s) := TRANSFORM
    SELF.sector := s.sector;
    sds := sec_ds(s.sector);
    SELF.secmean_pl := AVE(sds,sds.acc_pl);
    SELF.secvar_pl := VARIANCE(sds,acc_pl);
    SELF.secmean_sp := AVE(sds,sds.acc_sp);
    SELF.secvar_sp := VARIANCE(sds,acc_sp);
END;

tsr := PROJECT(secs,tscore_T(LEFT));

scorerec := RECORD
    STRING sec1;
    STRING sec2;
    REAL8 diff_mean_pl;
    REAL8 diff_mean_sp;
    REAL8 std_err_pl;
    REAL8 std_err_sp;
    REAL8 tscore_pl;
    REAL8 tscore_sp;
END;

stderr(REAL8 v1,REAL8 v2) := FUNCTION
    c := COUNT(wus);
    err := SQRT((v1/c) + (v2/c));
    RETURN err;
END;

score_T(STRING s1,STRING s2) := FUNCTION
    t1 := tsr(sector=s1)[1];
    t2 := tsr(sector=s2)[1];
    result := MODULE
        EXPORT diffpl := t1.secmean_pl-t2.secmean_pl;
        EXPORT diffsp := t1.secmean_sp-t2.secmean_sp;
        EXPORT errpl  := stderr(t1.secvar_pl,t2.secvar_pl);
        EXPORT errsp  := stderr(t1.secvar_sp,t2.secvar_sp);
        EXPORT tscpl  := diffpl/errpl;
        EXPORT tscsp  := diffsp/errsp;
    END;
    RETURN result;
END;

sec1 := secs[6].sector;
sec2 := secs[7].sector;
sec3 := secs[11].sector;

sc12 := score_T(sec1,sec2);
sc13 := score_T(sec1,sec3);
sc23 := score_T(sec2,sec3);

OUTPUT(tsr);
OUTPUT(sec1);
OUTPUT(sec2);
OUTPUT(sec3);
OUTPUT(sc12.tscpl);
OUTPUT(sc12.tscsp);
OUTPUT(sc13.tscpl);
OUTPUT(sc13.tscsp);
OUTPUT(sc23.tscpl);
OUTPUT(sc23.tscsp);