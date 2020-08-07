IMPORT ML_Core;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM SEC_2_Vec.sentiment.tests;
IMPORT * FROM Types;
IMPORT LogisticRegression as LR;

#OPTION('outputLimit',500);

path10k := '~ncf::edgarfilings::raw::all_10k';
path10q := '~ncf::edgarfilings::raw::all_10q';

svl := secvec_input_lbl(path10q,path10k,TRUE,'plain');
dat := sent_model.trndata_wlbl(svl);

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

secmod_n(STRING veclbltype = 'pl_vn',INTEGER n,STRING spliton='filename') := FUNCTION
    
    pl_vn := dat.s[1];
    pl_tf := dat.s[2];

    secn := sectors.sectorlist[n];

    v := CASE(veclbltype, 'pl_vn' => pl_vn, 'pl_tf' => pl_tf, 'sp_vn' => lbljoin(pl_vn), 'sp_tf' => lbljoin(pl_tf));
    pv := v(get_tick(fname) in sectors.ticksn(n));

    dat := traintestsplit(pv,spliton,2);
    dat_secn := dat.trn;
    dat_h := dat.tst;

    ff := sent_model.getFields(dat_secn);

    X := ff.NUMF;
    Y := ff.DSCF;

    h := sent_model.getFields(dat_h);

    Xh := h.NUMF;
    Yh := h.DSCF;

    plainblr := LR.BinomialLogisticRegression();

    mod := plainblr.getModel(X,Y);

    preds := plainblr.Classify(mod,X);
    predsh := plainblr.Classify(mod,Xh);

    podh := ML_Core.Analysis.Classification.Accuracy(predsh,Yh);

    doctrn := docsent(preds,dat_secn);
    doctst := docsent(predsh,dat_h);

    docX := doctrn.docavg;
    docY := doctrn.labtru;
    docXh := doctst.docavg;
    docYh := doctst.labtru;

    docmod := plainblr.getModel(docX,docY);

    docpredsh := plainblr.Classify(docmod,docXh);

    docpodh := ML_Core.Analysis.Classification.Accuracy(docpredsh,docYh);

    result := MODULE
        EXPORT s := secn;
        EXPORT h := podh;
        EXPORT dh := docpodh;
    END;
    RETURN result;
END;

outrec get_info(INTEGER n) := FUNCTION
    pl_vn := secmod_n('pl_vn',n,'filename');
    pl_tf := secmod_n('pl_tf',n,'filename');
    sp_vn := secmod_n('sp_vn',n,'filename');
    sp_tf := secmod_n('sp_tf',n,'filename');
    sec := pl_vn.s;
    pdpv := pl_vn.h[1].pod;
    pepv := pl_vn.h[1].pode;
    ddpv := pl_vn.dh[1].pod;
    depv := pl_vn.dh[1].pode;
    pdpt := pl_tf.h[1].pod;
    pept := pl_tf.h[1].pode;
    ddpt := pl_tf.dh[1].pod;
    dept := pl_tf.dh[1].pode;
    pdsv := sp_vn.h[1].pod;
    pesv := sp_vn.h[1].pode;
    ddsv := sp_vn.dh[1].pod;
    desv := sp_vn.dh[1].pode;
    pdst := sp_tf.h[1].pod;
    pest := sp_tf.h[1].pode;
    ddst := sp_tf.dh[1].pod;
    dest := sp_tf.dh[1].pode;
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