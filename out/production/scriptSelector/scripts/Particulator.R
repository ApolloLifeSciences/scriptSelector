print("script started")

SCRIPT="Particulator"
LOGFILE <- paste0("log_",SCRIPT,".txt")
LOGFILE0 <- paste0("logs/", LOGFILE)
append_log <- function(..., Logfile=LOGFILE){
  try(
    write(paste(Sys.time(), ...), file=Logfile, append = TRUE),
    print(...),
    silent = TRUE
  )
}
do <- function(anything, Logfile=LOGFILE){
  out <- try(anything)
  if(class(out) %in% "try-error") append_log(out, Logfile=Logfile)
  return(out)
}
append_log(SCRIPT, Logfile = LOGFILE0)
do({
  cmd_args <- commandArgs(trailingOnly=TRUE)
  target_folder <- cmd_args[1]
  arguements <- cmd_args[2]
  rmdfile <- paste(getwd(),list.files(path="report_templates", pattern="^Particulator.Rmd$", full.names = T), sep="/")
  setwd(target_folder)
})
append_log("====start=====")
PROGRESSFILE <- "r_Un_n_In_g.txt"
do(write.table(data.frame(), PROGRESSFILE))
append_log("load libraries")

append_log("define functions")

append_log("copy Rmd file")
do({
  file.copy(
    from = rmdfile,
    to = target_folder
  )
})
Sys.sleep(3)
append_log("run Rmd file")
do({
  minmaxvals <- c(100,300)
  append_log("arguements: ", arguements)
  if(!is.na(arguements)) minmaxvals <- strsplit(gsub(" ","",arguements), ",")[[1]]
  append_log("minmaxvals: ", minmaxvals)
  pandocpath <- path.expand("~/../AppData/Local/Pandoc")
  Sys.setenv(RSTUDIO_PANDOC = pandocpath)
  
  rmarkdown::render(
    input = paste0(target_folder, "/Particulator.Rmd"),
    output_file = "particle_report.html",
    params = list(minval=minmaxvals[1], maxval=minmaxvals[2])
  )
})
append_log("====end====")
do(file.remove(PROGRESSFILE))