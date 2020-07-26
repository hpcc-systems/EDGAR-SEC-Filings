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

END;