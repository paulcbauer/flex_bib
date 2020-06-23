# FUNCTION ####
tidy_bib <- function(rmarkdownfile,
                     old_bib_file,
                     new_bib_file,
                     by_sections = NULL,
                     repair = TRUE,
                     replace_curly_braces = FALSE,
                     removeISSN = TRUE,
                     removeISBN = TRUE,
                     removeDOI = TRUE,
                     removeURL = TRUE) {
  
  # ---- Load dependencies ----
  library(stringr)
  library(bib2df)
  library(dplyr)
  
  # ---- Source sub-functions ----
  source("tidy_bib_file_core.R")
  source("repair_bib_file.R")
  source("remove_curly_braces.R")
  
  # ---- Define fields to be removed ----
  to_remove <- c("ISSN", "ISBN", "DOI", "URL")
  to_remove <- to_remove[c(removeISSN,
                           removeISBN,
                           removeDOI,
                           removeURL)]
  
  # ---- Import, append multiple bib-files, remove non-essential columns ----
  complete_bib <- NULL
  if (length(old_bib_file) > 1) {
    for (file in old_bib_file) {
      partial_bib <- bib2df(file)
      complete_bib <- bind_rows(complete_bib, partial_bib) %>%
        dplyr::select(-contains("ABSTRACT"),
                      -contains("MENDELEY.TAGS"),
                      -contains("HYPOTHESIZED"))  %>%
        dplyr::select(-one_of(to_remove))
    }
  } else {
    complete_bib <- bib2df(old_bib_file) %>%
      dplyr::select(-contains("ABSTRACT"),
                    -contains("MENDELEY.TAGS"),
                    -contains("HYPOTHESIZED")) %>%
      dplyr::select(-one_of(to_remove))
  }
  cat("Imported old bib file(s).\n")
  
  # ---- Run core function ----
  # ---- by_sections == NULL: read in rmd file as one long string ----
  if (is.null(by_sections)) {
    rmd_text <- paste(readLines(rmarkdownfile), collapse = " ")
    
    # Run core function
    bibliography_new <- tidy_bib_file_core(rmd_text, complete_bib)
    
    # Write bib
    df2bib(bibliography_new,  new_bib_file)
    cat("New bib file created.\n")
    
    # Repair?
    if (isTRUE(repair)) {
      bibfile <- repair_bib_file(new_bib_file)
      writeLines(bibfile, new_bib_file)
      cat("Repaired new bib file.\n")
    }
    
    # Remove curly braces?
    if (isTRUE(replace_curly_braces)) {
      bibfile <- remove_curly_braces(new_bib_file)
      writeLines(bibfile, new_bib_file)
      cat("Also replaced curly braces.\n")
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
    rmd_text <- readLines(rmarkdownfile)
    
    # Define split points
    if (is.numeric(by_sections)) {
      rmarkdownfile <-
        split(rmd_text, cumsum(seq_along(rmd_text) %in% by_sections))
    } else if (is.character(by_sections)) {
      by_sections <-
        sapply(by_sections, function (x)
          which(rmd_text == x))
      
      # Re-validate by_section input
      if (any(sapply(by_sections, length) != 1)) {
        stop("by_sections input not found in rmarkdownfile")
      }
      
      # Split and concatenate
      rmd_text <- split(rmd_text, cumsum(seq_along(rmd_text) %in% by_sections))
      rmd_text <- lapply(rmd_text, paste, collapse = " ")
    }
    
    # Run core function across splits of the .Rmd
    new_bib_files <-
      lapply(rmd_text, tidy_bib_file_core, old_bib_file = complete_bib)
    
    # Write multiple bib files
    for (file in seq_along(new_bib_files)) {
      # Define file anme
      new_file_name <-
        paste0(gsub(".bib$", "", new_bib_file), "_", file, ".bib")
      
      # Write file
      df2bib(new_bib_files[[file]] %>%
               select(-one_of(to_remove)),
             new_file_name)
      cat(paste0(new_file_name, " created.\n"))
      
      # Repair?
      if (isTRUE(repair)) {
        bibfile <- repair_bib_file(new_file_name)
        writeLines(bibfile, new_file_name)
        cat(paste0(new_file_name, " repaired.\n"))
      }
      
      # Remove curly braces?
      if (isTRUE(replace_curly_braces)) {
        bibfile <- remove_curly_braces(new_file_name)
        writeLines(bibfile, new_file_name)
        cat(paste0("Curly braces removed from ", new_file_name, ".\n"))
      }
    }
  }
}
