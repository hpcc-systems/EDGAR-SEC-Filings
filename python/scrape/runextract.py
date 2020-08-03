import pandas as pd
import numpy as np
from extract_data import *
from scrape_utils import *
import sys
import pandas as pd
from useapi import *
from label_filename import *

hm = highestmonth(str(pd.datetime.now())[:10])

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
    fname = x[2].lower()+'_'+fixdate(x[-1])+'_'+''.join(x[3].split('-')).lower()+'.xml'

    step1 = fname.split('_')
    year = int(step1[1][:4])
    month = int(step1[1][4:6])
    if (year == hm[0] and month <= hm[1]) or year < hm[0]:
      newf = label_fileName(fname)
    else:
      newf = fname[:-4]+'_THISQ.xml'

    xml_file = open(scrape_path+foldpath(sectlist[i])+'/'+newf,'w')
    xml_file.write(x[0])
    xml_file.close()

print(j+i)