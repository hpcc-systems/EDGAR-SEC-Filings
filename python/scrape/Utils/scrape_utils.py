import numpy as np

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
