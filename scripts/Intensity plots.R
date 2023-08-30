#script explanation: 
"
generate plots with intensities for each gene in each round
TARGET FOLDER: contains a signal_intensities.txt file
CUSTOM TEXT: gene names separated by comma. If not specified, all genes are used
"
#=======================================================
#=======================================================
#=======================================================
SCRIPT <- "intensityPlots"
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
append_log(paste("====",SCRIPT,"====="))
#=======================================================
#=======================================================
#=======================================================
append_log("load packages")
append_log(CUSTOM_TEXT)
do({
  library(dplyr)
  library(magrittr)
  library(ggplot2)
  library(data.table)
  library(ggbeeswarm)
})
append_log("define functions")
do({
  getplot <- function(dt, channelx, maxy=NA, cex=.35){
    dt <- subset(dt, abs(signal)!=Inf)
    ggplot(subset(dt, channel==channelx), aes(factor(imaging_round), signal, color=ROI, group=ROI)) +
      facet_wrap(~id) +
      stat_summary(fun = median , geom="line") +
      geom_beeswarm(cex = cex) +
      scale_color_manual(values=c(W0A1="blue",W0A2="deepskyblue",W1A1="darkgreen",W1A2="green",W2A1="darkorange2",W2A2="orange",
                                  W3A1="darkred",W3A2="red",W4A1="deeppink3",W4A2="deeppink",W5A1="darkorchid3",W5A2="darkorchid1",
                                  W6A1="cornsilk4",W6A2="cornsilk2",W7A1="gold",W7A2="yellow")) +
      scale_y_continuous(limits=c(0,maxy), expand=c(0,0)) +
      labs(y="signal intensity", x="imaging round") +
      theme_bw() +
      theme(panel.border = element_rect(color=channelx))
  }
})
append_log("load files and calculate")
do({
  if(CUSTOM_TEXT!="") genes <- strsplit(CUSTOM_TEXT, split=",")[[1]]
  int_files <- list.files(recursive=T, pattern="signal_intensities.txt") %>% `names<-`(gsub("_.*","",.))
  ints <- lapply(names(int_files), function(x) {
    out <- read.table(int_files[[x]], sep="\t", header=T) %>% as.data.table() %>% 
      mutate(run=x, channel=ifelse(channel==1,"red","yellow"))
    if(CUSTOM_TEXT!="") out <- subset(out, id %in% genes)
    return(out)
  }) %>% `names<-`(names(int_files))
  percs <- ints %>% lapply(function(x){
    xlist <- split(x, x$background)
    xmerge <- merge(xlist[[1]], xlist[[2]], by=c("id","tile","imaging_round","ROI","run")) %>% mutate(signal=signal.y/signal.x*100, channel=channel.y)
    return(xmerge)
  })
  
  maxint <- max(do.call(rbind,ints)$signal, na.rm=T)
  maxintbg <- do.call(rbind, ints) %>% subset(background) %>% {max(.$signal, na.rm=T)}
  maxrel <- 50# max(do.call(rbind, percs)$signal, na.rm=T)
})
append_log("generate graphs")
lapply(names(ints), function(x){
  do({
    append_log("   ", x)
    mydt <- ints[[x]] %>% subset(!background)
    plotR <- getplot(dt=mydt, channelx="red", maxy=maxint)
    plotY <- getplot(dt=mydt, channelx="yellow", maxy=maxint)
    ggsave(paste0(x,"_RED_intended.png"), plotR, width=20, height=12)
    ggsave(paste0(x,"_YELLOW_intended.png"), plotY, width=20, height=12)
    
    mydt <- ints[[x]] %>% subset(background)
    plotR <- getplot(dt=mydt, channelx="red", maxy=maxintbg)
    plotY <- getplot(dt=mydt, channelx="yellow", maxy=maxintbg)
    ggsave(paste0(x,"_RED_unintended.png"), plotR, width=20, height=12)
    ggsave(paste0(x,"_YELLOW_unintended.png"), plotY, width=20, height=12)
    
    mydt <- percs[[x]]
    plotR <- getplot(dt=mydt, channelx="red", maxy=maxrel, cex=.1)
    plotY <- getplot(dt=mydt, channelx="yellow", maxy=maxrel, cex=.1)
    ggsave(paste0(x,"_RED_relBackground.png"), plotR, width=20, height=12)
    ggsave(paste0(x,"_YELLOW_relBackground.png"), plotY, width=20, height=12)
  })
})
append_log("====end====")
do(unlink(PROGRESSFILE))