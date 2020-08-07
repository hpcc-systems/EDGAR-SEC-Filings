IMPORT STD;
IMPORT * FROM EDGAR_Extract;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM Types;

EXPORT lbljoin(DATASET(trainrec) dset) := FUNCTION
    path10q := '~ncf::edgarfilings::supp::sandplabels_10q';
    path10k := '~ncf::edgarfilings::supp::sandplabels_10k';

    csvrec := RECORD
        STRING plainname;
        STRING spname;
    END;

    draw10q := DATASET(path10q,csvrec,CSV(HEADING(1)));
    draw10k := DATASET(path10k,csvrec,CSV(HEADING(1)));

    draws := draw10q+draw10k;

    cj := JOIN(dset,draws,LEFT.fname=RIGHT.plainname,TRANSFORM(trainrec,
                                                    SELF.fname := RIGHT.spname,
                                                    SELF.label := get_label(RIGHT.spname),
                                                    SELF := LEFT));

    RETURN cj;
END;