IMPORT * FROM SEC_2_Vec.sentiment.tests;

outrec := RECORD
    STRING sector;
    REAL8 acc_pl;
    REAL8 acc_sp;
    REAL8 pod_pl;
    REAL8 pod_sp;
    REAL8 hpod_pl;
    REAL8 hpod_sp;
    REAL8 pode_pl;
    REAL8 pode_sp;
    REAL8 hpode_pl;
    REAL8 hpode_sp;
END;

get_info(INTEGER n) := FUNCTION
    sm_pl := secmod_n(n,'plain');
    sm_sp := secmod_n(n,'s&p');
    sec := sm_pl.s;
    apl := sm_pl.c[1].accuracy;
    asp := sm_sp.c[1].accuracy;
    ppl := sm_pl.p[1].pod;
    psp := sm_sp.p[1].pod;
    hpl := sm_pl.h[1].pod;
    hsp := sm_sp.h[1].pod;
    pepl := sm_pl.p[1].pode;
    pesp := sm_sp.p[1].pode;
    hepl := sm_pl.h[1].pode;
    hesp := sm_sp.h[1].pode;
    RETURN DATASET([{sec,apl,asp,
                    ppl,psp,hpl,hsp,
                    pepl,pesp,hepl,hesp}],outrec);
END;
// sm1_pl := secmod_n(1,'plain');
// sm1_sp := secmod_n(1,'s&p');
// sm2_pl := secmod_n(2,'plain');
// sm2_sp := secmod_n(2,'s&p');
// sm3_pl := secmod_n(3,'plain');
// sm3_sp := secmod_n(3,'s&p');
// sm4_pl := secmod_n(4,'plain');
// sm4_sp := secmod_n(4,'s&p');
// sm5_pl := secmod_n(5,'plain');
// sm5_sp := secmod_n(5,'s&p');
// sm6_pl := secmod_n(6,'plain');
// sm6_sp := secmod_n(6,'s&p');
// sm7_pl := secmod_n(7,'plain');
// sm7_sp := secmod_n(7,'s&p');
// sm8_pl := secmod_n(8,'plain');
// sm8_sp := secmod_n(8,'s&p');
// sm9_pl := secmod_n(9,'plain');
// sm9_sp := secmod_n(9,'s&p');
// sm10_pl := secmod_n(10,'plain');
// sm10_sp := secmod_n(10,'s&p');
// sm11_pl := secmod_n(11,'plain');
// sm11_sp := secmod_n(11,'s&p');
// sm12_pl := secmod_n(12,'plain');
// sm12_sp := secmod_n(12,'s&p');
// sm13_pl := secmod_n(13,'plain');
// sm13_sp := secmod_n(13,'s&p');

info1 := get_info(1);
info2 := get_info(2);
info3 := get_info(3);
info4 := get_info(4);
info5 := get_info(5);
info6 := get_info(6);
info7 := get_info(7);
info8 := get_info(8);
info9 := get_info(9);
info10 := get_info(10);
info11 := get_info(11);
info12 := get_info(12);
info13 := get_info(13);

final := DATASET([info1[1],info2[1],info3[1],info4[1],
                info5[1],info6[1],info7[1],info8[1],
                info9[1],info10[1],info11[1],info12[1],
                info13[1]],outrec);

OUTPUT(final);