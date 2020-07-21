IMPORT * FROM EDGAR_Extract.Text_Tools;

EXPORT sectors := MODULE
    EXPORT secrec := RECORD
        STRING sector;
        STRING filename;
    END;

    EXPORT sectorticker := FUNCTION
        path := '~ncf::edgarfilings::supp::sector_guide_all';

        ds_all := DATASET(path,secrec,CSV(HEADING(1)));
        ds := ds_all(filename!='.DS_Store');

        outrec := RECORD
            STRING sector := ds.sector;
            STRING ticker := get_tick(ds.filename);
        END;

        out := DEDUP(SORT(TABLE(ds,outrec),ticker),ticker);

        RETURN out;
    END;

    EXPORT sectorlist := FUNCTION
        bysec := SORT(sectorticker,sector);
        uniqs := DEDUP(bysec,sector);
        out := SET(uniqs,uniqs.sector);
        RETURN out;
    END;
END;