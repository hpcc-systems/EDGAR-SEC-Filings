IMPORT * FROM EDGAR_Extract.Text_Tools;

//contains utilities for filtering by
//sector or listing the sectors in
//the dataset.
//
//INITIALIZED DATASETS:
// sectorticker (a dataset of
// all unique sector-ticker pairs)
// sectorlist (a set of all sectors)
// ticksn() (a set of tickers in
// the given sector)

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

    EXPORT ticksn(INTEGER n) := FUNCTION
        secn := sectorlist[n];
        ticksinsec := sectorticker(sector=secn);
        RETURN SET(ticksinsec,ticksinsec.ticker);
    END;
END;