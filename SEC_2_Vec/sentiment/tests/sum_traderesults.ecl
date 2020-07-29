IMPORT * FROM Types;

vanresults := DATASET(WORKUNIT('W20200728-164816','Result 1'),perfrec);
tfiresults := DATASET(WORKUNIT('W20200728-164816','Result 2'),perfrec);

van1s := vanresults(label='1');
tfi1s := tfiresults(label='1');

OUTPUT(SUM(van1s,van1s.tot_return),NAMED('vanilla_plain'));
OUTPUT(SUM(van1s,van1s.sp_return),NAMED('vanilla_sandp'));
OUTPUT(SUM(tfi1s,tfi1s.tot_return),NAMED('tfidf_plain'));
OUTPUT(SUM(tfi1s,tfi1s.sp_return),NAMED('tfidf_sandp'));