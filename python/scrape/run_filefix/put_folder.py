import os
import pandas as pd
import shutil
from scrape_utils import foldpath

comp = '/Users/Matthias/Downloads/companylist.csv'
pathmain = '/Users/Matthias/Documents/LexisNexis/SEC_10qs/scraped_files'

comps = pd.read_csv(comp)

os.chdir(pathmain)

for f in os.listdir(pathmain):
  
  if f[0]=='.':
    fname = f[1:]
  else:
    fname = f
  
  if '.xml' in fname:

    fname = fname.split('_')
    tick = fname[0].upper()
    print(tick)
    sect = list(comps.loc[comps.Symbol==tick].Sector)[0]
    print(foldpath(sect))
    shutil.copy(pathmain+'/'+f,pathmain+'/'+foldpath(sect))
  else:
    
    pass
