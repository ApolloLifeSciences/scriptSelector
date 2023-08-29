print("script started")

SCRIPT="HeLa_comparison"
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
  CURRENT_FOLDER <- cmd_args[1]
  setwd(CURRENT_FOLDER)
})
append_log("====start=====")
PROGRESSFILE <- "r_Un_n_In_g.txt"
do(write.table(data.frame(), PROGRESSFILE))
append_log("load libraries")
do({
  library(dplyr)
  library(ggplot2)
  library(data.table)
  library(magrittr)
})
append_log("define functions")

append_log("list summary_transcripts.txt files")
runs_tobe_avoided <- "" #c("Groot_2022-04-04","SAM_2022-04-01","SAM_2022-05-06","Hans_2022-05-03","Heidelberg_2022-04-27")
do({
  CURRENT_RUN <- gsub(".*[/\\]","",CURRENT_FOLDER)
  append_log("CURRENT_RUN: ", CURRENT_RUN)
  ARCHIVE <- "N:/DataAnalysis/archive_validationHotruns/"
  gene_files <- list.files(ARCHIVE, recursive=T, pattern="summary_transcripts.txt", full.names = T) %>% 
    `names<-`(gsub(".*//","",gsub("/tables.*","",.))) %>% 
    {.[!names(.) %in% runs_tobe_avoided]}
  append_log("files found: ", length(gene_files))
  gene_files %<>% c(list.files(recursive=T, pattern="summary_transcripts.txt") %>% `names<-`(CURRENT_RUN))
  append_log("current run added, now: ", length(gene_files))
  gene_list <- lapply(names(gene_files), function(x) {
    append_log("read: ", gene_files[[x]])
    tab <- read.table(gene_files[[x]], sep="\t", header=T) %T>% {append_log("as.data.table")} %>% 
      as.data.table() %T>% {append_log("mutate")} %>% 
      mutate(hotrun=x) %T>% {append_log("subset")} %>% 
      subset(!fp & !symbol=="" & (hotrun==CURRENT_RUN | !grepl("_.*_",hotrun)) ) %T>% {append_log("group_by")} %>% 
      group_by(hotrun,symbol) %T>% {append_log("summarise")} %>% 
      summarise(count=mean(count, na.rm=T))
    return(tab)
  })
})
append_log("list summary_ROIs.txt files")
do({
  count_files <- list.files(ARCHIVE, recursive=T, pattern="summary_ROIs.txt", full.names = T) %>% 
    `names<-`(gsub(".*//","",gsub("/tables.*","",.))) %>% 
    {.[!names(.) %in% runs_tobe_avoided]}
  count_files %<>% c(count_files, list.files(recursive=T, pattern="summary_ROIs.txt") %>% `names<-`(CURRENT_RUN))
  count_list <- lapply(names(count_files), function(x) {
    tab <- read.table(count_files[[x]], sep="\t", header=T) %>% as.data.table() %>% mutate(hotrun=x) %>% 
      group_by(hotrun) %>% 
      summarise(count_per_cell=mean(count_per_cell, na.rm=T), total_transcript_count=mean(total_transcript_count, na.rm=T))
    if("count_per_cell" %in% colnames(tab)) return(tab)
    return(NULL)
  })
})
append_log("combine count tables")
do({
  dt0 <- do.call(rbind, count_list)
})
append_log("combine gene tables and merge with count table")
do({
  dt <- do.call(rbind, gene_list) %>% 
    merge(dt0, by=c("hotrun")) %>%
    mutate(cpc=count/total_transcript_count*count_per_cell) %>% 
    subset(cpc>0) %>% as.data.table() %>% unique(by=c("hotrun","symbol"))
})
append_log("calculate colors and gene order")
do({
  mycolors <- unique(dt$hotrun) %>% `names<-`(rainbow(length(.)), .)
  append_log("geneorder")
  geneorder <- group_by(dt, symbol) %>% summarise(count=median(cpc)) %>% arrange(-count) %>% {.$symbol}
  append_log("rearrange levels")
  dt$symbol %<>% factor(levels=geneorder)
})
append_log("generate graph")
do({
  p <- ggplot(subset(dt, hotrun!=CURRENT_RUN), aes(symbol, cpc)) +
    geom_boxplot(outlier.shape=NA) +
    geom_jitter(aes(color=hotrun)) +
    geom_point(data=subset(dt, hotrun==CURRENT_RUN), fill="red", color="black", shape=21, size=4, alpha=.8) +
    labs(y="counts per cell (median of al ROIs)", color="hotrun") +
    theme_bw() +
    theme()
  ggsave(filename=paste0(Sys.Date(),"_",CURRENT_RUN,"_comparison_to_HeLa_runs.png"), plot=p, width=15, height=12)
})
append_log("====end====")
do(file.remove(PROGRESSFILE))