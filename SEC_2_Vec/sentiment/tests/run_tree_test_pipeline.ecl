IMPORT * FROM SEC_2_Vec.sentiment.tests;

#OPTION('outputLimit',100);

OUTPUT(tree_test_pipeline('s&p').comparison);