import os
from scrape_utils import *
import pandas as pd
from label_filename import *

hm = highestmonth(str(pd.datetime.now())[:10])

scraped_files = '/Users/Matthias/Documents/LexisNexis/SEC_10qs/scraped_files/'

def fix_thisqdate(x):
  parts1=x.split('_')
  tick=parts1[0]
  date=parts1[1]
  if len(date)==7:
    date = date[:4]+'0'+date[4:7]
  fname = tick+'_'+date+'_10q.xml'
  year = int(date[:4])
  mnth = int(date[4:6])
  if (year == hm[0] and mnth <= hm[1]) or year < hm[0]:
    try:
      print(fname)
      fixedname=label_fileName(fname)
    except:
      print('failure')
  else:
    fixedname=tick+'_'+date+'_10q_THISQ.xml'
  return fixedname

for fold in os.listdir(scraped_files):
  if fold=='.DS_Store':
    pass
  
  else:

    print()
    print()
    print('starting new folder:')
    print(fold)
    print()
    print()
  
    foldlist = os.listdir(scraped_files+fold)
    L = len(foldlist)
    #for f in os.listdir(scraped_files+fold):
    c=0
    for f in foldlist:
      if c%25==0:
        print('STATUS UPDATE: %' + str(c/L))
      c+=1
    
      try:
        os.rename(scraped_files+fold+'/'+f,scraped_files+fold+'/'+fix_thisqdate(f))
      except:
        print('failure renaming on '+f)
        #break
        pass
