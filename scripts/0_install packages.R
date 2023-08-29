#script explanation: 
"
install R packages for scriptSelector R scripts
TARGET FOLDER: no effect
CUSTOM TEXT: no effect
"
#=======================================================
#=======================================================
#=======================================================
SCRIPT <- "install R packages"
source("functions/write_Logfile.R")
do({
  cmd_args <- commandArgs(trailingOnly=TRUE)
  JAR_FOLDER <- getwd()
  TARGET_FOLDER <- cmd_args[1]
  CUSTOM_TEXT <- cmd_args[2]
  append_log(SCRIPT, TARGET_FOLDER, CUSTOM_TEXT, Logfile="logs/log_global_scriptSelector.txt")
  setwd(TARGET_FOLDER)
  
  PROGRESSFILE <- "scriptSelector_running.txt"
  append_log("_", Logfile=PROGRESSFILE)
})
#=======================================================
#=======================================================
#=======================================================
do({
  package_files <- list.files(path = paste0(JAR_FOLDER,"/../packages"), pattern = "zip$", full.names = T)
  sapply(package_files, function(x) {
    install.packages(x, repos = NULL, type = "win.binary")
  })
  tinytex::install_tinytex(force = TRUE)
})
#=======================================================
#=======================================================
#=======================================================
do(unlink(PROGRESSFILE))