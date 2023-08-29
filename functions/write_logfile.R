# devtools::document()

#' append to log file
#'
#' @param ... anything that should be written into the log file
#' @param Logfile path to the log file
#' @return nothing; appends the input to the log file with a time stamp. Will generate the log file if it does not already exist
#' @export
#' @examples
#' append_log("this is a test", 12345+2, "end of test")
#'
append_log <- function(..., Logfile="logfile_scriptSelector.txt"){
  try(
    write(paste(Sys.time(), ...), file=Logfile, append = TRUE),
    silent = TRUE
  )
}

#' try to do a function, append to log file if an error occurs
#'
#' @inheritParams append_log
#'
#' @param anything any statement to be tested
#' @return the result of the input if it ran successful, otherwise NULL while an error message is appended to the log file via the `append_log` function
#' @export
#' @examples
#' do(1 + 1)
#'
#' do("a" + 1) #should write this to the log file: 'Error in "a" + 1 : non-numeric argument to binary operator'
#'
do <- function(anything, Logfile="logfile_scriptSelector.txt"){
  out <- try(anything)
  if(class(out) %in% "try-error"){
    append_log(out[1], Logfile=Logfile)
    return(NULL)
  }
  return(out)
}
