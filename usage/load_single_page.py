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


REDIS = redis.Redis()


queries = REDIS.keys(pattern='http*')

for query in queries:
    page = REDIS.get(query)
    soup = BeautifulSoup(page, 'html.parser')
    count_match = soup.find(attrs={"id":"gs_ab_md"})
    text = soup.get_text()
    bounce_message = "Our systems have detected unusual traffic from your computer network"
    bounce_message = "Please show you're not a robot"
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
        elif answer=="i":
            print("ignoring")
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