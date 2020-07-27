IMPORT ML_Core;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM SEC_2_Vec.sentiment.tests;
IMPORT * FROM Types;

#OPTION('outputLimit',500);

pl_vn := DATASET(WORKUNIT('W20200726-092906','plain_vanilla'),trainrec);
pl_tf := DATASET(WORKUNIT('W20200726-092906','plain_tfidf'),trainrec);

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

final := DATASET(13,get_info(COUNTER));

OUTPUT(final);