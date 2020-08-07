IMPORT STD;
IMPORT * FROM EDGAR_Extract;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT * FROM Types;

mainrec := EDGAR_Extract.Extract_Layout_modified.Main;

EXPORT secvec_input_lbl(STRING inpath10q,STRING inpath10k,BOOLEAN prelabeled=TRUE,STRING comparedto='plain') := FUNCTION

    start10q := XBRL_HTML_File(inpath10q);
    start10k := XBRL_HTML_File(inpath10k);

    strec := RECORDOF(start10q);
    
    compjoin(DATASET(strec) stq,DATASET(strec) stk) := FUNCTION
      path10q := '~ncf::edgarfilings::supp::sandplabels_10q';
      path10k := '~ncf::edgarfilings::supp::sandplabels_10k';

      csvrec := RECORD
        STRING plainname;
        STRING spname;
      END;
      
      draw10q := DATASET(path10q,csvrec,CSV(HEADING(1)));
      draw10k := DATASET(path10k,csvrec,CSV(HEADING(1)));

      cj10q := JOIN(stq,draw10q,LEFT.filename = RIGHT.plainname,TRANSFORM(RECORDOF(stq),SELF.filename:=RIGHT.spname,SELF:=LEFT));
      cj10k := JOIN(stk,draw10k,LEFT.filename = RIGHT.plainname,TRANSFORM(RECORDOF(stk),SELF.filename:=RIGHT.spname,SELF:=LEFT));
      
      cj := cj10q + cj10k;

      RETURN cj;
    END;
    
    plain := IF(comparedto='plain',start10q+start10k,compjoin(start10q,start10k));

    STRING addfakelabels(STRING inName,STRING strlbl) := FUNCTION
        splitname := STD.Str.SplitWords(inName, '_', FALSE);
        ftwx_fakelabel := '10q_'+strlbl+'.xml';
        newname := splitname[1]+'_'+splitname[2]+'_'+ftwx_fakelabel;
        RETURN newname;
    END;

    Extract_Layout_modified.Main lblT(Extract_Layout_modified.Main r,INTEGER C) := TRANSFORM
        cntx := C%2;
        fakelabel := (STRING) cntx;
        SELF.fileName := addfakelabels(r.fileName,fakelabel);
        SELF.accessionNumber := r.accessionNumber;
        //SELF.name := r.name;
        //SELF.filingType := r.filingType;
        SELF.filingDate := r.filingDate;
        //SELF.reportPeriod := r.reportPeriod;
        //SELF.is_smallbiz := r.is_smallbiz;
        //SELF.pubfloat := r.pubfloat;
        //SELF.wellknown := r.wellknown;
        //SELF.shell := r.shell;
        //SELF.centralidxkey := r.centralidxkey;
        //SELF.amendflag := r.amendflag;
        //SELF.filercat := r.filercat;
        //SELF.fyfocus := r.fyfocus;
        //SELF.fpfocus := r.fpfocus;
        //SELF.emerging := r.emerging;
        //SELF.volfilers := r.volfilers;
        //SELF.currentstat := r.currentstat;
        //SELF.fyend := r.fyend;
        SELF.values := r.values;    
    END;
    
    ds := IF(prelabeled,label_filings(plain),label_filings(PROJECT(plain,lblT(LEFT,COUNTER))));

    Entry_wlabel augment_entry(label_rec bigrow,Extract_Layout_modified.Entry_clean r) := TRANSFORM
      SELF.element := r.element;
      SELF.contextRef := r.contextRef;
      SELF.unitRef := r.unitRef;
      SELF.decimals := r.decimals;
      SELF.content := r.content;
      SELF.label := bigrow.label;
      SELF.fname := bigrow.fileName;
    END;

    final_label_rec apply_augment(RECORDOF(ds) f) := TRANSFORM
      SELF.fileName := f.fileName;
      SELF.accessionNumber := f.accessionNumber;
      //SELF.name := f.name;
      //SELF.filingType := f.filingType;
      SELF.filingDate := f.filingDate;
      //SELF.reportPeriod := f.reportPeriod;
      //SELF.is_smallbiz := f.is_smallbiz;
      //SELF.pubfloat := f.pubfloat;
      //SELF.wellknown := f.wellknown;
      //SELF.shell := f.shell;
      //SELF.centralidxkey := f.centralidxkey;
      //SELF.amendflag := f.amendflag;
      //SELF.filercat := f.filercat;
      //SELF.fyfocus := f.fyfocus;
      //SELF.fpfocus := f.fpfocus;
      //SELF.emerging := f.emerging;
      //SELF.volfilers := f.volfilers;
      //SELF.currentstat := f.currentstat;
      //SELF.fyend := f.fyend;
      SELF.values := PROJECT(f.values,augment_entry(f,LEFT));
    END;

    labelds := PROJECT(ds,apply_augment(LEFT));

    textblocks(UNICODE el) := el IN [
        'us-gaap:QuarterlyFinancialInformationTextBlock',
        'us-gaap:AdditionalFinancialInformationTextBlock',
        'us-gaap:BasisOfPresentationAndSignificantAccountingPoliciesTextBlock',
        'us-gaap:CommitmentsAndContingenciesDisclosureTextBlock',
        'us-gaap:CashAndCashEquivalentsPolicyTextBlock'
    ];

    tb := labelds.values(textblocks(element));

    outrec := RECORD
      STRING text := tb.content;
      STRING label := tb.label;
      STRING fname := tb.fname;
    END;

    testtextvec_input_lbl := sep_sents_lbl(lblConcat(TABLE(tb,outrec)));
    

    RETURN testtextvec_input_lbl;
END;