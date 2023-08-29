# -*- coding: utf-8 -*-
"""
rename tiff files
TARGET FOLDER: no effect
CUSTOM TEXT: Opportunity number
"""
#=======================================================
#=======================================================
#=======================================================
SCRIPT = "Jira_entry_from_SFDC"
import os
import sys
from datetime import datetime
def append_log(*arguements, Logfile="logfile_scriptSelector.txt"):
    
    text = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    for arguement in arguements:
        text = text + " " + arguement
    
    with open(Logfile,"a") as f:
        f.write(text + "\n")
        
TARGET_FOLDER = sys.argv[1]
CUSTOM_TEXT = sys.argv[2]
append_log(SCRIPT, TARGET_FOLDER, CUSTOM_TEXT, Logfile="logs/log_global_scriptSelector.txt")
os.chdir(TARGET_FOLDER)

PROGRESSFILE = "scriptSelector_running.txt"
append_log("_", Logfile=PROGRESSFILE)

append_log("====" + SCRIPT + "=====")
#=======================================================
#=======================================================
#=======================================================
from jira import JIRA
import sys
import re

WANTED_OPP = sys.argv[2]
PATH = "N:/DataAnalysis/files_dashboards/data/sfdc_fulltable.txt"

MYJIRA = JIRA("https://resolve-operations.atlassian.net", basic_auth=("nicolas.huber@resolvebiosciences.com", "aiipohhTBWCimLRrcNArC53C"))
PRODUCTS ={
    "consumables":"7091002 - molecular cartography workflow consumables",
    "service":"service",
    "workflow":"workflow",
    }
ITEMS = {
    "consumables":"|60ml reagent reservoir|16| |\n"+
                  "|Reagent reservoir lid|3| |\n"+
                  "|Pipette tips|4 packs| |\n"+
                  "|Flared slide lid|5| |\n"+
                  "|Liquid waste container|1| |\n"+
                  "|Tip waste container|1| |\n"+
                  "|5ml reaction tubes|60| |\n"+
                  "|sticky wells|5| |",
    "service":"",
    "workflow":"",
    }

#generate dictionary containing the wanted opportunity
line_number = 0
keys = []
values = []
entry = {}
with open(PATH) as f:
    found_line = False
    while not found_line:
        line = f.readline().strip().split("\t")
        opp = line[0]
        if line_number == 0: 
            keys = line
            line_number += 1        
        if opp == WANTED_OPP:
            found_line = True
            values = line    
for i in range(len(keys)):
    value=""
    print(i)
    print(len(values))
    if len(values)>i: value=values[i]
    entry[keys[i]] = value

#========================================
#create an entry, then push that to Jira
opp_no = entry["Opportunity_Number"]
product = entry["projectType"]
street = re.sub("\n","",re.sub("\r","",re.sub("  "," ", entry["ShippingAddress.street"])))

issue_dict = {
    'project': {'key': "MSB"},
    'summary': opp_no,
    'labels': [product],
    'issuetype': {'name': 'Task'}, #Bug, Story, Task, for some boards only Task works
    'description': 
        'Opportunity : '+ opp_no + " - " + entry["Project_ID"] +
        '\nProduct: ' + PRODUCTS[product] + 
        '\n------------' +
        '\n*Institution  Person  Department  Street  City  PostalCode  State  Country*' +
        '\n' + entry["institution"] +
        '\n' + entry["ContactName"] +
        '\n' + entry["Department"] +
        '\n' + street + 
        '\n' + entry["ShippingAddress.city"] +
        '\n' + entry["ShippingAddress.postalCode"] +
        '\n' + entry["ShippingAddress.state"] + " (" + entry["ShippingAddress.stateCode"] + ")" +
        '\n' + entry["ShippingAddress.country"] +
        '\n------------' +
        '\n*Phone  Email*' + 
        '\n' + entry["Phone"] +
        '\n' + entry["Email"] + 
        '\n------------' +
        '\nIncoterm: ' +
        '\nPayment term: ' +
        '\n||*Item*||*Quantity*||*Status*||' +
        '\n' + ITEMS[product],
}
MYJIRA.create_issue(fields=issue_dict)

os.remove(PROGRESSFILE)