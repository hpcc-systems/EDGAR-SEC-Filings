import os
import Utils
from Utils import label_filename

try:
  labguide = open('../../Labels/labelguide_all_10k.csv','w')
except:
  os.mkdir('../../Labels')
  labguide = open('../../Labels/labelguide_all_10k.csv','w')
labguide.write('"original","sandp"')
labguide.write('\n')

newlabpath = '../../Filings/'

for fold in os.listdir(newlabpath):
  if fold != '.DS_Store':
    for f in os.listdir(newlabpath+fold):
      if not ('THISQ' in f):
        try:
          labguide.write(f+','+label_filename.label_fileName(f,'s&p'))
          labguide.write('\n')
          print('success on this one!')
        except:
          print('failed on: ')
          print(f)

labguide.close()
