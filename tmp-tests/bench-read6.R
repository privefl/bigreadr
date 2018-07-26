library(bigreadr)

long <- FALSE
if (long) {
  csv2 <- "tmp-data/mtcars-long.csv"
  block <- 100e4
  M <- 11
  block2 <- 3
} else {
  csv2 <- "tmp-data/mtcars-wide.csv"
  block <- 100
  M <- 11e4
  block2 <- 3
}


library(bigstatsr)
system.time(n1 <- bigstatsr::nlines(csv2))
system.time(n2 <- bigreadr::nlines(csv2))

# debugonce(big_read)
tmp <- gc(reset = TRUE)
system.time(
  test <- big_read(csv2, header = TRUE, sep = ",",
                   nlines = n1, confirmed = TRUE,
                   nlines.block = block, type = "double")
) # 38 sec  //  912 sec
gc() - tmp

tmp <- gc(reset = TRUE)
system.time({
  X <- FBM(n1 - 1, M)
  offset <- 0
  test2 <- big_fread1(csv2, block, .transform = function(df) {
    ind <- rows_along(df)
    X[offset + ind, ] <- do.call(cbind, df)
    offset <<- offset + length(ind)
    NULL
  }, .combine = 'c')
}) # 16 sec  //  122 sec
gc() - tmp

all.equal(dim(test$FBM), dim(X))
all.equal(test$FBM[, 1], X[, 1])
all.equal(test$FBM[, 11], X[, 11])

tmp <- gc(reset = TRUE)
system.time({
  X2 <- FBM(n1 - 1, M)
  offset <- 0
  test3 <- big_fread2(csv2, block2, .transform = function(df) {
    print(offset)
    ind <- cols_along(df)
    X[, offset + ind] <- do.call(cbind, df)
    offset <<- offset + length(ind)
    NULL
  }, .combine = 'c')
}) # 16 sec  //  122 sec
gc() - tmp

