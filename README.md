# tidy_bib

`tidy_bib` can be used to combine and tidy up (i.e., delete unused references from) a (set of) larger `.bib` file(s) based on the citations in an RMarkdown script. It creates either a single cleaned `.bib` file containing only those references cited in the `.Rmd` file or a set of cleaned `.bib` files, containing only those references cited in pre-defined sections of the RMarkdown document, which can then be embedded as section-specific bibliographies. 

Depending on how 'clean' the original `.bib file is`, the function may throw some errors. Normally, R will tell you in which line of your bib file the error is once you compile RMarkdown document.

## Contributors

**Paul C. Bauer**

- Mannheim Centre for European Social Research 
- University of Mannheim 
- [paulcbauer.eu](https://sites.google.com/view/paulcbauer)
- [\@p_c_bauer](https://twitter.com/p_c_bauer)


**Denis Cohen** 

- Mannheim Centre for European Social Research 
- University of Mannheim 
- [denis-cohen.github.io](https://denis-cohen.github.io)
- [\@denis_cohen](https://twitter.com/denis_cohen)

## Installation

The function `tidy_bib` is currently not part of a package. You can
simply download this repository and source the function `tidy_bib.R`
(which will in turn load all required dependencies).

## Dependencies

The use of `tidy_bib` requires the installation of the following R
packages:

  - [`bib2df`](https://cran.r-project.org/web/packages/bib2df/index.html). *Note:* Until [this issue](https://github.com/ropensci/bib2df/issues/37) is resolved, please make sure to install this issue-specific version of the `bib2df` packages via `remotes::install_github("ropensci/bib2df@issue_#29")`.
  - [`dplyr`](https://cran.r-project.org/web/packages/dplyr/index.html)
  - [`stringr`](https://cran.r-project.org/web/packages/stringr/index.html)

Additionally, `tidy_bib` uses the lua-filter
[`multiple-bibliographies`](https://github.com/pandoc/lua-filters/tree/master/multiple-bibliographies)
for the creation and inclusion of multiple bibliographies using
`pandoc-citeproc`.


## Using `tidy_bib`

For the use of `tidy_bib`, please see the
[vignette](https://github.com/paulcbauer/tidy_bib/blob/master/vignette.pdf).
