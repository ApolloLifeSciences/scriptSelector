#script explanation: (important to keep this in lines 3-5!)
"
removes FP data from a results.txt file
TARGET FOLDER: a folder with results.txt files
CUSTOM TEXT: no effect
"
#=======================================================
#=======================================================
#=======================================================
SCRIPT <- "remove FPs" #short, name of your script of your script (will be used in the logfile)
#eave the rest as is, until you reach "your code"
source("functions/write_Logfile.R")
source("functions/resolve_changeNames.R")
do({
  cmd_args <- commandArgs(trailingOnly=TRUE)
  JAR_FOLDER <- getwd()
  TARGET_FOLDER <- cmd_args[1]
  CUSTOM_TEXT <- cmd_args[2]
  append_log(SCRIPT, TARGET_FOLDER, CUSTOM_TEXT, Logfile="logs/log_global_scriptSelector.txt")
  setwd(TARGET_FOLDER)

  # PROGRESSFILE <- "scriptSelector_running.txt"
  # append_log("_", Logfile=PROGRESSFILE) #this file signals to java that the process is ongoing; important for progress bar
})
# append_log(paste("====",SCRIPT,"====="))
#=======================================================
#=======================================================
#=======================================================
#load file
file_paths <- list.files(TARGET_FOLDER, pattern="results.txt$")

lapply(file_paths, function(filePath){
  
  do(dt <- data.table::fread(filePath, sep = "\t", stringsAsFactors = F, header = F, col.names = c("xval", "yval", "zval", "id", "empty")))
  do(dt <- subset(dt, !startsWith(id, "FP ")))
  
  if(nrow(dt)>0) do(data.table::fwrite(x=dt, file=filePath, append=F, sep="\t", quote=F, row.names = F, col.names = F))
})

#=======================================================
#=======================================================
#=======================================================
# unlink(PROGRESSFILE) #signals to java that the process is done (progress bar is then filled)


