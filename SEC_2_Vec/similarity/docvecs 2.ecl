IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT TextVectors as tv;
IMPORT * from tv.internal.svutils;
t_Vector := tv.types.t_vector;

path := '~ncf::edgarfilings::raw::labels_allsecs_all';

tdwl := sentiment.sent_model.trndata_wlbl(path,TRUE,'s&p');

tdwl_vn := tdwl[1];
tdwl_tf := tdwl[2];

trndatarec := RECORDOF(tdwl_tf);

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

fnamesds := DEDUP(tdwl_tf,tdwl_tf.fname);
fnames := SET(fnamesds,fnamesds.fname);

namea := fnames[1];
nameb := fnames[2];

absim_vn := docsim(tdwl_vn(fname=namea),tdwl_vn(fname=nameb));
absim_tf := docsim(tdwl_tf(fname=namea),tdwl_tf(fname=nameb));

OUTPUT(tdwl_vn,ALL,NAMED('vanilla'));
OUTPUT(tdwl_tf,ALL,NAMED('tfidf'));
OUTPUT(absim_vn,NAMED('vanilla_sim_doc_1_2'));
OUTPUT(absim_tf,NAMED('tfidf_sim_doc_1_2'));
OUTPUT(namea,NAMED('name1'));
OUTPUT(nameb,NAMED('name2'));