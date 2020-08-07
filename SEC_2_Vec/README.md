SEC_2_Vec README

SEC_2_Vec Contains the core scripts used for similarity and sentiment modeling, as well as tests exhibiting these methods and allowing for reproduction of experimental results.

These methods are designed to either train text models or use trained text models in further modeling and analysis.

/SEC_2_Vec/sentiment contains a variety of scripts used for sentiment modeling

    /sentiment/tests contains tests demonstrating the various model approaches
    
        sentdoc_secmod contains a test that calculates sentence sentiment models and then uses the predicted values along with 'true' document labels to train a document model. The results of this test are PoD and PoDE scores (on holdout data) for the sentence and document models calculated on each sector.

        direct_secmod contains a test that calculates document sentiment directly by first averaging sentence vectors to create 'document vectors' on which a sentiment model can be directly trained according to document labels. The results of this test are PoD and PoDE scores (on in and out-of sample data) for the document models calculated on each sector.

        gnn_model contains a test that trains and evaluates a Keras model for sentence sentiment modeling

        k_means contains a test that trains and evalutes a K-Means (K=2) clustering as a means of unsupervised classification of sentence vectors

        language_tests contains a few language-oriented subjective tasks for evaluating the usefulness of a text model

        thisq_results calculates a direct document sentiment model and then predicts which THISQ data would be identified as having 'positive' sentiment, then returns the total percent return from those securities since the filing date. For example, if 3 stocks are identified as 'positive', for which the return since most recent filing are, respectively, 4.2%, -2.1%, and 7.3%, the total would be 9.4%

        tree_sent_test runs document/sentence sentiment modeling using classification forests rather than BLR

    doc_model takes a set of labeled sentence vectors (format 'trainrec') and returns averaged 'document vectors' with labels still attached, also in 'trainrec' form and ready for use in modeling or the getFields() method for obtaining NumericField and DiscreteField data

    docsent takes a set of predictions for sentence sentiment and averages the 1-dimensional predictions for each filing to obtain a 1-dimensional value that can be used as the independent variable in a document sentiment model

    sectors contains a variety of methods/sets/resources for subsetting by sector/identifying the sector a given stock ticker is associated with

    sent_model contains a variety of methods for preparing for sentiment modeling, including trndata_wlbl which actually trains a text model (with vanilla as well as tfidf vectors) from a list of sentences, and getFields(), which extracts NumericField and DiscreteField format from trainrec containing 100-dimensional vectors

    sent_prep contains tools for calculating tfidf score

    sent_setup_norm is a deprecated script containing a variety of experimental methods for calculating tf-idf vectors. while logically correct, it is not optimal computationally, and tfidf() should be used in almost every case except for intentional study and comparison

    tfidf is a script that takes a TextVectors model and a set of vanilla 'trainrec' sentence vectors in order to calculate the transformed tfidf sentence vectors

/SEC_2_Vec/similarity contains a variety of scripts used for similarity analysis and modeling

    /similarity/tests contains tests demonstrating the use of similarity methods and allows replication of experimental results

        qoq_holdout_test uses evaluates the predictive ability of similarity results to classify the sentiment labels for each filing

        simsents_test demonstrates the calculation of document similarity for successive filings (and keeps 'true' sentiment lables in-line for any modeling that might be of interest)

    docsim calculates the similarity between two sets of sentences (two 'documents')

    qoq_secmod_n is called by qoq_holdout_test to calculate the similarity/sentiment models and evaluate the results

    simlabs is used to set up consecutive similarity filing for viewing

lbljoin is used to attach alternate labels (currently only S&P labels)

secvec_input is used to create a plain set of numbered sentences for model training

secvec_input_lbl is used to create a set of numbered sentences that still have filenames and labels attached for sentence modeling

secvec_test_lbl is used to set up the numbered sentences from THISQ filings for use in tests such as thisq_results

traintestsplit is used to conveniently split training and test data according to a desired attribute such as shared filename, shared stock ticker, etc. and by a specified fraction