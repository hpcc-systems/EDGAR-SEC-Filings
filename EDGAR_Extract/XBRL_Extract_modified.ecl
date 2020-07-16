IMPORT STD;
IMPORT * FROM EDGAR_Extract;

// This is done as a module for symmetry with Classic EDGAR Extraction
EXPORT XBRL_Extract_modified := MODULE
  SHARED ds(STRING fileName) := Raw_Input_Files.Files(fileName);//, TRUE);   // strip prefix

  SHARED Extract_Layout_modified.Entry_clean getEntry(UNICODE element) := TRANSFORM
    SELF.element    := element;
    SELF.contextRef := XMLUNICODE('@contextRef');
    SELF.unitRef    := XMLUNICODE('@unitRef');
    SELF.decimals   := XMLUNICODE('@decimals');
    SELF.content    := (STRING)XMLUNICODE('');
  END;
  
  SHARED parserec := RECORD
    STRING parsed_tag;
  END;

  SHARED parse_inrec := RECORD
    STRING filename;
    UNICODE text;
  END;

  //DATASET(parserec) parsetags(STRING fname,UNICODE txt) := FUNCTION
  SHARED parsetags(UNICODE intext) := FUNCTION
    helperrec := RECORD
      UNICODE line;
    END;
    txtdata := DATASET([intext],helperrec);

    pattern mess := ANY NOT IN ['<','>'];
    pattern lcase := PATTERN('[a-z]');
    pattern ucase := PATTERN('[A-Z]');
    pattern propercase := ucase lcase*;
    pattern field_name := propercase* 'TextBlock';
    pattern tagnames := 'us-gaap'; //FIXME: WANT TO DYNAMICALLY ALLOW TICKER AS A TAGNAME, BUT IT IS A RUNTIME VARIABLE
    //pattern tagnames := ANY IN ['dei','us-gaap'];
    pattern eltag := tagnames ':' field_name;
    pattern tagform := '<' eltag mess* '>';
    rule tagblk := tagform;

    outrec := RECORD
      STRING parsed_tag := MATCHTEXT(tagform/eltag);
    END;

    out := DEDUP(SORT(PARSE(txtdata,line,tagblk,outrec),parsed_tag));
    
    RETURN out;
  END;

  EXPORT

  //SHARED DATASET(Extract_Layout_modified.Entry_clean) get_text_blocks(UNICODE txt) := FUNCTION
  DATASET(Extract_Layout_modified.Entry_clean) get_text_blocks(UNICODE txt) := FUNCTION
    tags := parsetags(txt);

    Extract_Layout_modified.Entry_clean getxml_T(parserec t) := TRANSFORM
      allrow := XMLPROJECT(t.parsed_tag,getEntry(t.parsed_tag));
      SELF.element := allrow.element;
      SELF.contextRef := allrow.contextRef;
      SELF.unitRef := allrow.unitRef;
      SELF.decimals := allrow.decimals;
      SELF.content := allrow.content;
    END;

    out := PROJECT(tags,getxml_T(LEFT));

    RETURN out;
  END;

  Extract_Layout_modified.Main cvt(RECORDOF(ds) lr) := TRANSFORM
    SELF.fileName         := lr.fileName;
    //SELF.filingType       := XMLUNICODE('dei:DocumentType');
    //SELF.reportPeriod     := XMLUNICODE('dei:DocumentPeriodEndDate');
    //SELF.name             := XMLUNICODE('dei:EntityRegistrantName');
    //SELF.is_smallbiz      := XMLUNICODE('dei:EntitySmallBusiness');
    //SELF.pubfloat         := XMLUNICODE('dei:EntityPublicFloat');
    //SELF.comsharesout     := XMLUNICODE('dei:EntityCommonStockSharesOutstanding');
    //SELF.wellknown        := XMLUNICODE('dei:EntityWellKnownSeasonedIssuer');
    //SELF.shell            := XMLUNICODE('dei:EntityShellCompany');
    //SELF.centralidxkey    := XMLUNICODE('dei:EntityCentralIndexKey');
    //SELF.amendflag        := XMLUNICODE('dei:AmendmentFlag');
    //SELF.filercat         := XMLUNICODE('dei:EntityFilerCategory');
    //SELF.fyfocus          := XMLUNICODE('dei:DocumentFiscalYearFocus');
    //SELF.fpfocus          := XMLUNICODE('dei:DocumentFiscalPeriodFocus');
    //SELF.emerging         := XMLUNICODE('dei:EntityEmergingGrowthCompany');
    //SELF.ticker           := XMLUNICODE('dei:TradingSymbol');
    //SELF.volfilers        := XMLUNICODE('dei:EntityVoluntaryFilers');
    //SELF.currentstat      := XMLUNICODE('dei:EntityCurrentReportingStatus');
    //SELF.fyend            := XMLUNICODE('dei:CurrentFiscalYearEndDate');
    SELF.filingDate       := 'N/A';    // only classic EDGAR
    SELF.accessionNumber  := 'N/A';    // only classic EDGAR
    SELF.values           := XMLPROJECT('us-gaap:NetIncomeLoss', getEntry('us-gaap:NetIncomeLoss'))
                           + XMLPROJECT('us-gaap:SalesRevenueNet', getEntry('us-gaap:SalesRevenueNet'))
                           + XMLPROJECT('us-gaap:UnrecordedUnconditionalPurchaseObligationBalanceOnFirstAnniversary', getEntry('us-gaap:UnrecordedUnconditionalPurchaseObligationBalanceOnFirstAnniversary'))
                           + XMLPROJECT('us-gaap:UnrecordedUnconditionalPurchaseObligationBalanceOnFifthAnniversary', getEntry('us-gaap:UnrecordedUnconditionalPurchaseObligationBalanceOnFifthAnniversary'))
                           + XMLPROJECT('us-gaap:QuarterlyFinancialInformationTextBlock', getEntry('us-gaap:QuarterlyFinancialInformationTextBlock'))
                           + XMLPROJECT('us-gaap:AdditionalFinancialInformationTextBlock', getEntry('us-gaap:AdditionalFinancialInformationTextBlock'))
                           + XMLPROJECT('us-gaap:BasisOfPresentationAndSignificantAccountingPoliciesTextBlock', getEntry('us-gaap:BasisOfPresentationAndSignificantAccountingPoliciesTextBlock'))
                           + XMLPROJECT('us-gaap:CommitmentsAndContingenciesDisclosureTextBlock', getEntry('us-gaap:CommitmentsAndContingenciesDisclosureTextBlock'))
                           + XMLPROJECT('us-gaap:CashAndCashEquivalentsPolicyTextBlock', getEntry('us-gaap:CashAndCashEquivalentsPolicyTextBlock'));
    //SELF.values           := get_text_blocks(lr.text); //FIXME: explore using macro, fixing this dynamic approach and using PROJECT or MERGE to combine instead of +
  END;

  EXPORT File(STRING fileName) := PARSE(ds(fileName), text, cvt(LEFT), XML('xbrl'));
END;