import yfinance as yf
import pandas as pd
from scrape_utils import *

def qtrlabels(tick,date,comp='plain'):

  stock = yf.Ticker(tick.upper())
  hist = stock.history(interval="1d",start=fixdate(date),end=qenddate(date))
  stkchg = hist.iloc[-1].Close/hist.iloc[0].Close

  if comp == 'plain':
    return int(stkchg>1)
  elif comp == 's&p' or comp == 'sector':
    #experimental code to find percent change rather than absolute change
    if comp == 's&p':
      sandptick = yf.Ticker('SPY')
      sandp = sandptick.history(interval="1d",start=fixdate(date),end=qenddate(date))
      sandpchg = (sandp.iloc[-1].Close/sandp.iloc[0].Close)-1
      return int(stkchg-1>sandpchg)
    elif comp == 'sector':
      print('NOT YET SUPPORTED')
      return None