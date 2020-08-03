import time
import selenium
from selenium import *
from bs4 import BeautifulSoup
from getlinks import *
from getxml import *

def process_list(ticklist):
  
  linklist=links(ticklist)
  xmllinks=xml_links(linklist)
  xmlsourc=xml_source(xmllinks)
  
  return xmlsourc
