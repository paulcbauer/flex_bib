# FUNCTION ####
tidy_bib_file <- function(rmarkdownfile,
                          old_bib_file,
                          new_bib_file,
                          repair = FALSE,
                          replace_curly_braces = FALSE){
  
  library(stringr)
  library(bib2df)
  library(dplyr)
  
  # Read in rmd file as one long string
  text <- paste(readLines(rmarkdownfile),collapse=" ")
  
  # Extract citation keys
  citation_keys1 <- gsub("]$", "", unlist(regmatches(text, gregexpr("@[-A-Za-z0-9_]*\\]", text))))
  citation_keys2 <- gsub("\\s$", "", unlist(regmatches(text, gregexpr("@[-A-Za-z0-9_]*\\s", text))))
  citation_keys3 <- gsub("\\;$", "", unlist(regmatches(text, gregexpr("@[-A-Za-z0-9_]*;", text))))
  citation_keys4 <- gsub("\\,$", "", unlist(regmatches(text, gregexpr("@[-A-Za-z0-9_]*,", text))))
  
  # Merge citation keys and keep unique
  citation_keys <- gsub("@", "", unique(c(citation_keys1, citation_keys2, citation_keys3, citation_keys4)))
  citation_keys <- data.frame(BIBTEXKEY = as.character(citation_keys))
  
  cat("Finished extracting bibtexkeys.\n")
  
  
  # Read bib file #### 
  df <- bib2df(old_bib_file)
  cat("Imported old bib file.\n")
  
  bibliography_new <- inner_join(df, citation_keys, by = "BIBTEXKEY")
  
  # Clean title
  bibliography_new$TITLE <- str_replace_all(bibliography_new$TITLE,
                                            "\\}|\\{", "")
  bibliography_new$TITLE <- str_to_title(bibliography_new$TITLE)
  
  # Create new bib file ####
  df2bib(bibliography_new,  new_bib_file)
  
  
  cat("Created new bib file.\n")
  
  # Repair bib file ###
  if(isTRUE(repair)){
    bibfile <- readLines(new_bib_file, encoding = "UTF-8") 
    accents <- c("\\`", "\\'", "\\^", '\\"', "\\~", "\\=", 
                 "\\.", "\\u", "\\v", "\\H", "\\t", "\\c", "\\d", "\\b", "\\k")
    accentletters <- expand.grid(accents, letters)
    accentletters <- sprintf('%s%s', accentletters[,1], accentletters[,2])
    accentletters <- gsub("\\\\", "", accentletters)
    
    # for(i in accentletters){bibfile <- gsub("\\{\\\\i\\}", "\\{\\\\i\\}\\}", bibfile)}
    bibfile <- gsub("\\{\\\\'e\\}", "\\{\\\\'e\\}\\}", bibfile)
    bibfile <- gsub("\\{\\\\'a\\}", "\\{\\\\'a\\}\\}", bibfile)
    bibfile <- gsub("\\{\\\\'o\\}", "\\{\\\\'o\\}\\}", bibfile)
    
    writeLines(bibfile, new_bib_file)
    
    cat("Repaired new bib file.\n")
  }
  
  
  
  # Replace curly braces
  if(isTRUE(replace_curly_braces)){
    bibfile <- readLines(new_bib_file, encoding = "UTF-8") 
    bibfile <- str_replace_all(bibfile, "\\s\\{", ' "')
    bibfile[nchar(bibfile)>1] <- str_replace_all(bibfile[nchar(bibfile)>1], 
                                                 "\\}", '"')
    #bibfile <- bibfile[!bibfile==""]
    writeLines(bibfile, new_bib_file)
    
    cat("Also replaced curly braces.\n")
  }
}