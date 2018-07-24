
library(bigreadr)
if (Sys.info()[["sysname"]] == "Windows") {
  options(bigreadr.split = "C:\\Program Files (x86)\\GnuWin32/bin/split.exe")
}


## LONG CSV
csv2 <- "tmp-data/mtcars-long.csv"
# csv <- readr::readr_example("mtcars.csv")
# df <- data.table::fread(csv, data.table = FALSE)
# data.table::fwrite(df[rep(seq_len(nrow(df)), 500000), ], csv2,
#                    quote = FALSE, row.names = FALSE)

nlines(csv2)
system.time(
  test <- split_file(csv2)
)
# Windows: 4.6 / 8.2 / 8.9
# Linux:   1.5 / 1.8 / 1.4


Rcpp::sourceCpp('tmp-tests/test-setvbuf5.cpp')
tmp <- tempfile()
system.time(
  test2 <- test_setvbuf6(csv2, tmp, 1e6)
)
# Windows: 15 / 4.8 / 5 / 4.4
# Linux: 5.4 / 3.3 / 3.6 / 3.5 / 2.8
as.integer(test2)
list.files(dirname(tmp), basename(tmp))



## LARGE CSV
csv3 <- "tmp-data/mtcars-wide.csv"
# data.table::fwrite(df[rep(seq_len(nrow(df)), 50), rep(seq_len(ncol(df)), 10000)],
#                    csv3, quote = FALSE, row.names = FALSE)

nlines(csv3)
system.time(
  test <- split_file(csv3)
)
# Windows: 4.3 / 3.9 / 9.6
# Linux:   3.2 / 1.4 / 3.7

Rcpp::sourceCpp('tmp-tests/test-setvbuf5.cpp')
tmp <- tempfile()
system.time(
  test2 <- test_setvbuf6(csv3, tmp, 100)
)
# Windows: 14. / 5.0 / 4.6
# Linux:   1.7 / 1.7 / 6.5
as.integer(test2)
list.files(dirname(tmp), basename(tmp))
