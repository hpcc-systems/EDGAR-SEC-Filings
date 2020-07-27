IMPORT TextVectors as tv;

EXPORT Types := MODULE

    EXPORT trainrec := RECORD
        tv.Types.t_TextId id;
        tv.Types.t_Sentence text;
        tv.Types.t_Vector vec;
        STRING label;
        STRING fname;
    END;

    EXPORT sveclblrec := RECORD
        UNSIGNED8 sentId;
        STRING text;
        STRING label;
        STRING fname;
    END;
    
    EXPORT normrec := RECORD
        STRING word;
        UNSIGNED8 sentId;
        STRING text;
    END;

    EXPORT wrec := RECORD
        STRING word;
        UNSIGNED8 sentId;
        STRING text;
        REAL8 tfidf_score;
        tv.Types.t_Vector w_Vector;
    END;

    EXPORT optrec := RECORD
        UNSIGNED8 sentId;
        STRING text;
        tv.Types.t_Vector w_Vector;
    END;

END;