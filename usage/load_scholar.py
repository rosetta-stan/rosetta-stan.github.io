# -*- coding: utf-8 -*-
"""
Attempt to scrape scholar.google.com results for Stan usage tracking"""

#from selenium import webdriver

import requests
from bs4 import BeautifulSoup
import redis
import re
import numpy
import time
import subprocess
import os

REDIS = redis.Redis()


# retrieve
# set of queries, broken out by 3 level strucuture for each category. 
# for each query
# collect docs and estimated count
# shove in doc store

# filter
# negative regex
# positive regex
# classifier 

HEADERS = {'User-Agent': 'Mozilla/5.0(Macintosh; Intel Mac OS X 10_11_6) AppleWebkit/537.36 (KHTML, like Gecko) Chrome/61.0.3163'}
URL_PREFIX = "https://scholar.google.com/scholar?"
QUERY_PREFIX = "hl=en&as_sdt=0%2C33&q="
START_YEAR = "&hl=en&as_sdt=0%2C33&as_ylo="
END_YEAR = "&as_yhi="
#page = requests.get("http://alias-i.com/index.html", headers=headers)
YEAR_START = 2011
YEAR_END = 2020
OFFSET_PATTERN = re.compile("start....(\d+)") # needs to be fixed, hacky
GOOGLE_COUNT = 'google_count'
FILTERED_COUNT = 'filtered_count'
RAW_COUNT = 'raw_count'

PKG_QUERY = ['rstan']


def cache_retrieve(query,headers):
    page = REDIS.get(query)
    if (not page):
        print("miss cache: \n" + query)
        wait = abs(numpy.random.normal(loc=300, scale=150, size=1)[0])
        print("waiting ", wait, " seconds")
        time.sleep(wait)
        result = requests.get(query, headers=headers)
        page = result.content
        REDIS.set(query,page)
   # else:
        # print("hit cache: \n" + query)
    return page

def cache_only(query,headers):
    return REDIS.get(query)
    

def interactive_cache_retrieve(query,headers):
    page = REDIS.get(query)
    if (not page):
        done = False
        while (not done):
            print("miss cache: \n" + query)
            old_file_mod_time = os.stat('/Users/breck/git/rosetta-stan.github.io/usage/file.html').st_mtime
            subprocess.call(['open','--wait-apps','--new',query]) # blocking
        #subprocess.call(['open',query])
            # answer = input("<ctl-c> to quit,<return> when /Users/breck/git/rosetta-stan.github.io/usage/file.html is saved")
            new_file_mod_time = os.stat('/Users/breck/git/rosetta-stan.github.io/usage/file.html').st_mtime
            if (old_file_mod_time - new_file_mod_time >= 0):
                print("/Users/breck/git/rosetta-stan.github.io/usage/file.html has not changed")
                continue;
            f=open('/Users/breck/git/rosetta-stan.github.io/usage/file.html', "r")    
            page = f.read()
            f.close()
            REDIS.set(query,page)
            done = True
    return page

for i in range(0,len(PKG_QUERY)):
    package = PKG_QUERY[i]
    package_d = {}
    for year in range(YEAR_START,YEAR_END):
        package_d[year] = {GOOGLE_COUNT:0,FILTERED_COUNT:0, RAW_COUNT:0}
        done = False     
        result_start_str = ''
        first_page= True
        filtered_count = 0
        while not done:
            query =  URL_PREFIX + result_start_str + "q=" + package + START_YEAR + str(year) + END_YEAR + str(year)
            #page = cache_only(query,HEADERS)
            #page = interactive_cache_retrieve(query,HEADERS)
            page = cache_retrieve(query,HEADERS)
            if not page:
                done = True
                continue
            soup = BeautifulSoup(page, 'html.parser')
            
            count_match = soup.find(attrs={"id":"gs_ab_md"})
            if not count_match:
                raise ValueError("query got unexpected result:" + query)
            # <div id="gs_ab_md"><div class="gs_ab_mdw">Page 15 of about 137,000 results (
            if count_match and first_page:
                google_count = count_match.get_text()
                RESULTS_COUNT_PATTERN = re.compile("([\d,]+) result") # About 3,339 results (0.03 sec)'
                google_count_value = RESULTS_COUNT_PATTERN.search(google_count).group(1)
                package_d[year][GOOGLE_COUNT] = int(google_count_value.replace(',',''))
                print("Got ",package_d[year][GOOGLE_COUNT]," estimated hits" )
                first_page = False
            if package_d[year][GOOGLE_COUNT] > 3000:
                print("too many results to page", package_d[year][GOOGLE_COUNT]," for query:", query);
                break
            for mention in soup.find_all(attrs={"class": "gs_r gs_or gs_scl"}): #go through indivudual mentions
                package_d[year][RAW_COUNT] += 1
                abstract = mention.find(attrs={"class":"gs_rs"})
                if abstract:
                    abs_text = mention.get_text()
                    #print("TEXT:",abs_text)
                    if package=='rstan': 
                        abs_text_clean = re.sub(r'</b>|<b>|\s|-','',abs_text) #  'U n d e <b>rstan</b> d th e '
                        understand_p = re.compile('understand',re.IGNORECASE)
                        if understand_p.search(abs_text_clean): 
                     #       print("skipping as part of 'understand':", abs_text_clean)
                            continue
                        rstan_token_p = re.compile('\srstan\s',re.IGNORECASE)
                        rstan_substr_p = re.compile('rstan',re.IGNORECASE)
                        if rstan_substr_p.search(abs_text) and not rstan_token_p.search(abs_text):
                            #print("skipping for no token 'rstan' but substring:",abs_text)
                            continue
                        package_d[year][FILTERED_COUNT] += 1
                        #print("kept:",abs_text)
            next_button = soup.find(name='button', attrs={"aria-label":"Next"})
            if next_button and next_button.attrs.get('onclick'):
                link = next_button.attrs.get('onclick')
                result_start = re.compile(OFFSET_PATTERN).search(link).group(1)
                result_start_str =  'start=' + result_start + '&'
            else:
               done = True
        print("Package:", package, "year: ", year, "google count:", 
              package_d[year][GOOGLE_COUNT], "filter count:", package_d[year][FILTERED_COUNT],
              "raw_count:",package_d[year][RAW_COUNT])
               
               #print("Package: ", package, " year: ", year, "count: ", package_d[year][FILTERED_COUNT])


# first abstract
#abstract = soup.find_all(attrs={"class": "gs_r gs_or gs_scl"})[0].find(attrs={"class":"gs_rs"})
#abstract.get_text()
#soup.find_all(attrs={"class": "gs_or"})[0].a
#entry = soup.find_all(attrs={"class": "gs_or"})[0]
#link = soup.find_all(attrs={"class": "gs_or"})[0].a['href']



