from useapi import *
from scrape_utils import *

def label_fileName(origName,comp='plain'):
  step1 = origName.split('_')
  tick = step1[0]
  date = step1[1]
  form = step1[2]
  year = int(date[:4])
  mnth = int(date[4:6])
  label = qtrlabels(tick.upper(),date,comp)
  return tick+'_'+str(year)+fix0s(mnth)+date[-2:]+'_'+form+'_'+str(label)+'.xml'