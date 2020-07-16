#OPTION('outputLimit',100);

xmlrec := RECORD
    STRING filename;
    STRING text;
END;

ds := DATASET(WORKUNIT('W20200712-204805','Result 1'),xmlrec);

pattern alphalo := '[a-z]';
pattern alphahi := '[A-Z]';
pattern guts := (ANY NOT IN ['<','>']);
pattern tagopn := '<' guts* '>';
pattern tagcls := '<\'' guts* '>';
pattern layer := tagopn guts*;
pattern layerout := guts* tagcls;
pattern itmtag := tagopn guts* 'ITEM ' layerout;
rule itemrow := itmtag;

outrec := RECORD
    UNICODE txtrow := MATCHUNICODE(itmtag);
END;

//out := PARSE(ds,text,itemrow,TRANSFORM(outrec,SELF.txtrow := MATCHUNICODE(itmtag)));
out := PARSE(ds,text,itemrow,outrec);


//OUTPUT(ds);
OUTPUT(out);