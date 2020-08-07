IMPORT ML_Core;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT TextVectors as tv;
IMPORT LogisticRegression as LR;
IMPORT * FROM Types;

#OPTION('outputLimit',500);

t_Vector := tv.Types.t_Vector;
Sentence := tv.Types.Sentence;

path10k := '~ncf::edgarfilings::raw::labels_allsecs_all_10k';
path10q := '~ncf::edgarfilings::raw::plainlabel_allsecs_all';
pathqthisq := '~ncf::edgarfilings::raw::thisq_10qs';
pathkthisq := '~ncf::edgarfilings::raw::thisq_blankcarat10q';
pathperf := '~ncf::edgarfilings::supp::thisq_perf';

csvrec := RECORD
    STRING fname;
    REAL8 tot_return;
    REAL8 sp_return;
END;

// OUTPUT(DATASET(pathperf,csvrec,CSV(HEADING(1))));
// OUTPUT(secvec_test_lbl(pathqthisq));
// OUTPUT(secvec_input_lbl(path10q,path10k,TRUE,'plain'));

trainsents := secvec_input_lbl(path10q,path10k,TRUE,'plain');
tm1 := sent_model.trndata_wlbl(trainsents);
tdat := tm1.s;
tvan := tdat[1];
ttfi := tdat[2];

docvan := doc_model(tvan);
doctfi := doc_model(ttfi);

sv := tv.SentenceVectors();
plainblr := LR.BinomialLogisticRegression();

vanff := sent_model.getFields(docvan);
tfiff := sent_model.getFields(doctfi);

vnX := vanff.NUMF;
vnY := vanff.DSCF;
tfX := tfiff.NUMF;
tfY := tfiff.DSCF;

vanmod := plainblr.GetModel(vnX,vnY);
tfimod := plainblr.GetModel(tfX,tfY);

vanpreds := plainblr.Classify(vanmod,vnX);
tfipreds := plainblr.Classify(tfimod,tfX);

vanpod := ML_Core.Analysis.Classification.Accuracy(vanpreds,vnY);
tfipod := ML_Core.Analysis.Classification.Accuracy(tfipreds,tfY);

sents := secvec_test_lbl(pathqthisq);
//dat := sent_model.trndata_wlbl(sents);
rawsents := PROJECT(sents,TRANSFORM(Sentence,SELF.sentId := LEFT.sentId,SELF.text := LEFT.text));
van := JOIN(sv.GetSentVectors(tm1.m,rawsents),sents,LEFT.sentId = RIGHT.sentId,TRANSFORM(trainrec,SELF.id := LEFT.sentId,
                                                                                                SELF.text := LEFT.text,
                                                                                                SELF.vec := LEFT.vec,
                                                                                                SELF.fname := RIGHT.fname,
                                                                                                SELF.label := RIGHT.label));//dat[1];
tfi := tfidf(tm1.m,sents);//dat[2];

thisdocvan := doc_model(van);
thisdoctfi := doc_model(tfi);

thisvanff := sent_model.getFields(thisdocvan);
thistfiff := sent_model.getFields(thisdoctfi);

thisvnX := thisvanff.NUMF;
thistfX := thistfiff.NUMF;

thisvnpreds := plainblr.Classify(vanmod,thisvnX);
thistfpreds := plainblr.Classify(tfimod,thistfX);

thisvnpredsdoc := JOIN(thisdocvan,thisvnpreds,LEFT.id = RIGHT.id,TRANSFORM(RECORDOF(LEFT),SELF.label:=(STRING)RIGHT.value,SELF:=LEFT));
thistfpredsdoc := JOIN(thisdoctfi,thistfpreds,LEFT.id = RIGHT.id,TRANSFORM(RECORDOF(LEFT),SELF.label:=(STRING)RIGHT.value,SELF:=LEFT));

perf := DATASET(pathperf,csvrec,CSV(HEADING(1)));

perfno0 := perf(tot_return!=0,sp_return!=0);

outvn := JOIN(thisvnpredsdoc,perfno0,LEFT.fname=RIGHT.fname,TRANSFORM(perfrec,SELF.sentId := LEFT.id,
                                                                SELF.fname := LEFT.fname,
                                                                SELF.label := LEFT.label,
                                                                SELF.text := LEFT.text,
                                                                SELF.vec := LEFT.vec,
                                                                SELF.tot_return := RIGHT.tot_return,
                                                                SELF.sp_return := RIGHT.sp_return));

outtf := JOIN(thistfpredsdoc,perfno0,LEFT.fname=RIGHT.fname,TRANSFORM(perfrec,SELF.sentId := LEFT.id,
                                                                SELF.fname := LEFT.fname,
                                                                SELF.label := LEFT.label,
                                                                SELF.text := LEFT.text,
                                                                SELF.vec := LEFT.vec,
                                                                SELF.tot_return := RIGHT.tot_return,
                                                                SELF.sp_return := RIGHT.sp_return));

van1s := outvn(label='1');
tfi1s := outtf(label='1');

OUTPUT(outvn);
OUTPUT(outtf);
OUTPUT(vanpod[1].pode);
OUTPUT(tfipod[1].pode);
OUTPUT(SUM(van1s,van1s.tot_return),NAMED('vanilla_plain'));
OUTPUT(SUM(van1s,van1s.sp_return),NAMED('vanilla_sandp'));
OUTPUT(SUM(tfi1s,tfi1s.tot_return),NAMED('tfidf_plain'));
OUTPUT(SUM(tfi1s,tfi1s.sp_return),NAMED('tfidf_sandp'));