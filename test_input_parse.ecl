IMPORT * FROM EDGAR_Extract;
IMPORT * FROM SEC_2_Vec;

//path := '~ncf::edgarfilings::raw::group10q';
path := '~ncf::edgarfilings::raw::more10qs';

OUTPUT(secvec_input(path),NAMED('separated_sentences'),ALL);