IMPORT * FROM Types;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT LearningTrees as LT;
IMPORT LogisticRegression as LR;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM SEC_2_Vec.sentiment.tests;
IMPORT ML_Core;
IMPORT ML_Core.Analysis.Classification as ml_ac;

#OPTION('outputLimit',500)

path10k := '~ncf::edgarfilings::raw::all_10k';
path10q := '~ncf::edgarfilings::raw::all_10q';

svl := secvec_input_lbl(path10q,path10k,TRUE,'plain');
dat := sent_model.trndata_wlbl(svl);

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

secmod_n(STRING veclbltype = 'pl_vn',INTEGER n,STRING spliton='ticker',STRING mtyp='BLR') := FUNCTION
    pl_vn := dat.s[1];
    pl_tf := dat.s[2];

    secn := sectors.sectorlist[n];

    v := CASE(veclbltype, 'pl_vn' => pl_vn, 'pl_tf' => pl_tf, 'sp_vn' => lbljoin(pl_vn), 'sp_tf' => lbljoin(pl_tf));
    pv := v(get_tick(fname) in sectors.ticksn(n));

    dat_all := doc_model(pv);
    dat := traintestsplit(dat_all,spliton,2);

    dat_trn := dat.trn;
    dat_tst := dat.tst;

    ff := sent_model.getFields(dat_trn);
    ff_tst := sent_model.getFields(dat_tst);

    X := ff.NUMF;
    Y := ff.DSCF;
    Xh := ff_tst.NUMF;
    Yh := ff_tst.DSCF;

    plainblr := LR.BinomialLogisticRegression();
    CF := LT.ClassificationForest();

    modtyp := IF(mtyp='BLR',plainblr,CF);

    mod := modtyp.GetModel(X,Y);

    preds := modtyp.Classify(mod,X);
    predsh := modtyp.Classify(mod,Xh);

    pod := ml_ac.Accuracy(preds,Y);
    podh := ml_ac.Accuracy(predsh,Yh);

    result := MODULE
        EXPORT p_in := pod[1].pod;
        EXPORT pe_in := pod[1].pode;
        EXPORT p_out := podh[1].pod;
        EXPORT pe_out := podh[1].pode;
    END;

    RETURN result;
END;

outrec get_info(INTEGER n) := FUNCTION
    sec := sectors.sectorlist[n];
    pl_vn := secmod_n('pl_vn',n,'ticker');
    pl_tf := secmod_n('pl_tf',n,'ticker');
    sp_vn := secmod_n('sp_vn',n,'ticker');
    sp_tf := secmod_n('sp_tf',n,'ticker');
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