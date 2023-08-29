#script explanation: 
"
generate 2 plots showing the counts in each Z level
TARGET FOLDER: contains files ending with 'results.txt'
CUSTOM TEXT: no effect
"
#=======================================================
#=======================================================
#=======================================================
SCRIPT <- "zLevelCounts.txt"
source("functions/write_Logfile.R")
do({
  cmd_args <- commandArgs(trailingOnly=TRUE)
  TARGET_FOLDER <- cmd_args[1]
  CUSTOM_TEXT <- cmd_args[2]
  append_log(SCRIPT, TARGET_FOLDER, CUSTOM_TEXT, Logfile=paste0("logs/log_global_scriptSelector.txt"))
  setwd(TARGET_FOLDER)
  
  PROGRESSFILE <- "scriptSelector_running.txt"
  append_log("_", Logfile=PROGRESSFILE)
})
append_log(paste("====",SCRIPT,"====="))
#=======================================================
#=======================================================
#=======================================================
append_log("load packages")
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