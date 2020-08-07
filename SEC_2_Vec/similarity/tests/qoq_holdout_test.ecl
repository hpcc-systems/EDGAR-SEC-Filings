IMPORT ML_Core;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT LogisticRegression as LR;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM SEC_2_Vec.similarity;
IMPORT * FROM SEC_2_Vec.sentiment.tests;

#OPTION('outputLimit',500);

path10k := '~ncf::edgarfilings::raw::all_10k';
path10q := '~ncf::edgarfilings::raw::all_10q';

svl := secvec_input_lbl(path10q,path10k,TRUE,'plain');
dat := sent_model.trndata_wlbl(svl);

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

secmod_n(STRING veclbltype = 'pl_vn',INTEGER n,STRING method='add') := FUNCTION
    pl_vn := dat.s[1];
    pl_tf := dat.s[2];
    secn := sectors.sectorlist[n];
    v := CASE(veclbltype, 'pl_vn' => pl_vn, 'pl_tf' => pl_tf, 'sp_vn' => lbljoin(pl_vn), 'sp_tf' => lbljoin(pl_tf));
    pv := v(get_tick(fname) in sectors.ticksn(n));

    dat := traintestsplit(pv,'ticker',2);
    dat_secn := dat.trn;
    dat_h := dat.tst;

    sl_secn := simlabs(dat_secn,method);
    sl_h := simlabs(dat_h,method);

    sal_secn := sl_secn.sim_and_labels(similarity!=-1.0);
    sal_h := sl_h.sim_and_labels(similarity!=-1.0);

    ff_secn := sl_secn.getFields(sal_secn);
    ff_h := sl_h.getFields(sal_h);

    Xtrn := ff_secn.x;
    Ytrn := ff_secn.y;

    Xtst := ff_h.x;
    Ytst := ff_h.y;

    plainblr := LR.BinomialLogisticRegression();

    mod := plainblr.getmodel(Xtrn,Ytrn);
    predsh := plainblr.Classify(mod,Xtst);

    pod := ML_Core.Analysis.Classification.Accuracy(predsh,Ytst);

    result := MODULE
        EXPORT p := pod[1].pod;
        EXPORT pe := pod[1].pode;
        EXPORT s := sal_secn;
        EXPORT sh := sal_h; 
    END;
    RETURN result;
END;

outrec get_info(INTEGER n) := FUNCTION
    pl_vn := secmod_n('pl_vn',n,'multiply');
    pl_tf := secmod_n('pl_tf',n,'multiply');
    sp_vn := secmod_n('sp_vn',n,'multiply');
    sp_tf := secmod_n('sp_tf',n,'multiply');
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