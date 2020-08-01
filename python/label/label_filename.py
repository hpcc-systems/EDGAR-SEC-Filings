from useapi import *

def label_fileName(origName):
  step1 = origName.split('_')
  tick = step1[0]
  date = step1[1]
  year = int(date[:4])
  mnth = int(date[4:6])
  qtr  = setq(mnth)

  labels = qtrlabels(tick.upper())
  
  def fix0s(n):
    if n<10:
      return '0'+str(n)
    else:
      return str(n)

  label = [x for x in labels if x[0]==qtr and x[1]==year][0][-1]
  #return label , qtr, year
  #return tick+'_'+str(year)+str(mnth)+date[-2:]+'_10q'+'_'+str(label)+'.xml'
  return tick+'_'+str(year)+fix0s(mnth)+date[-2:]+'_10q'+'_'+str(label)+'.xml'
