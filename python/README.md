SEC Scrape README

This folder contains Python scripts used for obtaining 10-Q and 10-K filings by scraping the SEC website using Selenium WebDriver. The /scrape/ folder contains all necessary resources for scraping and labeling training data: running scrape/runextract.py will activate the pipeline according to the arguments used. Specifically, the scrape follows the list of stock tickers given in the Data/tickers/companylist.csv file. For each ticker, the following occurs:
  the ticker is searched on SEC EDGAR
  the links to any 10-K and 10-Q filings on the resulting page are collected
  each of these links are used to access and save the relevant 10-K or 10-Q filing
  the date of the filing in question is used along with that stock ticker's historical stock prices (obtained using the yfinance package) to create '1' or '0' labels based on the desired labeling scheme.
  The ticker-date-formtype-label ('plain' label) is used to create a filename to save the XBRL source file of the filing to. The filings are saved under folders named for their industry sector, and any filings from the most recent quarter (where the quarter has not yet ended) are labeled THISQ

To obtain a list of file labels according to a different labeling scheme, such as s&p (the only alternative currently supported) simply run scrape/make_sp_labels.py

To obtain a file of stock performance for THISQ filings (for forward testing of the sentiment model on trading results), simply run python/THISQ_perf/get_thisq_perf.py