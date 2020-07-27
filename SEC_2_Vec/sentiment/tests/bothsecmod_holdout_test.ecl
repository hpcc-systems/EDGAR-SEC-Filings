IMPORT ML_Core;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM SEC_2_Vec.sentiment.tests;

#OPTION('outputLimit',500);

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

outrec get_info(INTEGER n) := FUNCTION
    pl_vn := bothlbl_secmod_n('pl_vn',n,'filename');
    pl_tf := bothlbl_secmod_n('pl_tf',n,'filename');
    sp_vn := bothlbl_secmod_n('sp_vn',n,'filename');
    sp_tf := bothlbl_secmod_n('sp_tf',n,'filename');
//     SELF.sector := pl_vn.s;
    sec := pl_vn.s;
    pdpv := pl_vn.h[1].pod;
    pepv := pl_vn.h[1].pode;
    ddpv := pl_vn.dh[1].pod;
    depv := pl_vn.dh[1].pode;
//     SELF.hpod_plvn := pl_vn.h[1].pod;
//     SELF.hpode_plvn := pl_vn.h[1].pode;
//     SELF.dochpod_plvn := pl_vn.dh[1].pod;
//     SELF.dochpode_plvn := pl_vn.dh[1].pode;
    pdpt := pl_tf.h[1].pod;
    pept := pl_tf.h[1].pode;
    ddpt := pl_tf.dh[1].pod;
    dept := pl_tf.dh[1].pode;
//     SELF.hpod_pltf := pl_tf.h[1].pod;
//     SELF.hpode_pltf := pl_tf.h[1].pode;
//     SELF.dochpod_pltf := pl_tf.dh[1].pod;
//     SELF.dochpode_pltf := pl_tf.dh[1].pode;
    pdsv := sp_vn.h[1].pod;
    pesv := sp_vn.h[1].pode;
    ddsv := sp_vn.dh[1].pod;
    desv := sp_vn.dh[1].pode;
//     SELF.hpod_spvn := sp_vn.h[1].pod;
//     SELF.hpode_spvn := sp_vn.h[1].pode;
//     SELF.dochpod_spvn := sp_vn.dh[1].pod;
//     SELF.dochpode_spvn := sp_vn.dh[1].pode;
    pdst := sp_tf.h[1].pod;
    pest := sp_tf.h[1].pode;
    ddst := sp_tf.dh[1].pod;
    dest := sp_tf.dh[1].pode;
//     SELF.hpod_sptf := sp_tf.h[1].pod;
//     SELF.hpode_sptf := sp_tf.h[1].pode;
//     SELF.dochpod_sptf := sp_tf.dh[1].pod;
//     SELF.dochpode_sptf := sp_tf.dh[1].pode;
    RETURN DATASET([{sec,
                pdpv,pepv,ddpv,depv,
                pdpt,pept,ddpt,dept,
                pdsv,pesv,ddsv,desv,
                pdst,pest,ddst,dest}],outrec);
END;

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