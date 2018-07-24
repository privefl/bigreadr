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
data.table::fwrite(iris[rep(seq_len(nrow(iris)), 1e5), ], csv,
                   quote = FALSE, row.names = FALSE)
format(file.size(csv), big.mark = ",")

# Read (by parts) all data -> using `fread` would be faster
big_iris <- big_fread(csv)
# Read and subset (by parts)
big_iris_setosa <- big_fread(csv, .transform = function(df) {
  dplyr::filter(df, Species == "setosa")
})
```

## Command 'split'

Splitting is the strategy used by this package to read large text files.
For splitting, system command 'split' is used. 
This command should be available by default on Unix-like systems.

For Windows users, you can [download CoreUtils](https://sourceforge.net/projects/gnuwin32/files/coreutils/5.3.0/coreutils-5.3.0.exe/download) (and install it) to get a similar command.
Then, you'll have to supply the path to this command as argument `split` in functions of this package.
For example, on my Windows computer, this command is installed there: `C:\\Program Files (x86)\\GnuWin32/bin/split.exe`.
