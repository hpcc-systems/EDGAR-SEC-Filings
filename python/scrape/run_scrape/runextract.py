import pandas as pd
import numpy as np
from extract_data import *
from scrape_utils import *
import sys
import pandas as pd
from useapi import *
from label_filename import *

##experimental addition trying to label as we scrape##
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

hm = highestmonth(str(pd.datetime.now())[:10])
##end experimental addition

companies = pd.read_csv('/Users/Matthias/Downloads/companylist.csv')
bigticklist = list(companies.Symbol)
bigsectlist = list(companies.Sector)
B = len(bigticklist)
j = int(sys.argv[1])
batchsize = int(sys.argv[2])

ticklist = bigticklist[j:min((j+batchsize),B)]
sectlist = bigsectlist[j:min((j+batchsize),B)]
if B<=j+batchsize:
  print('NO MORE DATA TO PROCESS AFTER THIS...')

for i in range(len(ticklist)):
  print('|'+int(i/5)*'#'+int((batchsize-i)/5)*' '+'|'+str(i*100/batchsize)+'%'+'current: '+ticklist[i])
  
  try:
    xmldata = process_list([ticklist[i]])
  except:
    print(j+i)
    break
  
  scrape_path = '/Users/Matthias/Documents/LexisNexis/SEC_10qs/scraped_files/'

  for x in xmldata:
    fname = x[2].lower()+'_'+fixdate(x[-1])+'_10q.xml'

    ##experimental code to label as we scrape
    step1 = fname.split('_')
    year = int(step1[1][:4])
    month = int(step1[1][4:6])
    if (year == hm[0] and month <= hm[1]) or year < hm[0]:
      newf = label_fileName(fname)
    else:
      newf = fname[:-4]+'_THISQ.xml'
    ##end experimental code

    ##xml_file = open(scrape_path+foldpath(sectlist[i])+'/'+x[2].lower()+'_'+fixdate(x[-1])+'_10q.xml','w')
    xml_file = open(scrape_path+foldpath(sectlist[i])+'/'+newf,'w')
    xml_file.write(x[0])
    xml_file.close()

print(j+i)
