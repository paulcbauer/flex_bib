merge_bib_lines <- function(x){
  
  # ---- Load dependencies ----
  library(stringr)
  library(dplyr)
  
  # Function merges bib argument entries that span several lines
  # If line does not end with }, take the next line(s) and add it to this line
  lines_wo_end <- !str_detect(x, "\\}$|\\},$") & !str_detect(x, "@") & x!="" & !str_detect(x, "^%")
  # Get index
  lines_wo_end_index <- which(lines_wo_end)
  # Write index concecutive numbers into list
  indx <- split(lines_wo_end_index, cumsum(c(1, diff(lines_wo_end_index) != 1)))
  
  
  
  # Add index for next line to elements
  for(i in 1:length(indx)){indx[[i]] <- c(indx[[i]], last(indx[[i]])+1)}
  
  # Paste elements together according to index
  # https://stackoverflow.com/questions/32338758/r-paste-together-some-string-vector-elements-based-on-list-of-indexes
  x<-c(na.omit(Reduce(function(s,i) 
    replace(s,i,c(paste(s[i],collapse=" "),rep(NA,length(i)-1))),indx,x)))
  
  # Delete white space across all elements
  for(i in 1:length(x)){
    # split when =
    if(str_detect(x[i], "=")){
      splitted <- str_split(x[i], "=")
      splitted[[1]][2] <- str_squish(splitted[[1]][2])
      x[i] <- paste(splitted[[1]][1], splitted[[1]][2], sep="= ")
    }
    
  }
  x
}