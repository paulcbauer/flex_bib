repair_bib_file <- function(new_bib_file){
  bibfile <- readLines(new_bib_file, encoding = "UTF-8")
  accents <- c(
    "\\`",
    "\\'",
    "\\^",
    '\\"',
    "\\~",
    "\\=",
    "\\.",
    "\\u",
    "\\v",
    "\\H",
    "\\t",
    "\\c",
    "\\d",
    "\\b",
    "\\k"
  )
  accentletters <- expand.grid(accents, letters)
  accentletters <-
    sprintf('%s%s', accentletters[, 1], accentletters[, 2])
  accentletters <- gsub("\\\\", "", accentletters)
  
  # for(i in accentletters){bibfile <- gsub("\\{\\\\i\\}", "\\{\\\\i\\}\\}", bibfile)}
  bibfile <- gsub("\\{\\\\'e\\}", "\\{\\\\'e\\}\\}", bibfile)
  bibfile <- gsub("\\{\\\\'a\\}", "\\{\\\\'a\\}\\}", bibfile)
  bibfile <- gsub("\\{\\\\'o\\}", "\\{\\\\'o\\}\\}", bibfile)
  
  # Return output
  return(bibfile)
}