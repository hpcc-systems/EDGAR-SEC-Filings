IMPORT * FROM SEC_2_Vec;

path_fic := '~ncf::edgarfilings::raw::cocaficsamp';
path_sec := '~ncf::edgarfilings::raw::tech10qs_group';
path_sec_small := '~ncf::edgarfilings::raw::group10q';

OUTPUT(Stage_Learn.FinalStage(path_fic,'ptext',path_sec));