import os
import yfinance as yf
import pandas as pd

path = '/Users/Matthias/Documents/LexisNexis/SEC_10qs/thisq_10q'

files = os.listdir(path)

sptick = yf.Ticker("SPY")
sphist = sptick.history(period="daily",start="2015-01-01")

outfile = open('thisq_perf.csv','w')
outfile.write("fname,tot_return,sp_return")
outfile.write("\n")

def no_ws(s):
  out=''
  for c in s:
    if c != ' ':
      out+=c
  return out

def price_change(d,t):
  tick = yf.Ticker(t)
  hist = tick.history(period="daily",start=d[:4]+'-'+d[4:6]+'-'+d[6:],end='2020-06-01')
  start_p = hist.iloc[0].Close
  end_p = hist.iloc[-1].Close
  return (end_p/start_p)-1

for f in files:
  f=no_ws(f)
  parts=f.split('_')
  tick=parts[0]
  date=parts[1]
  try:
    totr=price_change(date,tick)
    spr =price_change(date,'SPY')
    outfile.write(f+','+str(totr)+','+str(totr-spr))
  except:
    outfile.write(f+',error,error')
  outfile.write("\n")

outfile.close()
