IMPORT * FROM EDGAR_Extract;
IMPORT * FROM EDGAR_Extract.Text_Tools;

EXPORT secvec_input(STRING inpath) := FUNCTION
    ds   := XBRL_HTML_File(inpath);

    textblocks(UNICODE el) := el IN [
        'us-gaap:QuarterlyFinancialInformationTextBlock',
        'us-gaap:AdditionalFinancialInformationTextBlock',
        'us-gaap:BasisOfPresentationAndSignificantAccountingPoliciesTextBlock',
        'us-gaap:CommitmentsAndContingenciesDisclosureTextBlock',
        'us-gaap:CashAndCashEquivalentsPolicyTextBlock'
    ];

    tb := ds.values(textblocks(element));

    outrec := RECORD
        STRING text := tb.content;
    END;

    testtextvec_input := sep_sents(Concat(TABLE(tb,outrec)));
    
    RETURN testtextvec_input;
END;