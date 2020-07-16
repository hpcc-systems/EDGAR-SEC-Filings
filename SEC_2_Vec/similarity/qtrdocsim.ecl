IMPORT * FROM SEC_2_Vec.similarity;
IMPORT * FROM SEC_2_Vec.sentiment;
trec := sentiment.sent_model.trainrec;

#OPTION('outputLimit',100);

sandplblvn := DATASET(WORKUNIT('W20200712-194048','sandp_label_vanilla_data'),trec);

sl1 := simlabs(sandplblvn,'multiply');
sl2 := simlabs(sandplblvn,'add');

OUTPUT(sl1.sim_and_labels,ALL,NAMED('sp_sim_and_labels_multiply'));
OUTPUT(sl2.sim_and_labels,ALL,NAMED('sp_sim_and_labels_add'));