[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build status](https://travis-ci.org/privefl/bigreadr.svg?branch=master)](https://travis-ci.org/privefl/bigreadr)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/privefl/bigreadr?branch=master&svg=true)](https://ci.appveyor.com/project/privefl/bigreadr)
[![Coverage status](https://codecov.io/gh/privefl/bigreadr/branch/master/graph/badge.svg)](https://codecov.io/github/privefl/bigreadr?branch=master)

# R package {bigreadr}

Read large text files based on splitting + `data.table::fread`


## Example

```{r}
# devtools::install_github("privefl/bigreadr")
library(bigreadr)

# Create a temporary file of ~360 MB (just as an example)
csv <- tempfile()
fwrite2(iris[rep(seq_len(nrow(iris)), 1e5), ], csv)
format(file.size(csv), big.mark = ",")

# Read (by parts) all data -> using `fread` would be faster
nlines(csv)  ## 15M lines -> split every 1M
big_iris <- big_fread(csv, every_nlines = 1e6)
# Read and subset (by parts)
big_iris_setosa <- big_fread(csv, every_nlines = 1e6, .transform = function(df) {
  dplyr::filter(df, Species == "setosa")
})
```
