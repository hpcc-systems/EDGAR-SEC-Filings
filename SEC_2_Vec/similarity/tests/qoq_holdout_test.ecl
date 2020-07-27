IMPORT ML_Core;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM SEC_2_Vec.similarity;
IMPORT * FROM SEC_2_Vec.sentiment.tests;

#OPTION('outputLimit',500);

outrec := RECORD
    STRING sector;
    REAL8 plvn_pod;
    REAL8 plvn_pode;
    REAL8 pltf_pod;
    REAL8 pltf_pode;
    REAL8 spvn_pod;
    REAL8 spvn_pode;
    REAL8 sptf_pod;
    REAL8 sptf_pode;
END;

outrec get_info(INTEGER n) := FUNCTION
    pl_vn := qoq_secmod_n('pl_vn',n,'multiply');
    pl_tf := qoq_secmod_n('pl_tf',n,'multiply');
    sp_vn := qoq_secmod_n('sp_vn',n,'multiply');
    sp_tf := qoq_secmod_n('sp_tf',n,'multiply');
    sec := sectors.sectorlist[n];
    pdpv := pl_vn.p;
    pepv := pl_vn.pe;
    pdpt := pl_tf.p;
    pept := pl_tf.pe;
    pdsv := sp_vn.p;
    pesv := sp_vn.pe;
    pdst := sp_tf.p;
    pest := sp_tf.pe;

    RETURN DATASET([{sec,pdpv,pepv,pdpt,pept,pdsv,pesv,pdst,pest}],outrec);
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