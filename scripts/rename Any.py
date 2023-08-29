#script explanation: 
"""
rename tiff files
TARGET FOLDER: contains the tiff files
CUSTOM TEXT: old text and new text, seperated by comma (e.g. _R9,_R8)
"""
#=======================================================
#=======================================================
#=======================================================
SCRIPT = "renameTiffs"
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
append_log("load modules")
import re

append_log("get arguements")
#renamefolderpath = os.path.dirname(__file__) #old version where the file was inside the folder
customtext = CUSTOM_TEXT.split(",")
oldString = customtext[0]
newString = customtext[1]

append_log("rename files")
files = [ file for file in os.listdir(TARGET_FOLDER) ]
for filename in files:
                    try:
                        newname = re.sub(oldString, newString, filename)
                        os.rename(filename, newname)
                        append_log(filename, " --- ", newname)
                    except Exception as e:
                        append_log(e)
                        append_log("problem renaming " + filename)
                        
os.remove(PROGRESSFILE)
