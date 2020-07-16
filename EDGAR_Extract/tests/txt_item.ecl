IMPORT * FROM EDGAR_Extract;

#OPTION('outputLimit',100);

path := '~ncf::edgarfilings::raw::abbv_txt_10k';

f := Raw_Input_Files.Files(path);//_XBRL(path);


//OUTPUT(DATASET(path,{STRING contents},THOR));
OUTPUT(f);