remove_curly_braces <- function(new_bib_file){
  bibfile <- readLines(new_bib_file, encoding = "UTF-8")
  bibfile <- str_replace_all(bibfile, "\\s\\{", ' "')
  bibfile[nchar(bibfile) > 1] <-
    str_replace_all(bibfile[nchar(bibfile) > 1],
                    "\\}", '"')
  #bibfile <- bibfile[!bibfile==""]
  
  # Return output
  return(bibfile)
}