# devtools::document()

#' change ROI names
#'
#' @param input vector of strings
#' @export
#' @examples
#' library(resolveReport)
#'
resolve_changeNames <- function(input, altnames=""){
  replacement <- gsub("W0A","A1-",input)
  replacement <- gsub("W1A","B1-",replacement)
  replacement <- gsub("W2A","C1-",replacement)
  replacement <- gsub("W3A","D1-",replacement)
  replacement <- gsub("W4A","A2-",replacement)
  replacement <- gsub("W5A","B2-",replacement)
  replacement <- gsub("W6A","C2-",replacement)
  replacement <- gsub("W7A","D2-",replacement)

  if(length(altnames)>0){
    if(!altnames %in% ""){
      altnames <- unlist(strsplit(altnames,","))
      if(length(altnames)>0) for(i in seq(altnames)) replacement <- gsub(paste0("^A",i,"$"), paste0(altnames[i],"Z"), replacement)
      if(length(altnames)>0) for(i in seq(altnames)) replacement <- gsub("Z$", "", replacement)
    }
  }
  return(replacement)
}

