IMPORT * FROM EDGAR_Extract;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT TextVectors AS tv;
IMPORT tv.Types;
IMPORT * FROM SEC_2_Vec;
Sentence := Types.Sentence;


sv := tv.SentenceVectors();

model := DATASET(WORKUNIT('W20200526-115152','tech10qs_vecmod'),Types.TextMod);

Word := Types.Word;

testWords := DATASET([{1, 'debt'},{2,'liability'},{3,'securities'},{4,'assets'}],
                Word);

testWords2 := DATASET([{1, 'pending'},{2,'current'},{3,'probable'},{4,'pursuant'}],
                Word);

wordVecs := sv.GetWordVectors(model, testWords);
wordVecs2 := sv.GetWordVectors(model, testWords2);

OUTPUT(model(typ=1),ALL);

//OUTPUT(wordVecs);
//OUTPUT(wordVecs2);



//OUTPUT(sv.Similarity(wordVecs[2].vec,wordVecs[3].vec),NAMED('liability_securities_sim'));
//OUTPUT(sv.Similarity(wordVecs[3].vec,wordVecs[4].vec),NAMED('securities_assets_sim'));

//OUTPUT(sv.Similarity(wordVecs2[1].vec,wordVecs[2].vec),NAMED('pending_current_sim'));
//OUTPUT(sv.Similarity(wordVecs[1].vec,wordVecs[3].vec),NAMED('pending_probable_sim'));

//OUTPUT(sv.WordAnalogy(model,'debt','cash','uncertain',3));
//OUTPUT(sv.WordAnalogy(model,'debt','liability','securities',3));
//OUTPUT(sv.WordAnalogy(model,'pending','pursuant','probable',3));