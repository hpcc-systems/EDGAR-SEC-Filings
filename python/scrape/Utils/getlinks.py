import time
import selenium
from selenium import webdriver
from bs4 import BeautifulSoup

##This script obtains the links to all 10-K/Q
##documents for the given list of ticker symbols
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

    #go to company search page
    try:
      driver.get('https://www.sec.gov/edgar/searchedgar/legacy/companysearch.html')
    except:
      try:
        driver.get('https://www.sec.gov/edgar/searchedgar/legacy/companysearch.html')
      except:
        pass
    
    #attempt to close the user survey window, if it has appeared
    try:
      form_close = driver.find_element_by_id('acsFocusFirst')
      form_close.click()
    except:
      pass
    
    #search by CIK
    try:
      company_search_box = driver.find_element_by_id('cik')
      company_search_box.send_keys(tick)
    except:
      #try again (including starting over from company search)
      #in case a temporary issue such as connectivity occurred
      try:
        try:
          company_search_box = driver.find_element_by_id('cik')
          company_search_box.send_keys(tick)
        except:
          driver.get('https://www.sec.gov/edgar/searchedgar/legacy/companysearch.html')
          try:
            form_close = driver.find_element_by_id('acsFocusFirst')
            form_close.click()
          except:
            pass
          company_search_box = driver.find_element_by_id('cik')
          company_search_box.send_keys(tick)
      except:
        pass
    
    #submit CIK to be searched, including possibly restarting if
    #an error occurred
    try:
      company_search_box.submit()
    except:
      try:
        company_search_box.submit()
      except:
        driver.quit()
        driver=webdriver.Chrome(drivepath)
        driver.get('https://www.sec.gov/edgar/searchedgar/legacy/companysearch.html')
        try:
            form_close = driver.find_element_by_id('acsFocusFirst')
            form_close.click()
        except:
          pass
        company_search_box = driver.find_element_by_id('cik')
        company_search_box.send_keys(tick)
        try:
          company_search_box.submit()
        except:
          pass

    time.sleep(1)

    #get page source to find document page links
    html = driver.page_source
    soup = BeautifulSoup(html,"lxml")

    taglist=[tag for tag in soup.find_all('td')]

    #select only document links associated with a 10-K/Q
    #there is a pattern on 10-K/Q links in which
    #two links, Document and Interactive, are available
    #we only want Document, so a counting procedure is
    #used to identify the appropriate link, which is
    #then saved to a tuple with ticker and date
    for tag in taglist:
      if len(tag.contents) < 1:
        pass
      else:
        if tag.contents[0] in ['10-Q','10-K']:##== formtyp: 
          c=1
          formtyp = tag.contents[0]
        elif c==1:
          link = tag.contents[0].get('href')
          c+=1
        elif c==2:
          c+=1
        elif c==3:
          date = tag.contents[0]
          c=0
          out.append((link,tick,formtyp,date))
  
  driver.quit()
  return out