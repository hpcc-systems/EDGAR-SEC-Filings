import os
import label_sp_filenames
from label_sp_filenames import *

#for testing import useapi
import useapi
from useapi import *
#

#labguide = open('labelguide.csv','w')
#labguide = open('labelguide_full.csv','w')
#labguide = open('labelguide_all.csv','w')
labguide = open('labelguide_all_10k.csv','w')
labguide.write('"original","sandp"')
labguide.write('\n')

#newlabpath = '/Users/Matthias/Documents/LexisNexis/SEC_10qs/scraped_files/num_labels_new/'
#newlabpath = '/Users/Matthias/Documents/LexisNexis/SEC_10qs/scraped_files/num_labels_0629/'
#newlabpath = '/Users/Matthias/Documents/LexisNexis/SEC_10qs/master_labeled/'
newlabpath = '/Users/Matthias/Documents/LexisNexis/SEC_10qs/master_10k/'

def midtrim(s):
  out=''
  for c in s:
    if c!=' ':
      out+=c
  return out

for f in os.listdir(newlabpath):
  #try:
  #  labguide.write(f + ',' + label_fileName(f))
  #  labguide.write('\n')
  #except:
  #  print(f)
  #  try:
  #    def midtrim(s):
  #      out=''
  #      for c in s:
  #        if c!=' ':
  #          out+=c
  #      return out
  #    print(exqtrlabs(midtrim(f).split('_')[0].upper(),'s&p'))
  #  except:
  #    print(midtrim(f))

#  try:
#    trimf = midtrim(f)
#    trimtick = trimf.split('_')
#    tt = trimtick[0].upper()
#    labguide.write(f+','+exqtrlabs(tt,'s&p'))
#    print('success!')
#  except:
#    print('issue found')
#    print(f)

  try:
    labguide.write(f+','+label_fileName(f))
    labguide.write('\n')
    print('success on this one!')
  except:
    print('failed on:')
    print(f)

labguide.close()
