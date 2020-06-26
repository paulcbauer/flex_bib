
<!-- README.md is generated from README.Rmd. Please edit that file -->

# flex\_bib

The package/function is being developed by [Paul C.
Bauer](http://paulcbauer.eu/) and [Denis
Cohen](https://denis-cohen.github.io/) .

It deals with two problems:

1.  We normally use (one or several) large .bib files as input for our
    paper .rmd files. These are based on one or several authors’
    literature databases. However, we ideally want to end up with one
    single (max. two) .bib file(s) that includes only those references
    that were cited in our paper, e.g., if we prepare reproduction
    files.
2.  Papers normally have at least two sections namely a main section and
    an appendix that also have independent bibliographies. Ideally, in
    compiling our RMarkdown paper we want two independent bibliographies
    that correspond to those sections and are located at their end.

`flex_bib` can solve those problems automatically for us namely to tidy
up (delete unused references from) a larger bib file based on the
citations in a .rmd file. It creates a new cleaned bib file(s).
`flex_bib` can also rely on several bib files as input and merge them.

## Installation

The function `flex_bib_file` is currently not part of a package. So
simply run the code below to source the function from github. You will
need the `df2bib` package.

``` r
library(devtools)
source_url("https://raw.githubusercontent.com/paulcbauer/flex_bib/master/flex_bib.R")
```

The use of `flex_bib` requires the installation of the following R
packages:

  - [`bib2df`](https://cran.r-project.org/web/packages/bib2df/index.html).
    *Note:* Until [this
    issue](https://github.com/ropensci/bib2df/issues/37) is resolved,
    please make sure to install this issue-specific version of the
    `bib2df` package via
    `remotes::install_github("ropensci/bib2df@issue_#29")`.
  - [`dplyr`](https://cran.r-project.org/web/packages/dplyr/index.html)
  - [`stringr`](https://cran.r-project.org/web/packages/stringr/index.html)

Additionally, `flex_bib` uses the lua-filter
[`multiple-bibliographies`](https://github.com/pandoc/lua-filters/tree/master/multiple-bibliographies)
for the creation and inclusion of multiple bibliographies using
`pandoc-citeproc`.

  - Download the file `multiple-bibliographies.lua` and store it as
    `multiple-bibliographies.lua` (not as .txt file) in the same folder
    as your Rmarkdown file.

## How to

Information on how to use the function can be found in the vignette:

  - PDF:
    <https://github.com/paulcbauer/flex_bib/blob/master/vignette.pdf>
    ([Download
    link](https://github.com/paulcbauer/flex_bib/raw/master/vignette.pdf))
  - HTML:
    [Link](https://htmlpreview.github.io/?https://github.com/paulcbauer/flex_bib/blob/master/vignette_html.html)

## Contributors

**Paul C. Bauer**

  - Mannheim Centre for European Social Research
  - University of Mannheim
  - [paulcbauer.eu](https://sites.google.com/view/paulcbauer)
  - [@p\_c\_bauer](https://twitter.com/p_c_bauer)

**Denis Cohen**

  - Mannheim Centre for European Social Research
  - University of Mannheim
  - [denis-cohen.github.io](https://denis-cohen.github.io)
  - [@denis\_cohen](https://twitter.com/denis_cohen)
