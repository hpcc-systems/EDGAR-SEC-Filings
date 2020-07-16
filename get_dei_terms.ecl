IMPORT STD;
IMPORT EDGAR_Extract;
IMPORT * FROM EDGAR_Extract;

path := '~ncf::edgarfilings::raw::labels_allsecs_all';
rawf := Raw_Input_Files.Files(path);

pattern mess := ANY NOT IN ['<','>'];
pattern lcase := PATTERN('[a-z]');
pattern ucase := PATTERN('[A-Z]');
pattern propercase := ucase lcase*;
pattern field_name := propercase* 'TextBlock';
pattern tagnames := 'dei'|'us-gaap'|'a';
pattern eltag := tagnames ':' field_name;
pattern tagform := '<' eltag mess* '>';
rule tagblk := tagform;

outrec := RECORD
    STRING parsed_tag := MATCHTEXT(tagform/eltag);
END;

dsa := DATASET([{1},{2},{3}],{INTEGER val});
dsb := DATASET([{4},{2},{7}],{INTEGER val});

//mer := COMBINE(dsa,dsb);
mer := MERGE([dsa,dsb],val);

out := DEDUP(SORT(PARSE(rawf,text,tagblk,outrec),parsed_tag));

OUTPUT(STD.Str.SplitWords(rawf[1].filename, '_', FALSE)[1]);
OUTPUT(rawf[1].filename);
OUTPUT(out,ALL);
OUTPUT(mer);