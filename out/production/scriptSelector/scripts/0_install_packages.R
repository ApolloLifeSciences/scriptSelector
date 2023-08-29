
SCRIPT="intensity_plots"
LOGFILE <- paste0("log_",SCRIPT,".txt")
append_log <- function(..., Logfile=LOGFILE){
  try(
    write(paste(Sys.time(), ...), file=Logfile, append = TRUE),
    silent = TRUE
  )
}
do <- function(anything, Logfile=LOGFILE){
  out <- try(anything)
  if(class(out) %in% "try-error") append_log(out, Logfile=Logfile)
  return(out)
}

append_log("====start=====")
do({
  cmd_args <- commandArgs(trailingOnly=TRUE)
  current_folder <- cmd_args[1]
  setwd(current_folder)
  
  PROGRESSFILE <- "r_Un_n_In_g.txt"
  write.table(data.frame(), PROGRESSFILE)
})
do({
  package_files <- list.files(path = "packages", pattern = "zip$", full.names = T)
  sapply(package_files, function(x) {
    append_log(x)
    install.packages(x, repos = NULL, type = "win.binary")
  })
  tinytex::install_tinytex()
})
append_log("====end====")
do(file.remove(PROGRESSFILE))