library(bigreadr)
library(bigstatsr)
library(foreach)

## Need to handle 'skip'
csv2 <- "tmp-data/mtcars-long.csv"
n <- nlines(csv2)
K <- 20
every_lines <- ceiling(n / 20)

Rcpp::sourceCpp('tmp-tests/test-setvbuf6.cpp')
tmp <- tempfile()
parts <- FBM(K, 1, init = 0, type = "integer")
system.time(
  test <- test_setvbuf7(csv2, tmp, every_nlines = every_lines, parts)
)
as.integer(test)
files <- paste0(tmp, 1:K, ".txt")
file.exists(files)

system.time({
  res2 <- foreach(ic = 1:K) %do% {
    while (parts[ic] == 0) Sys.sleep(TIME)
    bigreadr:::fread2(files[ic], nThread = 8)
  }
}) # 0.9 / 1 (8) -> 2.4 (1)
## Either all or only 1


