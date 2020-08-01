import time
import selenium
from selenium import webdriver
from bs4 import BeautifulSoup

def links(ticks):
  drivepath = '/usr/local/bin/chromedriver'
  out=[]
  is10q=False
  c=0
  link=''
  date=''
  driver=webdriver.Chrome(drivepath)
  
  for tick in ticks:
    
    try:
      driver.get('https://www.sec.gov/edgar/searchedgar/companysearch.html')
    except:
      time.sleep(1)
      try:
        driver.get('https://www.sec.gov/edgar/searchedgar/companysearch.html')
      except:
        pass
    
    try:
      form_close = driver.find_element_by_id('acsFocusFirst')
      form_close.click()
    except:
      pass
    
    try:
      company_search_box = driver.find_element_by_id('cik')
      company_search_box.send_keys(tick)
    except:
      time.sleep(1)
      try:
        try:
          company_search_box = driver.find_element_by_id('cik')
          company_search_box.send_keys(tick)
        except:
          driver.get('https://www.sec.gov/edgar/searchedgar/companysearch.html')
          time.sleep(1)
          try:
            form_close = driver.find_element_by_id('acsFocusFirst')
            form_close.click()
          except:
            pass
          time.sleep(1)
          company_search_box = driver.find_element_by_id('cik')
          company_search_box.send_keys(tick)
          time.sleep(1)
      except:
        pass
    
    try:
      search_button = driver.find_element_by_id('cik_find')
      search_button.click()
    except:
      time.sleep(1)
      try:
        search_button = driver.find_element_by_id('cik_find')
        search_button.click()
      except:
        time.sleep(2)
        driver.quit()
        driver=webdriver.Chrome(drivepath)
        time.sleep(1)
        driver.get('https://www.sec.gov/edgar/searchedgar/companysearch.html')
        time.sleep(1)
        try:
            form_close = driver.find_element_by_id('acsFocusFirst')
            form_close.click()
        except:
          pass
        time.sleep(1)
        company_search_box = driver.find_element_by_id('cik')
        company_search_box.send_keys(tick)
        time.sleep(1)
        try:
          search_button = driver.find_element_by_id('cik_find')
          search_button.click()
        except:
          pass

    time.sleep(1)
    html = driver.page_source
    #driver.quit()
    soup = BeautifulSoup(html,"lxml")

    taglist=[tag for tag in soup.find_all('td')]

    for tag in taglist:
      if len(tag.contents)<1:
        pass
      else:
        if tag.contents[0] == '10-Q':
          is10q = True
          c = 1
        if is10q:
          if 'Documents' in str(tag.contents[0]):
            link = tag.contents[0].get('href')
            c += 1
          elif 'Interactive Data' in str(tag.contents[0]):
            c += 1
          elif c == 3:
            c += 1
          elif c == 4:
            date = tag.contents[0]
            out.append((link,tick,date))
            is10q = False
            c = 0
            link = ''
            date = ''
    time.sleep(1)
  
  driver.quit()
  return out
