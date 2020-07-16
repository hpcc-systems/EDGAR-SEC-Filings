IMPORT LearningTrees AS LT;
IMPORT * FROM LT;
IMPORT SEC_2_Vec;
IMPORT SEC_2_Vec.sentiment.sent_model as sm;
IMPORT SupportVectorMachines as SVM;

#OPTION('outputLimit',100);
#OPTION('inputLimit',1000);

vansents := DATASET(WORKUNIT('W20200623-012104','Result 2'),sm.trainrec);
ff := sm.getFields(vansents);

X := ff.NUMF;

Y := ff.DSCF;

//dscan := DBSCAN(eps=0.01);
//clust := dscan.fit(X);

CF := LT.ClassificationForest();

mod := CF.GetModel(X,Y);

preds := CF.Classify(mod,X);

//OUTPUT(preds);
//OUTPUT(clust);

svc := SVM.SVC();

//svm_mod := svc.GetModel(X,Y);
//svm_preds := svc.Classify(svm_mod,X);
//svm_con := SVM.Confusion(Y,svm_preds);

IMPORT LogisticRegression as LR;

precon := LR.Confusion(Y,preds);
con := LR.BinomialConfusion(precon);

OUTPUT(vansents,ALL);
OUTPUT(mod,ALL);
OUTPUT(preds,ALL);
OUTPUT(con,NAMED('tree_model_confusion'));
//OUTPUT(svc.Report(svm_mod,X,Y),NAMED('SVC_Report_All'));
//OUTPUT(svm_con,NAMED('svm_model_confusion'));