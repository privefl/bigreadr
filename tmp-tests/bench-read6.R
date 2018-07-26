library(bigreadr)
csv2 <- "tmp-data/mtcars-long.csv"

system.time(
  test2 <- big_fread(csv2, 1e6)
)

library(bigstatsr)
system.time(n1 <- bigstatsr::nlines(csv2))
system.time(n2 <- bigreadr::nlines(csv2))

debugonce(big_read)
test <- big_read(csv2, header = TRUE, sep = ",",
                 nlines = n1, confirmed = FALSE,
                 nlines.block = 1e6, type = "double")



csv3 <- "tmp-data/mtcars-wide.csv"

system.time(
  test3 <- big_fread(csv3, 100, nThread = 12)
)
# 37 sec

system.time(
  test <- data.table::fread(csv3, verbose = TRUE, nThread = 1)
) # 3 sec

system.time(
  test <- data.table::fread(csv3, verbose = TRUE, nThread = 11)
) # 3 sec
