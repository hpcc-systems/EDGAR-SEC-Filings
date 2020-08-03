import time
import selenium
from selenium import *
from bs4 import BeautifulSoup
import Utils
from Utils import getlinks
from Utils import getxml

def process_list(ticklist):
  
  linklist=getlinks.links(ticklist)
  xmllinks=getxml.xml_links(linklist)
  xmlsourc=getxml.xml_source(xmllinks)
  
  return xmlsourc
