# -*- coding: utf-8 -*-
"""
Created on Thu Nov 24 12:36:45 2022

@author: nicolas.huber
"""

from datetime import datetime

def append_log(*arguements, Logfile="logfile_scriptSelector.txt"):
    
    text = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    for arguement in arguements:
        text = text + " " + arguement
    
    with open(Logfile,"a") as f:
        f.write(text + "\n")