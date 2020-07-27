IMPORT * FROM Types;
IMPORT LogisticRegression as LR;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM SEC_2_Vec.sentiment.tests;
IMPORT ML_Core;
IMPORT ML_Core.Analysis.Classification as ml_ac;

outrec := RECORD
    STRING sector;
    REAL8 vn_pod;
    REAL8 vn_pode;
    REAL8 tf_pod;
    REAL8 tf_pode;
    REAL8 spvn_pod;
    REAL8 spvn_pode;
    REAL8 sptf_pod;
    REAL8 sptf_pode;
    REAL8 vnh_pod;
    REAL8 vnh_pode;
    REAL8 tfh_pod;
    REAL8 tfh_pode;
    REAL8 spvnh_pod;
    REAL8 spvnh_pode;
    REAL8 sptfh_pod;
    REAL8 sptfh_pode;
END;

outrec get_info(INTEGER n) := FUNCTION
    sec := sectors.sectorlist[n];
    pl_vn := doc_secmod_n('pl_vn',n,'ticker');
    pl_tf := doc_secmod_n('pl_tf',n,'ticker');
    sp_vn := doc_secmod_n('sp_vn',n,'ticker');
    sp_tf := doc_secmod_n('sp_tf',n,'ticker');
    vnpd := pl_vn.p_in;
    vnpe := pl_vn.pe_in;
    tfpd := pl_tf.p_in;
    tfpe := pl_tf.pe_in;
    svpd := sp_vn.p_in;
    svpe := sp_vn.pe_in;
    stpd := sp_tf.p_in;
    stpe := sp_tf.pe_in;
    vhpd := pl_vn.p_out;
    vhpe := pl_vn.pe_out;
    thpd := pl_tf.p_out;
    thpe := pl_tf.pe_out;
    shpd := sp_vn.p_out;
    shpe := sp_vn.pe_out;
    phpd := sp_tf.p_out;
    phpe := sp_tf.pe_out;

    RETURN DATASET([{sec,
        vnpd,vnpe,tfpd,tfpe,
        svpd,svpe,stpd,stpe,
        vhpd,vhpe,thpd,thpe,
        shpd,shpe,phpd,phpe}],outrec);
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