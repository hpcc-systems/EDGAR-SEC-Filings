//OUTPUT('&#134;');
//OUTPUT('†');
//OUTPUT(3!=3);
ds := DATASET(WORKUNIT('W20200613-213217','Money_Table_test'),{STRING descr,STRING money});
firstishidden(STRING txt) := txt[1] NOT IN ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
OUTPUT('h'+'e');
OUTPUT(COUNT(['h','e']));
OUTPUT(ds[1].descr[1..2]);
OUTPUT(firstishidden(ds[1].descr))