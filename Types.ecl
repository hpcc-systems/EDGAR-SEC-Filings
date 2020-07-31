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

    EXPORT perfrec := RECORD
        UNSIGNED8 sentId;
        STRING fname;
        STRING label;
        STRING text;
        tv.Types.t_Vector vec;
        REAL8 tot_return;
        REAL8 sp_return;
    END;

    EXPORT Entry_fname := RECORD
      UNICODE element;
      UNICODE contextRef;
      UNICODE unitRef;
      UNICODE decimals;
      STRING content;
      STRING fname;
    END;

    EXPORT final_fname_rec := RECORD
      STRING fileName;
      UNICODE accessionNumber;
      //UNICODE     name;
      //UNICODE     filingType;
      UNICODE     filingDate;
      //UNICODE     reportPeriod;
      //UNICODE     is_smallbiz;
      //UNICODE     pubfloat;
    //UNICODE     comsharesout;
      //UNICODE     wellknown;
      //UNICODE     shell;
      //UNICODE     centralidxkey;
      //UNICODE     amendflag;
      //UNICODE     filercat;
      //UNICODE     fyfocus;
      //UNICODE     fpfocus;
      //UNICODE     emerging;
    //UNICODE     ticker;
      //UNICODE     volfilers;
      //UNICODE     currentstat;
      //UNICODE     fyend;
      DATASET(Entry_fname) values;
    END;

    EXPORT secrec := RECORD
        STRING sector;
        STRING filename;
    END;

    EXPORT vecrec := RECORD
        REAL8 value;
    END;

    EXPORT fldrec := RECORD
        UNSIGNED rowid;
        DATASET(vecrec) vecds;
        INTEGER4 label;
    END;

    //FIXME: Currently written out explicitly
    //Consider applying MACRO
    EXPORT nastyrec := RECORD
        UNSIGNED id;REAL8 val1;REAL8 val2;REAL8 val3;REAL8 val4;REAL8 val5;REAL8 val6;REAL8 val7;REAL8 val8;REAL8 val9;REAL8 val10;REAL8 val11;REAL8 val12;REAL8 val13;REAL8 val14;REAL8 val15;REAL8 val16;REAL8 val17;REAL8 val18;REAL8 val19;REAL8 val20;REAL8 val21;REAL8 val22;REAL8 val23;REAL8 val24;REAL8 val25;REAL8 val26;REAL8 val27;REAL8 val28;REAL8 val29;REAL8 val30;REAL8 val31;REAL8 val32;REAL8 val33;REAL8 val34;REAL8 val35;REAL8 val36;REAL8 val37;REAL8 val38;REAL8 val39;REAL8 val40;REAL8 val41;REAL8 val42;REAL8 val43;REAL8 val44;REAL8 val45;REAL8 val46;REAL8 val47;REAL8 val48;REAL8 val49;REAL8 val50;REAL8 val51;REAL8 val52;REAL8 val53;REAL8 val54;REAL8 val55;REAL8 val56;REAL8 val57;REAL8 val58;REAL8 val59;REAL8 val60;REAL8 val61;REAL8 val62;REAL8 val63;REAL8 val64;REAL8 val65;REAL8 val66;REAL8 val67;REAL8 val68;REAL8 val69;REAL8 val70;REAL8 val71;REAL8 val72;REAL8 val73;REAL8 val74;REAL8 val75;REAL8 val76;REAL8 val77;REAL8 val78;REAL8 val79;REAL8 val80;REAL8 val81;REAL8 val82;REAL8 val83;REAL8 val84;REAL8 val85;REAL8 val86;REAL8 val87;REAL8 val88;REAL8 val89;REAL8 val90;REAL8 val91;REAL8 val92;REAL8 val93;REAL8 val94;REAL8 val95;REAL8 val96;REAL8 val97;REAL8 val98;REAL8 val99;REAL8 val100;
        INTEGER4 label;
    END;

END;