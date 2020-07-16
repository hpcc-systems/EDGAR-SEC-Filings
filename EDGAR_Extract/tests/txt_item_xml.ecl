xmlrec := RECORD
    STRING filename;
    STRING text;
END;

ds := DATASET(WORKUNIT('W20200712-204805','Result 1'),xmlrec);

//xmlt := ds[1].text;

//LOADXML(xmlt);
spanrec := RECORD
    UNICODE element;
    UNICODE spantxt;
END;

dsspanrec := RECORD
    DATASET(spanrec) entry;
END;

spanrec getspan(UNICODE element) := TRANSFORM
    SELF.element := element;
    SELF.spantxt := XMLUNICODE('');
END;

dsspanrec parse_xmltxt(xmlrec xr) := TRANSFORM
    SELF.entry := XMLPROJECT('ix::NonNumeric',getspan('ix::NonNumeric'));
END;

EXPORT txt_item_xml := PARSE(ds,text,parse_xmltxt(LEFT),XML('lxml'));