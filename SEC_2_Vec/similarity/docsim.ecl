IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
IMPORT TextVectors as tv;
IMPORT * FROM tv.internal.svUtils;
IMPORT * FROM Types;

t_Vector := tv.Types.t_Vector;

EXPORT REAL8 docsim(DATASET(trainrec) doca,DATASET(trainrec) docb,STRING method='add') := FUNCTION

    midrec := RECORD
        REAL8 simval;
    END;

    outrec := RECORD
        INTEGER numsims;
        REAL8   sumsims;
    END;

    outrec_prod := RECORD
        INTEGER numsims;
        REAL8   comsims;
    END;

    midrec finish_sim_T(trainrec a,t_Vector vecb) := TRANSFORM
        SELF.simval := cosineSim(a.vec,vecb,100);
    END;

    midrec iter_prod_T(midrec ml,midrec mr,INTEGER C) := TRANSFORM
        SELF.simval := IF(C=1,mr.simval,ml.simval*mr.simval);
    END;

    outrec_prod start_sim_T(trainrec b,DATASET(trainrec) a) := TRANSFORM
        SELF.numsims := COUNT(a);
        helperds := PROJECT(a,finish_sim_T(LEFT,b.vec));
        SELF.comsims := IF(method='add',
                SUM(helperds,helperds.simval),
                ITERATE(helperds,iter_prod_T(LEFT,RIGHT,COUNTER))[SELF.numsims].simval);
    END;

    out := PROJECT(docb,start_sim_T(LEFT,doca));
    c := COUNT(out);

    outrec_prod iter_prod_outT(outrec_prod otl,outrec_prod otr,INTEGER C) := TRANSFORM
        SELF.numsims := otr.numsims;
        SELF.comsims := IF(C=1,otr.comsims,otl.comsims*otr.comsims);
    END;

    com := IF(method='add',SUM(out,out.comsims),
                           ITERATE(out,iter_prod_outT(LEFT,RIGHT,COUNTER))[c].comsims);
    num := SUM(out,out.numsims);

    RETURN IF(method='add',com/num,POWER(com,1/num));
END;