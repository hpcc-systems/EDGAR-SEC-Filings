import os
import Utils
from Utils import label_filename

labguide = open('labelguide_all_10k.csv','w')
labguide.write('"original","sandp"')
labguide.write('\n')

newlabpath = '/Users/Matthias/Documents/LexisNexis/SEC_10qs/master_10k/'

for f in os.listdir(newlabpath):

  try:
    labguide.write(f+','+label_filename.label_fileName(f,'s&p'))
    labguide.write('\n')
    print('success on this one!')
  except:
    print('failed on:')
    print(f)

labguide.close()