print("script started")

SCRIPT="zLevel_counts"
LOGFILE <- paste0("logs/log_",SCRIPT,".txt")
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
append_log(SCRIPT)
do({
  cmd_args <- commandArgs(trailingOnly=TRUE)
  current_folder <- cmd_args[1]
  setwd(current_folder)
})
append_log("====start=====")
PROGRESSFILE <- "r_Un_n_In_g.txt"
do(write.table(data.frame(), PROGRESSFILE))
append_log("load libraries")
do({
  library(dplyr)
  library(magrittr)
  library(ggplot2)
  library(data.table)
})
append_log("define functions")

append_log("load files and calculate")
do({
  result_files <- list.files(recursive=F, pattern="results.txt") %>% `names<-`(gsub("Panorama_(.*)_.*$","\\1",.))
  
  results <- lapply(names(result_files), function(x) {
    read.table(result_files[[x]], sep="\t", header=T) %>% as.data.table() %>% `colnames<-`(c("x","y","z","gene","empty")) %>% 
      select(z) %>% mutate(ROI=x)
  }) %>% do.call(rbind, .) %>% 
    group_by(z,ROI) %>% summarise(count=n()) %>% 
    group_by(ROI) %>% mutate(rel.count=count/sum(count)*100) %>% as.data.table()
})
append_log("generate graphs")
do({
  append_log("graph1")
  p <- ggplot(results, aes(z,rel.count, fill=z)) +
    geom_bar(stat="identity", color=NA) +
    facet_wrap(~ROI) +
    scale_x_continuous(limits=c(0,NA), expand=c(0,0), name="Z-level") +
    scale_y_continuous(limits=c(0,NA), expand=c(0,0), name="relative count (%)") +
    scale_fill_gradient(low="green",high="magenta") +
    theme_bw() +
    theme(legend.position="none")
  ggsave("zLevel_counts_singleROIs.png", p, width=10, height=10)
  append_log("graph2")
  p2 <- ggplot(results, aes(z,rel.count,color=ROI)) +
    geom_line() +
    scale_x_continuous(limits=c(0,NA), expand=c(0,0), name="Z-level") +
    scale_y_continuous(limits=c(0,NA), expand=c(0,0), name="relative count (%)") +
    theme_bw() +
    theme()
  ggsave("zLevel_counts_mergedROI.png", p2, width=10, height=10)
})
append_log("====end====")
do(file.remove(PROGRESSFILE))