import time
import selenium
from selenium import *
from fixhtmlform import * 
from bs4 import BeautifulSoup

def xml_links(list10qlinks):
  data_links = []
  drivepath = '/usr/local/bin/chromedriver'
  secpath = 'https://www.sec.gov'
  driver = webdriver.Chrome(drivepath)

  for o in list10qlinks:
    driver.get(secpath + o[0])
    
    try:
      form_close = driver.find_element_by_id('acsFocusFirst')
      form_close.click()
    except:
      try:
        form_close = driver.find_element_by_id('acsFocusFirst')
        form_close.click()
      except:
        pass
    
    html_docpage = driver.page_source

    soup = BeautifulSoup(html_docpage,"lxml")
    #soup = BeautifulSoup(html_docpage,"lxml")
    #next = False
    #trs = soup.find_all('tr')
    #for tr in trs:
    #  cells = tr.find_all('td')
    #  C=len(cells)
    #  for i in range(C):
    #    if next == True:
    #      data_links.append((cells[i].get('href'),o[1],o[2]))
    #      next = False
    #    else:
    #      continue
    #    if 'XBRL INSTANCE DOCUMENT' in cells[i].getText():
    #      next = True
    #    else:
    #      continue
    taglist = [tag for tag in soup.find_all('a')]

    for tag in taglist:
      if 'htm.xml' in str(tag.text):
        data_links.append((tag.get('href'),o[1],o[2]))
  
  driver.quit()

  return data_links

def xml_source(listxmllinks):
  data_full = []
  drivepath = '/usr/local/bin/chromedriver'
  secpath = 'https://www.sec.gov'
  driver = webdriver.Chrome(drivepath)
  driver.set_page_load_timeout(1800)

  for d in listxmllinks:
    driver.get(secpath + d[0])
  
    try:
      form_close = driver.find_element_by_id('acsFocusFirst')
      form_close.click()
    except:
      pass
    
    time.sleep(2)
    dataxml = driver.page_source
    if '<html xmlns' in dataxml[:200]:
        print('ERROR: html xmlns')
        ##break
        dataxml = fix(dataxml)
    data_full.append((dataxml,d[0],d[1],d[2]))
  
  driver.quit()

  return data_full
