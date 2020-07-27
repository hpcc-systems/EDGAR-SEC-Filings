IMPORT STD;
IMPORT * FROM EDGAR_Extract;
IMPORT SEC_2_Vec;
IMPORT * FROM EDGAR_Extract.Text_Tools;

#OPTION('outputLimit',1000);

path10k := '~ncf::edgarfilings::raw::labels_allsecs_all_10k';
path10q := '~ncf::edgarfilings::raw::plainlabel_allsecs_all';

docs10k := Text_tools.XBRL_HTML_File(path10k);
docs10q := Text_tools.XBRL_HTML_File(path10q);

tickrec := RECORD
    STRING ticker;
END;

ticksk := PROJECT(docs10k,TRANSFORM(tickrec,SELF.ticker := get_tick(LEFT.filename)));
ticksq := PROJECT(docs10q,TRANSFORM(tickrec,SELF.ticker := get_tick(LEFT.filename)));

set_ticksq := SET(ticksq,ticksq.ticker);

ticks := ticksk(ticker IN set_ticksq);

// shared10k := docs10k(get_tick(filename) IN ticks);
// shared10q := docs10q(get_tick(filename) IN ticks);

// docs := SORT(shared10k+shared10q,filename);

OUTPUT(ticks,ALL);
OUTPUT(docs10k,ALL);
OUTPUT(docs10q,ALL);