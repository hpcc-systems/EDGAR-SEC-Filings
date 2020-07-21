IMPORT ML_Core;
IMPORT dbscan;
IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;

vansents := DATASET(WORKUNIT('W20200713-063347','sandp_label_vanilla_data'),sent_model.trainrec);

//zeroids := SET(vansents(label='0'),id);
//oneids := SET(vansents(label='1'),id);

ff := sent_model.getFields(vansents);
X := ff.NUMF;
Y := ff.DSCF;

Model := dbscan.DBSCAN().Fit(X);
NumClusters := dbscan.DBSCAN().Num_Clusters(Model);
NumOutliers := dbscan.DBSCAN().Num_Outliers(Model);

OUTPUT(NumClusters);
OUTPUT(NumOutliers);
OUTPUT(Model,ALL,NAMED('DBSCAN_model'));