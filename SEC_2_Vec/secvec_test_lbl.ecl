IMPORT STD;
IMPORT * FROM EDGAR_Extract;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT * FROM Types;
mainrec := EDGAR_Extract.Extract_Layout_modified.Main;

EXPORT DATASET(sveclblrec) secvec_test_lbl(STRING inpath10q) := FUNCTION

    start10q := XBRL_HTML_File(inpath10q);

    strec := RECORDOF(start10q);

    Entry_fname augment_entry(mainrec bigrow,Extract_Layout_modified.Entry_clean r) := TRANSFORM
      SELF.element := r.element;
      SELF.contextRef := r.contextRef;
      SELF.unitRef := r.unitRef;
      SELF.decimals := r.decimals;
      SELF.content := r.content;
      SELF.fname := bigrow.fileName;
    END;

    final_fname_rec apply_augment(strec f) := TRANSFORM
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

    fnameds := PROJECT(start10q,apply_augment(LEFT));

    textblocks(UNICODE el) := el IN [
        'us-gaap:QuarterlyFinancialInformationTextBlock',
        'us-gaap:AdditionalFinancialInformationTextBlock',
        'us-gaap:BasisOfPresentationAndSignificantAccountingPoliciesTextBlock',
        'us-gaap:CommitmentsAndContingenciesDisclosureTextBlock',
        'us-gaap:CashAndCashEquivalentsPolicyTextBlock'
    ];

    tb := fnameds.values(textblocks(element));

    outrec := RECORD
      STRING text := tb.content;
      STRING fname := tb.fname;
    END;

    testtextvec_input_fnm := sep_sents_fnm(fnmConcat(TABLE(tb,outrec)));

    finalout := PROJECT(testtextvec_input_fnm,TRANSFORM(sveclblrec,SELF.sentId := COUNTER,SELF.label := 'THISQ',SELF := LEFT));
    RETURN finalout;
END;