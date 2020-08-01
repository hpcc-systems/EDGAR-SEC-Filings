import os
import fixhtmlform
from fixhtmlform import *

newlabpath = '/Users/Matthias/Documents/LexisNexis/SEC_10qs/scraped_files/num_labels_new/'
i=0
j=0
for f in os.listdir(newlabpath):
  htmlform=False
  i+=1
  with open(newlabpath+f,'r') as content_file:
    content = content_file.read()
    if '<html xmlns' in content[:200]:
      j+=1
      htmlform=True
      print('Found one')
      print(content[:200])
  #if htmlform:
  #  with open(newlabpath+f,'w') as content_file:
  #    content_file.write(fix(content))
  #    print('Fixed one')

print(str(i) +'total files')
print(str(j) +'html files')
