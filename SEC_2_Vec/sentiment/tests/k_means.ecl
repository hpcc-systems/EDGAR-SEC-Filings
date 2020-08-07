IMPORT ML_Core;
IMPORT KMeans;
IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM Types;

nf := ML_Core.Types.NumericField;
df := ML_Core.Types.DiscreteField;

hundred0s := DATASET(100,TRANSFORM({UNSIGNED4 i},SELF.i := COUNTER));

centroid_ds_1 := PROJECT(hundred0s,TRANSFORM(nf,
                    SELF.wi := 1,
                    SELF.id := 1,
                    SELF.number := LEFT.i,
                    SELF.value := IF(LEFT.i=0,1.0,0.0)));
centroid_ds_2 := PROJECT(hundred0s,TRANSFORM(nf,
                    SELF.wi := 1,
                    SELF.id := 2,
                    SELF.number := LEFT.i,
                    SELF.value := IF(LEFT.i=100,1.0,0.0)));

centroids_artificial := centroid_ds_1+centroid_ds_2;


path10k := '~ncf::edgarfilings::raw::all_10k';
path10q := '~ncf::edgarfilings::raw::all_10q';

svl := secvec_input_lbl(path10q,path10k,TRUE,'plain');
dat := sent_model.trndata_wlbl(svl);

vansents := lbljoin(dat.s[1]);

ff := sent_model.getFields(vansents);
X := ff.NUMF;
Y := ff.DSCF;

centroids_x := X(id IN [1,100]);

Max_iterations := 100;
Tolerance := 0.0001;

//Train K-Means Model
//Setup the model
Pre_Model := KMeans.KMeans(Max_iterations, Tolerance);
//Train the model
Model := Pre_Model.Fit( X , centroids_artificial );

//Coordinates of cluster centers
Centers := KMeans.KMeans().Centers(Model);

//Predict the cluster index of the new samples
Labels := KMeans.KMeans().Predict(Model, X);

df lab_to_df(KMeans.Types.KMeans_Model.Labels ls) := TRANSFORM
    SELF.wi := ls.wi;
    SELF.id := ls.id;
    SELF.number := 1;
    SELF.value := ls.label;
END;

k_preds := PROJECT(Labels,lab_to_df(LEFT));

k_acc := ML_Core.Analysis.Classification.Accuracy(k_preds,Y);

OUTPUT(k_acc);