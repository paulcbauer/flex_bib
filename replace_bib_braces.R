replace_bib_braces <- function(x){
  
  # ---- Load dependencies ----
  library(stringr)
  library(dplyr)

  
  
  # Function replaces braces for bad bibtex entries
  
  x <- gsub("= \"", "= \\{", x)
  x <- gsub('\",', "\\},", x)
  
  problematic_lines <- !str_detect(x, "\\{|\\}")
  
  # Add } after = 
  x[problematic_lines] <- gsub("=  ", "= \\{", x[problematic_lines])
  problematic_lines2 <- str_detect(x[problematic_lines], "= \\{")
  x[problematic_lines][problematic_lines2] <- gsub(",$", "\\},", x[problematic_lines][problematic_lines2])
  
  # Add } before string end
  problematic_lines3 <- str_detect(x[problematic_lines], "= \\{") & !str_detect(x[problematic_lines], "\\}")
  x[problematic_lines][problematic_lines3] <- paste(x[problematic_lines][problematic_lines3], "}", sep="")
  
  x <- gsub("\"", "\\}", x)
  x
  
}  