IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT TextVectors as tv;
IMPORT * FROM Types;

modrec := tv.Types.TextMod;
Sentence := tv.Types.Sentence;
Word := tv.Types.Word;

path10k := '~ncf::edgarfilings::raw::all_10k';
path10q := '~ncf::edgarfilings::raw::all_10q';

svl := secvec_input_lbl(path10q,path10k,TRUE,'plain');
dat := sent_model.trndata_wlbl(svl);

spdat := lbljoin(dat.s[1]);
sents := svl;
model := dat.m;

tsents := PROJECT(sents,TRANSFORM(Sentence,SELF.sentId := LEFT.sentId,SELF.text := LEFT.text));

testWords := DATASET([{1,'cash'},{2,'debt'},{3,'equity'},{4,'profit'},{5,'music'}],Word);
testSents := DATASET([{1,'We expect to be profitable next quarter'},{2,'There is an unknown amount of litigation pending'}],Sentence);

sv := tv.SentenceVectors();

wordVecs := sv.GetWordVectors(model,testWords);

sentVecs := sv.GetSentVectors(model,testSents);

closestWords := sv.ClosestWords(model,testWords,3);

closestSents := sv.ClosestSentences(model,testSents,2);

leastSim := sv.LeastSImilarWords(model,testWords,1);

result := sv.WordAnalogy(model,'drug','cancer','law',2);

trainingStats := sv.GetTrainStats(model);

OUTPUT(closestWords);
OUTPUT(closestSents);
OUTPUT(leastSim);
OUTPUT(result);
OUTPUT(trainingStats);