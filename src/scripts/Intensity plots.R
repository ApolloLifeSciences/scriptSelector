print("script started")

SCRIPT="intensity_plots"
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
  target_folder <- cmd_args[1]
  custom_text <- cmd_args[2]
  setwd(target_folder)
})
append_log("====start=====")
PROGRESSFILE <- "r_Un_n_In_g.txt"
do(write.table(data.frame(), PROGRESSFILE))
append_log("load libraries")
append_log(custom_text)
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
      labs(y="signal intensity") +
      theme_bw() +
      theme(panel.border = element_rect(color=channelx))
  }
})
append_log("load files and calculate")
do({
  if(custom_text!="") genes <- strsplit(custom_text, split=",")[[1]]
  int_files <- list.files(recursive=T, pattern="signal_intensities.txt") %>% `names<-`(gsub("_.*","",.))
  ints <- lapply(names(int_files), function(x) {
    out <- read.table(int_files[[x]], sep="\t", header=T) %>% as.data.table() %>% 
      mutate(run=x, channel=ifelse(channel==1,"red","yellow"))
    if(custom_text!="") out <- subset(out, id %in% genes)
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
do(file.remove(PROGRESSFILE))