#script explanation: (important to keep this in lines 3-5!)
"
extracts the postion of all ROIs on the slide as coordinates
TARGET FOLDER: the imagingConfig folder of a hotrun
CUSTOM TEXT: no effect
"
#=======================================================
#=======================================================
#=======================================================
SCRIPT <- "get coordinates" #short, name of your script of your script (will be used in the logfile)
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
#expnow xml file (contains coordinates)
TILESIZE <- 295.872
expNow_path <- list.files(TARGET_FOLDER, pattern="ExpNow.xml")
expnow <- XML::xmlToList(XML::xmlParse(expNow_path))$ExperimentBlocks$AcquisitionBlock$SubDimensionSetups$RegionsSetup$SampleHolder$SingleTileRegionArrays
expnow[sapply(expnow, is.null)] <- NULL

#create a df that contains the names, coordinates and widths for all ROIs
rois <- lapply(expnow, function(roi){
  tiles <- roi$SingleTileRegions
  tilesX <- sort(as.numeric(as.character(unique(unlist( lapply(tiles, function(tile) tile$X) )))))
  tilesY <- sort(as.numeric(as.character(unique(unlist( lapply(tiles, function(tile) tile$Y) )))))
  outdf <- data.frame(roi=resolve_changeNames(roi$.attrs[["Name"]]),
                      xmin=tilesX[1],
                      xmax=tail(tilesX,1)+TILESIZE,
                      ymin=tilesY[1],#+0.3*TILESIZE, #the 0.3 and 1.3 correction is necessary to push the ROI down to its correct position
                      ymax=tail(tilesY,1)+TILESIZE)#+1.3*TILESIZE
  return(outdf)
})
rois <- transform(do.call(rbind, rois), row.names=NULL)
write.table(rois, paste0(JAR_FOLDER,"/ROI_coordinates.txt"), quote=F, sep="\t", row.names=F)

#=======================================================
#=======================================================
#=======================================================
# unlink(PROGRESSFILE) #signals to java that the process is done (progress bar is then filled)


