IMPORT * FROM EDGAR_Extract;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT TextVectors as tv;
IMPORT * FROM TextVectors;
#OPTION('outputLimit',100);
//#OPTION('outputLimit',50);
//path_fic := '~ncf::edgarfilings::raw::cocaficsamp';
path_wiki := '~ncf::edgarfilings::raw::wikisamp';
corp := DATASET(path_wiki,STRING);

rec := RECORD
    STRING text := corp.line;
END;
corp_concat := Concat(TABLE(corp,rec));
corp_sents  := sep_sents(corp_concat);
sentrec := RECORD
    UNSIGNED8 sentId := corp_sents.sentId;
    STRING    text   := corp_sents.text;
END;

trainSentences := TABLE(corp_sents,sentrec);

sv := tv.SentenceVectors();
model := sv.GetModel(trainSentences);

Word := Types.Word;

testWords := DATASET([{1, 'debt'},{2,'equity'},{3,'cash'},{4,'liquid'}],
                Word);

wordVecs := sv.GetWordVectors(model, testWords);


OUTPUT(model,ALL);
OUTPUT(wordVecs,ALL);
OUTPUT(sv.ClosestWords(model, testWords, 3));
OUTPUT(sv.WordAnalogy(model,'quarter','year','part',2));