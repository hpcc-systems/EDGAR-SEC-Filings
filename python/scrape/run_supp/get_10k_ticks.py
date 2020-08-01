import os

path = '/Users/Matthias/Documents/LexisNexis/SEC_10qs/scraped_10ks'

tickfile=open('/Users/Matthias/Documents/LexisNexis/SEC_10qs/SEC_scrape/ticks_10k.csv','wt')
tickfile.write('ticker')
tickfile.write('\n')

for fold in os.listdir(path):
  if fold!='.DS_Store':
    for f in os.listdir(path+'/'+fold):
      parts = f.split('_')
      tick=parts[0]
      tickfile.write(tick)
      tickfile.write('\n')
  else:
    pass

tickfile.close()
