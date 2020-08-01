import yfinance as yf
import pandas as pd

def setq(x):
  qdict = {1:1,2:1,3:1,
           4:2,5:2,6:2,
           7:3,8:3,9:3,
         10:4,11:4,12:4}
  return qdict[x]

def exqtrlabs(tick,comp='plain'):
  def asmonth(x):
    return pd.to_datetime(x).month

  stock = yf.Ticker(tick.upper())
  hist = stock.history(interval="1d",start="2015-01-01",end=str(pd.datetime.now())[:10])
  hist['Date'] = hist.index
  hist['month'] = [asmonth(hist.iloc[i].Date) for i in range(len(hist.Date))]

  hist['Quarter'] = [setq(hist.iloc[i].month) for i in range(len(hist.month))]

  #hist['year'] = [int(hist.iloc[i].Date[:4]) for i in range(len(hist.Date))]
  hist['year'] = [int(hist.iloc[i].Date.year) for i in range(len(hist.Date))]
  
  if comp == 'plain':
    pass
  elif comp == 's&p' or comp == 'sector':
    #experimental code to find percent change rather than absolute change
    pcts = hist['Close']/hist['Close'].shift(1)-1
    hist['pcts'] = list(pcts)
    #
    if comp == 's&p':
      sandptick = yf.Ticker('SPY')
      sandp = sandptick.history(interval="1d",start="2015-01-01",end=str(pd.datetime.now())[:10])
      sandp['Date'] = sandp.index
      sandp['month'] = [asmonth(sandp.iloc[i].Date) for i in range(len(sandp.Date))]
      sandp['Quarter'] = [setq(sandp.iloc[i].month) for i in range(len(sandp.month))]
      sandp['year'] = [int(sandp.iloc[i].Date.year) for i in range(len(sandp.Date))]
      sp_pcts = sandp['Close']/sandp['Close'].shift(1)-1
      sandp['pcts'] = list(sp_pcts)
    
    #elif comp == 'sector':
    #  sectick = yf.Tick
    elif comp == 'sector':
      print('NOT YET SUPPORTED')

  timepairs = [(i,j) for i in range(1,5) for j in range(2015,2021)]

  def qclose(tpair):
    q = tpair[0]
    y = tpair[1]

    try:
      lastrow = hist.loc[(hist['Quarter']==q) & (hist['year']==y)].iloc[-1]
      if comp == 'plain':
        return lastrow.Close
      elif comp == 's&p':
        return lastrow.pcts
    except:
      return None
  
  def qclose_sp(tpair):
    q = tpair[0]
    y = tpair[1]
    
    try:
      lastrow = sandp.loc[(sandp['Quarter']==q) & (sandp['year']==y)].iloc[-1]
      if comp == 'plain':
        return lastrow.Close
      elif comp == 's&p':
        return lastrow.pcts
    except:
      return None

 # def qclose_sec(tpair):
 #   q = tpair[0]
 #   y = tpair[1]
 #
 #   try:
 #     lastrow = sec_hist.loc[(sec_hist['Quarter']==q) & (sec_hist['year']==y)].iloc[-1]
 #     return lastrow.Close
 #   except:
 #     return None

  def cleanupq(qc):
    out = [x for x in qc if x[2] != None]
    return out

  qcloses = sorted(cleanupq([(x[0],x[1],qclose(x)) for x in timepairs]),key = lambda x:x[1])
  if comp == 's&p':
    sp_qcloses = sorted(cleanupq([(x[0],x[1],qclose_sp(x)) for x in timepairs]),key = lambda x:x[1])

  qc_withlab = [[x[0],x[1],x[2],None] for x in qcloses]
  if comp == 's&p':
    qc_sp_withlab = [[x[0],x[1],x[2],None] for x in sp_qcloses]

  for x in range(1,len(qc_withlab)):
    if comp == 'plain':
      if qc_withlab[x][2]>qc_withlab[x-1][2]:
        qc_withlab[x][3] = 1
      else:
        qc_withlab[x][3] = 0
    elif comp == 's&p':
      if qc_withlab[x][2]>qc_sp_withlab[x-1][2]:
        qc_withlab[x][3] = 1
      else:
        qc_withlab[x][3] = 0
    else:
      print('check comparison type, only supported types are "plain" and "s&p"')

  qcwl = qc_withlab
  qc_laglab = [[qcwl[i][0],qcwl[i][1],qcwl[i][2],qcwl[i][3],qcwl[i+1][3]] for i in range(len(qcwl)-1)]

  return qc_laglab

 
def qtrlabels(tick):
  
  def asmonth(x):
    return pd.to_datetime(x).month 
  
  stock = yf.Ticker(tick.upper())
  hist = stock.history(interval="1d",start="2015-01-01",end=str(pd.datetime.now())[:10])
  hist['Date'] = hist.index
  hist['month'] = [asmonth(hist.iloc[i].Date) for i in range(len(hist.Date))]

  hist['Quarter'] = [setq(hist.iloc[i].month) for i in range(len(hist.month))]

  #hist['year'] = [int(hist.iloc[i].Date[:4]) for i in range(len(hist.Date))]
  hist['year'] = [int(hist.iloc[i].Date.year) for i in range(len(hist.Date))]  

  timepairs = [(i,j) for i in range(1,5) for j in range(2015,2021)]

  def qclose(tpair):
    q = tpair[0]
    y = tpair[1]

    try:
      lastrow = hist.loc[(hist['Quarter']==q) & (hist['year']==y)].iloc[-1]
      return lastrow.Close
    except:
      return None

  def cleanupq(qc):
    out = [x for x in qc if x[2] != None]
    return out

  qcloses = sorted(cleanupq([(x[0],x[1],qclose(x)) for x in timepairs]),key = lambda x:x[1])

  qc_withlab = [[x[0],x[1],x[2],None] for x in qcloses]

  for x in range(1,len(qc_withlab)):
    if qc_withlab[x][2]>qc_withlab[x-1][2]:
      qc_withlab[x][3] = 1
    else:
      qc_withlab[x][3] = 0

  qcwl = qc_withlab
  qc_laglab = [[qcwl[i][0],qcwl[i][1],qcwl[i][2],qcwl[i][3],qcwl[i+1][3]] for i in range(len(qcwl)-1)]

  return qc_laglab
