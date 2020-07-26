IMPORT ML_Core;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM SEC_2_Vec.sentiment.tests;

#OPTION('outputLimit',500);

sam := sents_and_mod;
model := sam.m;
sents := sam.p;

pl_vn := sam.t;
pl_tf := tfidf_experimental(model(typ=1),sents,100,1);
sp_vn := lbljoin(pl_vn);
sp_tf := lbljoin(pl_tf);

outrec := RECORD
    STRING sector;
    REAL8 hpod_plvn;
    REAL8 hpode_plvn;
    REAL8 dochpod_plvn;
    REAL8 dochpode_plvn;
    REAL8 hpod_pltf;
    REAL8 hpode_pltf;
    REAL8 dochpod_pltf;
    REAL8 dochpode_pltf;
    REAL8 hpod_spvn;
    REAL8 hpode_spvn;
    REAL8 dochpod_spvn;
    REAL8 dochpode_spvn;
    REAL8 hpod_sptf;
    REAL8 hpode_sptf;
    REAL8 dochpod_sptf;
    REAL8 dochpode_sptf;
END;

outrec get_info(INTEGER n) := TRANSFORM
    s := bothlbl_secmod_n(pl_vn,pl_tf,sp_vn,sp_tf,n,'filename');
    SELF.sector := s.s;
    SELF.hpod_plvn := s.h1[1].pod;
    SELF.hpode_plvn := s.h1[1].pode;
    SELF.dochpod_plvn := s.dh1[1].pod;
    SELF.dochpode_plvn := s.dh1[1].pode;
    SELF.hpod_pltf := s.h2[1].pod;
    SELF.hpode_pltf := s.h2[1].pode;
    SELF.dochpod_pltf := s.dh2[1].pod;
    SELF.dochpode_pltf := s.dh2[1].pode;
    SELF.hpod_spvn := s.h3[1].pod;
    SELF.hpode_spvn := s.h3[1].pode;
    SELF.dochpod_spvn := s.dh3[1].pod;
    SELF.dochpode_spvn := s.dh3[1].pode;
    SELF.hpod_sptf := s.h4[1].pod;
    SELF.hpode_sptf := s.h4[1].pode;
    SELF.dochpod_sptf := s.dh4[1].pod;
    SELF.dochpode_sptf := s.dh4[1].pode;
END;

// info1 := get_info(1);
// info2 := get_info(2);
// info3 := get_info(3);
// info4 := get_info(4);
// info5 := get_info(5);
// info6 := get_info(6);
// info7 := get_info(7);
// info8 := get_info(8);
// info9 := get_info(9);
// info10 := get_info(10);
// info11 := get_info(11);
// info12 := get_info(12);
// info13 := get_info(13);

// final := DATASET([info1[1],info2[1],info3[1],info4[1],
//                 info5[1],info6[1],info7[1],info8[1],
//                 info9[1],info10[1],info11[1],info12[1],
//                 info13[1]],outrec);

final := DATASET(13,get_info(COUNTER));

OUTPUT(final);