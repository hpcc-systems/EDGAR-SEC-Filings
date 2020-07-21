IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT TextVectors as tv;
IMPORT * from tv.internal.svutils;
t_Vector := tv.types.t_vector;
trec := sent_model.trainrec;

#OPTION('outputLimit',1000);

//path := '~ncf::edgarfilings::raw::labels_allsecs_all';

//tdwl := sentiment.sent_model.trndata_wlbl(path,TRUE,'s&p');
//tdwl := sentiment.sent_model.

sandplblvn := DATASET(WORKUNIT('W20200712-194048','sandp_label_vanilla_data'),trec);

// path10k := '~ncf::edgarfilings::raw::labels_allsecs_all_10k';
// path10q := '~ncf::edgarfilings::raw::plainlabel_allsecs_all';

// splblsents := SORT(secvec_input_lbl(path10q,path10k,TRUE,'s&p'),fname);

// sandplblvn := sent_model.trn10q10klbl_van(splblsents);


tdwl_vn := sandplblvn;//tdwl[1];
//tdwl_tf := tdwl[2];

trndatarec := RECORDOF(tdwl_vn);

midrec := RECORD
    REAL8 simval;
END;

outrec := RECORD
    INTEGER numsims;
    REAL8   sumsims;
END;

//outrec docsim(DATASET(trndatarec) doca,t_vector vecb) := FUNCTION
REAL8 docsim(DATASET(trndatarec) doca,DATASET(trndatarec) docb) := FUNCTION


    midrec finish_sim_T(trndatarec a,t_Vector vecb) := TRANSFORM
        SELF.simval := cosineSim(a.vec,vecb,100);
    END;

    outrec start_sim_T(trndatarec b,DATASET(trndatarec) a) := TRANSFORM
        SELF.numsims := COUNT(a);
        helperds := PROJECT(a,finish_sim_T(LEFT,b.vec));
        SELF.sumsims := SUM(helperds,helperds.simval);
    END;

    out := PROJECT(docb,start_sim_T(LEFT,doca));

    tot := SUM(out,out.sumsims);
    num := SUM(out,out.numsims);

    RETURN tot/num;
END;

fnamesds := DEDUP(tdwl_vn,tdwl_vn.fname);
fnames := SET(fnamesds,fnamesds.fname);

namea := fnames[4];
nameb := fnames[5];

absim_vn := docsim(tdwl_vn(fname=namea),tdwl_vn(fname=nameb));
//absim_tf := docsim(tdwl_tf(fname=namea),tdwl_tf(fname=nameb));


OUTPUT(tdwl_vn,ALL,NAMED('vanilla'));
//OUTPUT(tdwl_tf,ALL,NAMED('tfidf'));
OUTPUT(absim_vn,NAMED('vanilla_sim_doc_1_2'));
//OUTPUT(absim_tf,NAMED('tfidf_sim_doc_1_2'));
OUTPUT(namea,NAMED('name1'));
OUTPUT(nameb,NAMED('name2'));