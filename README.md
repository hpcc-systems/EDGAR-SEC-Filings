#EDGAR-SEC-Filings
Contains ECL scripts used for preprocessing, analysis and ML on SEC filings data.

  /Data/ contains data that can be used for convenient testing of this repository.
  
    /Data/tickers contains the list of company tickers that were used in the project, companylist.csv. Can potentially redo project with larger set of company tickers if a different file is used here.
    
    labelguide_all contains s&p labels for all the 10-Q files initially extracted
    
    labelguide_all_10k contains s&p labels for all the 10-K files initially extracted
    
    sector_guide_all contains a list of all tickers and what sector they are from
    
    thisq_perf contains the performance (according to plain and s&p scheme) of THISQ filings in the initial extraction: if a filing is from THISQ, it cant be compared to the end of its quarter, so instead this file contains that stock's percent return overall and compared to the S&P from the date of filing until the date that the extraction is being run (used pd.datetime.now())
    
    ticks_10k contains a list of stocks for which 10-K filings exist in the initial extraction
    
    xbrl10k.zip contains a selection of 10-K files that can be used in testing without having to run the scraping procedure
    
    xbrl10q.zip contains a selection of 10-Q files that can be used in testing without having to run the scraping procedure
    
    xbrlthisqtr.zip contains a selection of THISQ that can be used in testing without having to run the scraping procedure

  /EDGAR_Extract/ contains scripts used for extraction and initial text cleaning of the SEC filings.
    
    Extract_Layout_modified contains recordtypes for use in extraction
    
    Raw_Input_Files performs the initial read of the BLOB
    
    XBRL_Extract_modified performs the file extract and some initial cleaning
    
    Text_Tools contains a variety of tools used for cleaning and various manipulations on strings and parsing. There is also a method called MoneyTable that is still partially experimental, which is meant to be able to extract all mentions of $ and % from a text block and list those values along with immediate text descriptions, to ease the analysis of quantitative details from these long notes sections.

  /Internal/ contains utility files
    The only file currently present in Internal is svUtils, which has a variety of tools for use throughout the package, mostly vector manipulation

  /python/ Contains python scripts used to obtain SEC filings and labels for sentiment modeling. There is a more descriptive README.md within this folder

  /SEC_2_Vec/ Contains the core scripts used for similarity and sentiment modeling
    
    secvec_input takes a path to a numbered list of sentences for training
    
    secvec_input_lbl takes a path to a numbered list of sentences along with file names and labels from the original documents
    
    secvec_test_lbl takes a path to a numbered list of sentences along with file names and labels from the original documents
    
    traintestsplit performs a train-test split of data
    based on filename, stock ticker, or sentence number,
    and according to the desired fraction of the original
    lbljoin turns a plain-labeled dataset to s&p labeled
    
    /sentiment contains a variety of scripts used for sentiment modeling
      
      sectors contains a number of useful datasets and sets
      for use in identifying files and sentences by their
      appropriate industry sector
      
      sents_and_mod trains a fresh set of labeled sentences
      and a text model
      
      sent_prep performs preparatory token counting and other
      tasks used for tfidf scoring
      
      sent_setup_norm is a deprecated script containing a
      variety of approaches to tfidf vector transformation
      that are not computationally efficient but may be of
      interest for study
      
      tfidf performs a computationally efficient/distributed
      transformation of vanilla vectors to tfidf weighting
      
      sent_model contains a variety of methods for preparing
      a sentiment model, including taking a set of labeled
      sentences to vanilla and tfidf vectors, and turning
      a dataset of vectors with class labels into NumericField
      and DiscreteField for ML
      
      docsent averages all the sentence sentiment predictions
      single-dimensional document sentiment and then converts
      that into NumericField for use in modeling, also outputs
      the file labels as DiscreteField for use in ML
      
      doc_model averages sentence vectors from the same file
      into a 'document vector' with labels and filenames attached
      (trainrec format)
    
    /similarity contains a variety of scripts for the similarity modeling/analysis
      
      docsim calculates the similarity between two documents
      
      simlabs creates a comparative set of consecutive quarterly filings with similarity scores and the filenames and labels still attached
      
      qoq_secmod_n creates a sector-specific model for predicting the sentiment labels using the similarity scores as independent variables

  /SEC_Viz contains visualization scripts
    
    wordcloud_prep turns a filepath into a list of words in the corpus for use in word cloud creation
    
    sec_wordcloud creates a wordcloud from a prepared word list

  /tokenutils contains tokenization scripts copied from TextVectors that originally lived in the ML (not ML_Core) library, but for ease of use the relevant files were moved into this repository so as to avoid confusion between ML_Core and ML in any imports
    
    Config contains some configuration settings for the tokenization
    
    Tokenize contains tools for document tokenization
    
    Types contains recordtypes for use in tokenization

clean_extract_10k_10q is a test to ensure the extraction is performed cleanly. It will be removed.
get_dei_terms is a test that was used to get all possible tags/fields from the XBRL document, used in development. It will be removed
txt_extract_ficcorp is used to test extraction and reading of a fiction corpus in previous experiments. It will be removed.
Types contains a variety of important recordtypes for use throughout this package.
