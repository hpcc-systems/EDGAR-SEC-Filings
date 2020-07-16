/**
 * The generic extraction record layout produced by the specific extraction routines.
 */

EXPORT Extract_Layout_modified := MODULE

  EXPORT Entry := RECORD
    UNICODE     element;      //the element r line tag for classic EDGAR
    UNICODE     contextRef;   //the contextRef attribute or position data for classic EDGAR
    UNICODE     unitRef;      //the unitRef attribute or blank for classic EDGAR
    UNICODE     decimals;     //the decimals attribute or blank for classic EDGAR
    UNICODE     content;      //the text content of the element
  END;

  EXPORT Entry_clean := RECORD
    UNICODE     element;      //the element r line tag for classic EDGAR
    UNICODE     contextRef;   //the contextRef attribute or position data for classic EDGAR
    UNICODE     unitRef;      //the unitRef attribute or blank for classic EDGAR
    UNICODE     decimals;     //the decimals attribute or blank for classic EDGAR
    STRING     content;      //the text content of the element
  END;

  EXPORT Main := RECORD
    STRING      fileName;
    UNICODE     accessionNumber;
    //UNICODE     name;
    //UNICODE     filingType;
    UNICODE     filingDate;
    //UNICODE     reportPeriod;
    //UNICODE     is_smallbiz;
    //UNICODE     pubfloat;
    //UNICODE     comsharesout;
    //UNICODE     wellknown;
    //UNICODE     shell;
    //UNICODE     centralidxkey;
    //UNICODE     amendflag;
    //UNICODE     filercat;
    //UNICODE     fyfocus;
    //UNICODE     fpfocus;
    //UNICODE     emerging;
    //UNICODE     ticker;
    //UNICODE     volfilers;
    //UNICODE     currentstat;
    //UNICODE     fyend;
    DATASET(Entry_clean) values;
  END;
END;
