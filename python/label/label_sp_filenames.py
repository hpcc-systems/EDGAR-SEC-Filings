from useapi import *

def label_fileName(origName):

  def midtrim(s):
    out=''
    for c in s:
      if c!=' ':
        out+=c
    return out

  def fixdate(s):
    parts = s.split('_')
    date = parts[1]
    #step1 = s.split('_')
    #date = step1[1]
    year = date[:4]
    if len(date)==7:
      mnth = '0'+date[4]
    else:
      mnth = date[4:6]
    if len(date)==7:
      day = date[5:]
    else:
      day = date[6:]
    parts[1] = year+mnth+day
    return '_'.join(parts)

  def fix0s(n):
    if n<10:
      return '0'+str(n)
    else:
      return str(n)

  trimName = fixdate(midtrim(origName))
  #step1 = origName.split('_')
  step1 = trimName.split('_')
  tick = step1[0]
  date = step1[1]
  year = int(date[:4])
  mnth = int(date[4:6])
  qtr  = setq(mnth)

  labels = exqtrlabs(tick.upper(),'s&p')
  
  label = [x for x in labels if x[0]==qtr and x[1]==year][0][-1]
  #return label , qtr, year
  #return tick+'_'+str(year)+str(mnth)+date[-2:]+'_10q'+'_'+str(label)+'.xml'
  return tick+'_'+str(year)+fix0s(mnth)+date[-2:]+'_10q'+'_'+str(label)+'.xml'
