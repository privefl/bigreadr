[![Travis build status](https://travis-ci.org/privefl/bigreadr.svg?branch=master)](https://travis-ci.org/privefl/bigreadr)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/privefl/bigreadr?branch=master&svg=true)](https://ci.appveyor.com/project/privefl/bigreadr)
[![Coverage status](https://codecov.io/gh/privefl/bigreadr/branch/master/graph/badge.svg)](https://codecov.io/github/privefl/bigreadr?branch=master)
[![CRAN status](https://www.r-pkg.org/badges/version/bigreadr)](https://cran.r-project.org/package=bigreadr)

# R package {bigreadr}

Read large text files based on splitting + `data.table::fread`


## Example

```{r}
# remotes::install_github("privefl/bigreadr")
library(bigreadr)

# Create a temporary file of ~141 MB (just as an example)
csv <- fwrite2(iris[rep(seq_len(nrow(iris)), 1e4), rep(1:5, 4)], tempfile())
format(file.size(csv), big.mark = ",")

## Splitting lines (1)
# Read (by parts) all data -> using `fread` would be faster
nlines(csv)  ## 1M5 lines -> split every 500,000
big_iris1 <- big_fread1(csv, every_nlines = 5e5)
# Read and subset (by parts)
big_iris1_setosa <- big_fread1(csv, every_nlines = 5e5, .transform = function(df) {
  dplyr::filter(df, Species == "setosa")
})

## Splitting columns (2)
big_iris2 <- big_fread2(csv, nb_parts = 3)
# Read and subset (by parts)
species_setosa <- (fread2(csv, select = 5)[[1]] == "setosa")
big_iris2_setosa <- big_fread2(csv, nb_parts = 3, .transform = function(df) {
  dplyr::filter(df, species_setosa)
})

## Verification
identical(big_iris1_setosa, dplyr::filter(big_iris1, Species == "setosa"))
identical(big_iris2, big_iris1)
identical(big_iris2_setosa, big_iris1_setosa)
```

## Use cases

Please send me your use cases!

- [Convert a CSV to SQLite by parts](https://privefl.github.io/bigreadr/articles/csv2sqlite.html)

- [Read a text file as a Filebacked Big Matrix](https://privefl.github.io/bigstatsr/reference/big_read.html)

- [Read a text file as a Filebacked Data Frame](https://privefl.github.io/bigdfr/reference/FDF_read.html)

- Read multiple files at once using `bigreadr::fread2()`.
