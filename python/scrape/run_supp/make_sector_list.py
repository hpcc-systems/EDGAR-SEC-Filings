import os

sectorguide = open('sector_guide_all.csv','w')
sectorguide.write('sector,filename')
sectorguide.write('\n')
filepath = '/Users/Matthias/Documents/LexisNexis/SEC_10qs/scraped_files/'

for fold in os.listdir(filepath):
  if fold == '.DS_Store':
    pass
  else:
    for f in os.listdir(filepath+fold):
      sectorguide.write(fold+','+f)
      sectorguide.write('\n')

sectorguide.close()
