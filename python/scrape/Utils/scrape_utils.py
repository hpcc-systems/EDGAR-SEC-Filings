import numpy as np
import pandas as pd

def fixdate(dateString):
  return ''.join(dateString.split('-'))

def foldpath(sectString):
  sectdict = {'Technology':'Technology','Health Care':'HealthCare','Consumer Services':'ConsumerServices','Consumer Durables':'ConsumerDurables','Capital Goods':'CapitalGoods',np.nan:'nan','Finance':'Finance','Miscellaneous':'Miscellaneous','Consumer Non-Durables':'ConsumerNonDurables','Public Utilities':'PublicUtilities','Basic Industries':'BasicIndustries','Transportation':'Transportation','Energy':'Energy'}
  return sectdict[sectString]

def highestmonth(x):
  date = ''.join(x.split('-'))
  year = int(date[:4])
  month = int(date[4:6])
 
  if np.mod(month,3)==0:
    out = month-3
  else:
    out = month-np.mod(month,3)
    

  if out == 0:
    year -= 1
    return [year,12]
  else:
    return [year,out]

def fix0s(n):
  if n<10:
    return '0'+str(n)
  else:
    return str(n)

def asmonth(x):
  return pd.to_datetime(x).month

def setq(x):
  qdict = {1:1,2:1,3:1,
           4:2,5:2,6:2,
           7:3,8:3,9:3,
         10:4,11:4,12:4}
  return qdict[x]

def qenddate(date):
  last_month = setq(asmonth(date))*3
  if last_month == 6:
    return '06-30'
  else:
    return date[:4]+'-'+fix0s(str(last_month))+'-31'

def midtrim(s):
  out=''
  for c in s:
    if c!=' ':
      out+=c
  return out

def fix(insourc):

  opener = '<?xml version="1.0" encoding="utf-8"?>'
  
  i=0
  ##get xbrl start idx
  stillhtml = True

  while stillhtml:
    if insourc[i:i+6]=='<xbrl ':
      starti = i
      stillhtml = False
    else:
      i+=1

  j=0
  ##get xbrl end idx
  stillhtml = True
  
  while stillhtml:
    if insourc[j:min(len(insourc)+j+7,len(insourc))]=='</xbrl>':
      endj = min(len(insourc)+j+7,len(insourc))
      stillhtml = False
    else:
      j-=1

  return opener + insourc[starti:endj]