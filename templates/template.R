#script explanation: (important to keep this in lines 3-5!)
"
...a short (1 line) description of what the script does; the fewer letters the better
TARGET FOLDER: ...a description of what the folder should contain; if not used, write:  no effect
CUSTOM TEXT: ...what arguements (separated by what separator);          if not used, write:   no effect
"
#=======================================================
#=======================================================
#=======================================================
SCRIPT <- "my script" #short, name of your script of your script (will be used in the logfile)
#eave the rest as is, until you reach "your code"
source("functions/write_Logfile.R")
do({
  cmd_args <- commandArgs(trailingOnly=TRUE)
  JAR_FOLDER <- getwd()
  TARGET_FOLDER <- cmd_args[1]
  CUSTOM_TEXT <- cmd_args[2]
  append_log(SCRIPT, TARGET_FOLDER, CUSTOM_TEXT, Logfile="logs/log_global_scriptSelector.txt")
  setwd(TARGET_FOLDER)
  
  PROGRESSFILE <- "scriptSelector_running.txt"
  append_log("_", Logfile=PROGRESSFILE) #this file signals to java that the process is ongoing; important for progress bar
})
append_log(paste("====",SCRIPT,"====="))
#=======================================================
#=======================================================
#=======================================================


# ...your code


#=======================================================
#=======================================================
#=======================================================
do(unlink(PROGRESSFILE)) #signals to java that the process is done (progress bar is then filled)