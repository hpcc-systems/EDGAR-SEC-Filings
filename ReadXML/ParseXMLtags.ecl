xflat := DATASET('~ncf::edgarfilings::raw::aapl_20180929.xml',{STRING10000 words},CSV);
pattern alpha := PATTERN('[A-Za-zA-Za-z]')+;
pattern tag   := PATTERN('[-\t a-zA-Z]')+ NOT IN ['xbrli','xbrldi'];
pattern typ   := alpha+;
pattern ws    := PATTERN(' ');

pattern maintag:='<' tag ':' typ ws;
rule opentag:=maintag;

outrec := RECORD
    STRING Opener:=MATCHTEXT(maintag/tag);
    STRING DocumentType:=MATCHTEXT(maintag/typ);
END;

ParseXMLtags := PARSE(xflat,words,opentag,outrec,SCAN ALL);
OUTPUT(DEDUP(ParseXMLtags,ALL),ALL);