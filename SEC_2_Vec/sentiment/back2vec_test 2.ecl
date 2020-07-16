toyset := [1.1e308,-2.9e11,3.1e-100,-4.2];

multiplyvec((SET OF REAL8) tvec,REAL8 x) := FUNCTION
    dsvec := DATASET(tvec,{REAL8 val});
    dsrec := RECORD
        REAL8 val;
    END;
    dsrec mult_T(dsrec d) := TRANSFORM
        SELF.val := d.val * x;
    END;
    outds := PROJECT(dsvec,mult_T(LEFT));
    RETURN SET(outds,outds.val);
END;

normalvec((SET OF REAL8) tvec) := FUNCTION
    dsvec := DATASET(tvec,{REAL8 val});
    dsrec := RECORD
        REAL8 val;
    END;
    dsrec norm_T(dsrec d) := TRANSFORM
        SELF.val := d.val * d.val;
    END;
    outds := PROJECT(dsvec,norm_T(LEFT));
    normby := 1/SQRT(SUM(outds,outds.val));
    RETURN multiplyvec(tvec,normby);
END;

//mltset := multiplyvec(toyset,3);

OUTPUT(toyset);
//OUTPUT(mltset);
OUTPUT(utils.normalizeVector(toyset));
//OUTPUT(utils.normalizeVector(mltset));