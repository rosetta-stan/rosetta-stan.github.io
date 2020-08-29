#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Aug 29 12:10:07 2020

@author: breck
"""

from bs4 import BeautifulSoup
import redis
import re
import os

#iterate over redis, find pages that don't have results b/c of blocking

#"\n\nhttps://scholar.google.com/scholar?q=rstan&hl=en&as_sdt=0%2C33&as_ylo=2017&as_yhi=2017\n\n\n\n\n\nvar submitCallback = function(response) {document.getElementById('captcha-form').submit();};\n\n\n\n\n\nAbout this page\n\nOur systems have detected unusual traffic from your computer network.  This page checks to see if it's really you sending the requests, and not a robot.  Why did this happen?\n\nThis page appears when Google automatically detects requests coming from your computer network which appear to be in violation of the Terms of Service. The block will expire shortly after those requests stop.  In the meantime, solving the above CAPTCHA will let you continue to use our services.This traffic may have been sent by malicious software, a browser plug-in, or a script that sends automated requests.  If you share your network connection, ask your administrator for help — a different computer using the same IP address may be responsible.  Learn moreSometimes you may be asked to solve the CAPTCHA if you are using advanced terms that robots are known to use, or sending requests very quickly.\n\n\nIP address: 72.10.199.91Time: 2020-08-28T14:51:07ZURL: https://scholar.google.com/scholar?q=rstan&hl=en&as_sdt=0%2C33&as_ylo=2017&as_yhi=2017\n\n\n\n\n"

REDIS = redis.Redis()


queries = REDIS.keys(pattern='http*')

for query in queries:
    page = REDIS.get(query)
    soup = BeautifulSoup(page, 'html.parser')
    count_match = soup.find(attrs={"id":"gs_ab_md"})
    text = soup.get_text()
    bounce_message = "Our systems have detected unusual traffic from your computer network"
    if bounce_message in text:
        print(query)
    else:
        continue

    #query = input("Please enter query to load without quotes (key): ")
    #print("You entered " + str(query))

    answer = input("(d)elete/(u)pdate/(i)gnore cache entry? (q) to quit:d/u/i/q")
    done = False
    while (not done):
        if answer=='d':
            REDIS.delete(query)
            print("entry deleted")
            done = True
        elif answer=='q':
            print("quitting")
            done = True
            break
        elif answer=="n":
            done = True
        elif answer=="u":
            done = True
            file_path = input("Please enter file to have as new value ")
            print("You entered " + str(file_path))
            f=open(file_path, "r")
            data = f.read()
            f.close()
            soup2 = BeautifulSoup(data, 'html.parser')
            count_match = soup2.find(attrs={"id":"gs_ab_md"})
            print("count match:", count_match)
            answer = input("update cache?:y/n")
            done2 = False
            while (not done2):   
                if answer=='y':
                    REDIS.set(query,data)
                    print("cache updated")
                    done2 = True
                elif answer=="n":
                    print("cache not updated")
                    done2 = True
                    
   
    




#give query
#filename downloaded