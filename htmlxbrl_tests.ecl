IMPORT * FROM EDGAR_Extract;
IMPORT SEC_2_Vec;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT * FROM EDGAR_Extract.XBRL_Extract_modified;

//path := '~ncf::edgarfilings::raw::htmlform_example';
//path := '~ncf::edgarfilings::raw::htmlfixedform_example';
//path := '~ncf::edgarfilings::raw::oldform_sample';
path := '~ncf::edgarfilings::raw::10k_sample';

OUTPUT(Text_Tools.XBRL_HTML_File(path));
OUTPUT(XBRL_Extract_modified.File(path));