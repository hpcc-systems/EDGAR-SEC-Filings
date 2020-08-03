import time
import selenium
from selenium import *
from scrape_utils import * 
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

    taglist = [tag for tag in soup.find_all('a')]

    for tag in taglist:
      if 'htm.xml' in str(tag.text):
        data_links.append((tag.get('href'),o[1],o[2],o[3]))
  
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
        print('ERROR: html xmlns, fixing format')
        dataxml = fix(dataxml)
    data_full.append((dataxml,d[0],d[1],d[2],d[3]))
  
  driver.quit()

  return data_full
