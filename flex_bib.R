# FUNCTION ####
flex_bib <- function(rmarkdown_file,
                     bib_input,
                     bib_output,
                     by_sections = NULL,
                     repair = TRUE,
                     removeISSN = TRUE,
                     removeISBN = TRUE,
                     removeDOI = TRUE,
                     removeURL = TRUE) {
  
  # ---- Load dependencies ----
  library(stringr)
  library(bib2df)
  library(dplyr)
  
  # ---- Sub-functions ----
  flex_bib_file_core <- function(text,
                                 bib_input) {
    
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
      inner_join(bib_input, citation_keys, by = "BIBTEXKEY")
    
    # Clean title
    bibliography_new$TITLE <- str_replace_all(bibliography_new$TITLE,
                                              "\\}|\\{", "")
    bibliography_new$TITLE <- str_to_title(bibliography_new$TITLE)
    
    # Return object
    return(bibliography_new)
  }
  
  repair_bib_file <- function(bib_output){
    bibfile <- readLines(bib_output, encoding = "UTF-8")
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
    
    # Replace faulty urls
    #bibfile <- gsub("url\\{", "", bibfile)
    
    
    
    # Return output
    return(bibfile)
  }
  
  # ---- Define fields to be removed ----
  to_remove <- c("ISSN", "ISBN", "DOI", "URL", "FILE")
  to_remove <- to_remove[c(removeISSN,
                           removeISBN,
                           removeDOI,
                           removeURL)]
  
  # ---- Import, append multiple bib-files, remove non-essential columns ----
  complete_bib <- NULL
  if (length(bib_input) > 1) {
    for (file in bib_input) {
      partial_bib <- bib2df(file) %>%
        mutate(YEAR = as.character(YEAR))
      complete_bib <- bind_rows(complete_bib, partial_bib) %>%
        dplyr::select(-contains("ABSTRACT"),
                      -contains("MENDELEY.TAGS"),
                      -contains("HYPOTHESIZED"),
                      -contains("FILE"),
                      -contains("KEYWORDS"),
                      -contains("LANGUAGE"),
                      -contains("ORIGINAL_ID"),
                      -contains("X."))  %>%
        dplyr::select(-one_of(to_remove))
    }
  } else {
    complete_bib <- bib2df(bib_input) %>%
      dplyr::select(-contains("ABSTRACT"),
                    -contains("MENDELEY.TAGS"),
                    -contains("HYPOTHESIZED"),
                    -contains("FILE"),
                    -contains("KEYWORDS"),
                    -contains("LANGUAGE"),
                    -contains("ORIGINAL_ID"),
                    -contains("X.")) %>%
      dplyr::select(-one_of(to_remove))
  }
  cat("Imported old bib file(s).\n")
  
  # ---- Run core function ----
  # ---- by_sections == NULL: read in rmd file as one long string ----
  if (is.null(by_sections)) {
    rmd_text <- paste(readLines(rmarkdown_file), collapse = " ")
    
    # Run core function
    bibliography_new <- flex_bib_file_core(rmd_text, complete_bib)
    
    # Write bib
    df2bib(bibliography_new,  bib_output)
    cat("New bib file created.\n")
    
    # Repair?
    if (isTRUE(repair)) {
      bibfile <- repair_bib_file(bib_output)
      stringi::stri_write_lines(bibfile, bib_output)
      cat("Repaired new bib file.\n")
    }

    
  # ---- by_sections != NULL: split by sections ----
  } else {
    
    # Validate by_section input
    if (!(is.vector(by_sections) &
          (is.character(by_sections) | is.numeric(by_sections)))) {
      stop(
        paste0(
          "by_sections must be a character vector of section titles ",
          "(with the correct number of #'s) or a numeric vector of ",
          "lines in the Rmd file on which new reference sections start."
        )
      )
    }
    
    # Read in rmd file as vector of lines
    rmd_text <- readLines(rmarkdown_file)
    
    # Define split points
    if (is.numeric(by_sections)) {
      rmarkdown_file <-
        split(rmd_text, cumsum(seq_along(rmd_text) %in% by_sections))
    } else if (is.character(by_sections)) {
      by_sections <-
        sapply(by_sections, function (x)
          which(rmd_text == x))
      
      # Re-validate by_section input
      if (any(sapply(by_sections, length) != 1)) {
        stop("by_sections input not found in rmarkdown_file")
      }
      
      # Split and concatenate
      rmd_text <- split(rmd_text, cumsum(seq_along(rmd_text) %in% by_sections))
      rmd_text <- lapply(rmd_text, paste, collapse = " ")
    }
    
    # Run core function across splits of the .Rmd
    bib_outputs <-
      lapply(rmd_text, flex_bib_file_core, bib_input = complete_bib)
    
    # Write multiple bib files
    for (file in seq_along(bib_outputs)) {
      # Define file anme
      new_file_name <-
        paste0(gsub(".bib$", "", bib_output), "_", file, ".bib")
      
      # Write file
      df2bib(bib_outputs[[file]] %>%
               select(-one_of(to_remove)),
             new_file_name)
      cat(paste0(new_file_name, " created.\n"))
      
      # Repair?
      if (isTRUE(repair)) {
        bibfile <- repair_bib_file(new_file_name)
        stringi::stri_write_lines(bibfile, new_file_name)
        cat(paste0(new_file_name, " repaired.\n"))
      }
    }
  }
}
