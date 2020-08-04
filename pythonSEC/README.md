SEC Scrape README

This folder contains Python scripts used for obtaining 10-Q and 10-K filings by scraping the SEC website using Selenium WebDriver. 

  /pythonSEC/Utils contains a variety of utilities for scraping and labeling
  
    scrape_utils contains a variety of utilities used in other Utils scripts, such as string/date handling

    useapi contains the calls to the yfinance API and calculation of labels

    label_filename calls useapi to label files

    getlinks acquires filing listing for a given ticker as well as the links to each filing

    getxml acquires the XBRL source from a filing link

    extract_data calls getlinks and getxml to extract the filings for a ticker

  runextract (start) (numticks) runs the pipeline. It will automatically open a Chrome browser for scraping when initialized. Here 'start' is the index of the ticker list contained in /Data/tickers/companylist.csv the scrape should start from. When first running, begin at 0 -- if the pipeline runs into an issue or is canceled, it should report the index that should be started from on next run. Here 'numticks' is the number of tickers to process before the pipeline stops and reports the stopping point. If numticks is greater than the number of remaining tickers, the pipeline will report that there is no more data to process before beginning. Files will be saved to a Filings directory according to the appropriate industry sector (as described in companylist.csv). This Filings directory will be directly outside root, adjacent to this repository on your local machine.
  
  Example: python3 runextract.py 0 5 would process ticker indexes 0-4 in companylist.csv and then report that 5 is the index to start from next.

  make_sp_labelguide generates a csv containing S&P labels for each plain-label file in the Filings directory. It saves this csv in a Labels directory adjacent to Filings.

  get_thisq_perf generates a csv containing stock performance by percent for each THISQ filing.

Running runextract.py (with appropriate arguments) will activate the pipeline according to the arguments used. Specifically, the scrape follows the list of stock tickers given in the Data/tickers/companylist.csv file. For each ticker, the following occurs:
  the ticker is searched on SEC EDGAR
  the links to any 10-K and 10-Q filings on the resulting page are collected
  each of these links are used to access and save the relevant 10-K or 10-Q filing
  the date of the filing in question is used along with that stock ticker's historical stock prices (obtained using the yfinance package) to create '1' or '0' labels based on the desired labeling scheme.
  The ticker-date-formtype-label ('plain' label) is used to create a filename to save the XBRL source file of the filing to. The filings are saved under folders named for their industry sector, and any filings from the most recent quarter (where the quarter has not yet ended) are labeled THISQ

To obtain a list of file labels according to a different labeling scheme, such as s&p (the only alternative currently supported) simply run scrape/make_sp_labels.py

To obtain a file of stock performance for THISQ filings (for forward testing of the sentiment model on trading results), simply run python/THISQ_perf/get_thisq_perf.py