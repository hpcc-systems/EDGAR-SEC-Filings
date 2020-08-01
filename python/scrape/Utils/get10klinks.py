import time
import selenium
from selenium import webdriver
from bs4 import BeautifulSoup

##experimental import related to new search page structure
from selenium.webdriver.common.keys import Keys
##

def links(ticks):
  drivepath = '/usr/local/bin/chromedriver'
  out=[]
  is10q=False
  c=0
  link=''
  date=''
  driver=webdriver.Chrome(drivepath)
  
  for tick in ticks:
    
    #strip whitespace
    tick = tick.strip()
    try:
      #driver.get('https://www.sec.gov/edgar/searchedgar/companysearch.html')
      driver.get('https://www.sec.gov/edgar/searchedgar/legacy/companysearch.html')
    except:
      #time.sleep(1)
      try:
        #driver.get('https://www.sec.gov/edgar/searchedgar/companysearch.html')
        driver.get('https://www.sec.gov/edgar/searchedgar/legacy/companysearch.html')
      except:
        pass
    
    try:
      form_close = driver.find_element_by_id('acsFocusFirst')
      form_close.click()
    except:
      pass
    
    try:
      company_search_box = driver.find_element_by_id('cik')
      #company_search_box = driver.find_element_by_id('company')
      company_search_box.send_keys(tick)
    except:
      #time.sleep(1)
      try:
        try:
          company_search_box = driver.find_element_by_id('cik')
          company_search_box.send_keys(tick)
        except:
          #driver.get('https://www.sec.gov/edgar/searchedgar/companysearch.html')
          driver.get('https://www.sec.gov/edgar/searchedgar/legacy/companysearch.html')
          #time.sleep(1)
          try:
            form_close = driver.find_element_by_id('acsFocusFirst')
            form_close.click()
          except:
            pass
          #time.sleep(1)
          company_search_box = driver.find_element_by_id('cik')
          company_search_box.send_keys(tick)
          #time.sleep(1)
      except:
        pass
    
    try:
      #search_button = driver.find_element_by_id('cik_find')
      #search_button = driver.find_element_by_id('search_button')
      #search_button.click()
      #company_search_box.send_keys(Keys.RETURN)
      company_search_box.submit()
    except:
      #time.sleep(1)
      try:
        #search_button = driver.find_element_by_id('cik_find')
        #search_button = driver.find_element_by_id('search_button') 
        #search_button.click()
        #company_search_box.send_keys(Keys.RETURN)
        company_search_box.submit()
      except:
        #time.sleep(2)
        driver.quit()
        driver=webdriver.Chrome(drivepath)
        #time.sleep(1)
        #driver.get('https://www.sec.gov/edgar/searchedgar/companysearch.html')
        driver.get('https://www.sec.gov/edgar/searchedgar/legacy/companysearch.html')
        try:
            form_close = driver.find_element_by_id('acsFocusFirst')
            form_close.click()
        except:
          pass
        #time.sleep(1)
        company_search_box = driver.find_element_by_id('cik')
        #company_search_box = driver.find_element_by_id('company')
        company_search_box.send_keys(tick)
        try:
          #search_button = driver.find_element_by_id('cik_find')
          #search_button = driver.find_element_by_id('search_button')
          #search_button.click()
          #company_search_box.send_keys(Keys.RETURN)
          company_search_box.submit()
        except:
          pass

    time.sleep(1)
    html = driver.page_source
    #driver.quit()
    soup = BeautifulSoup(html,"lxml")

    taglist=[tag for tag in soup.find_all('td')]

    for tag in taglist:
      if len(tag.contents) < 1:
        pass
      else:
        #if tag.contents[0] == '10-Q':
        if tag.contents[0] == '10-K': 
          c=1
        elif c==1:
          link = tag.contents[0].get('href')
          c+=1
        elif c==2:
          c+=1
        elif c==3:
          date = tag.contents[0]
          c=0
          out.append((link,tick,date))

    #time.sleep(1)
  
  driver.quit()
  return out
