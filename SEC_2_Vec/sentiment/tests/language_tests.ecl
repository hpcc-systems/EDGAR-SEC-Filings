IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
IMPORT TextVectors as tv;
IMPORT tv.Types;

srec := sentiment.sent_model.sveclblrec;
modrec := Types.TextMod;

sents := DATASET(WORKUNIT('W20200710-041732','Result 1'),srec);
model := DATASET(WORKUNIT('W20200710-041732','Result 2'),modrec);

tsents := PROJECT(sents,TRANSFORM(Types.Sentence,SELF.sentId := LEFT.sentId,SELF.text := LEFT.text));

Word := Types.Word;
Sentence := Types.Sentence;

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