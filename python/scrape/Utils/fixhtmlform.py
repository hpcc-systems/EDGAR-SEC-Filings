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
