IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
IMPORT TextVectors as tv;
IMPORT * FROM tv.internal.svUtils;

t_Vector := tv.Types.t_Vector;
trainrec := sentiment.sent_model.trainrec;

EXPORT REAL8 docsim(DATASET(trainrec) doca,DATASET(trainrec) docb) := FUNCTION

    midrec := RECORD
        REAL8 simval;
    END;

    outrec := RECORD
        INTEGER numsims;
        REAL8   sumsims;
    END;

    midrec finish_sim_T(trainrec a,t_Vector vecb) := TRANSFORM
        SELF.simval := POWER(cosineSim(a.vec,vecb,100),3.0);
    END;

    outrec start_sim_T(trainrec b,DATASET(trainrec) a) := TRANSFORM
        SELF.numsims := COUNT(a);
        helperds := PROJECT(a,finish_sim_T(LEFT,b.vec));
        SELF.sumsims := SUM(helperds,helperds.simval);
    END;

    out := PROJECT(docb,start_sim_T(LEFT,doca));

    tot := SUM(out,out.sumsims);
    num := SUM(out,out.numsims);

    RETURN tot/num;
END;