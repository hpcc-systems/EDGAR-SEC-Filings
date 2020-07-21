IMPORT TextVectors as tv;
IMPORT tv.Types;

t_Vector := Types.t_Vector;

wrec := RECORD
    STRING word;
    UNSIGNED8 sentId;
    STRING text;
    REAL8 tfidf_score;
    t_Vector w_Vector;
END;


EXPORT rollsets(DATASET(wrec) w) := FUNCTION
    wrec roll_T(wrec l,wrec r) := TRANSFORM
        SELF.w_Vector := l.w_Vector + r.w_Vector;
        SELF := r;
    END;

    out := ROLLUP(w,roll_T(LEFT,RIGHT),sentId,LOCAL)[1].w_Vector;

    RETURN out;
END;