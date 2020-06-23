# FUNCTION ####
tidy_bib_file_core <- function(text,
                               old_bib_file) {

  # Extract citation keys
  citation_keys1 <-
    gsub("]$", "", unlist(regmatches(
      text, gregexpr("@[-A-Za-z0-9_]*\\]", text)
    )))
  citation_keys2 <-
    gsub("\\s$", "", unlist(regmatches(
      text, gregexpr("@[-A-Za-z0-9_]*\\s", text)
    )))
  citation_keys3 <-
    gsub("\\;$", "", unlist(regmatches(
      text, gregexpr("@[-A-Za-z0-9_]*;", text)
    )))
  citation_keys4 <-
    gsub("\\,$", "", unlist(regmatches(
      text, gregexpr("@[-A-Za-z0-9_]*,", text)
    )))
  citation_keys5 <-
    gsub("\\.$", "", unlist(regmatches(
      text, gregexpr("@[-A-Za-z0-9_]*\\.", text)
    )))
  
  # Merge citation keys and keep unique
  citation_keys <-
    gsub("@", "", unique(
      c(
        citation_keys1,
        citation_keys2,
        citation_keys3,
        citation_keys4,
        citation_keys5
      )
    ))
  citation_keys <-
    data.frame(BIBTEXKEY = as.character(citation_keys))
  
  cat("Finished extracting bibtexkeys.\n")
  
  
  # Create new bib file ####
  bibliography_new <-
    inner_join(old_bib_file, citation_keys, by = "BIBTEXKEY")
  
  # Clean title
  bibliography_new$TITLE <- str_replace_all(bibliography_new$TITLE,
                                            "\\}|\\{", "")
  bibliography_new$TITLE <- str_to_title(bibliography_new$TITLE)
  
  # Return object
  return(bibliography_new)
}