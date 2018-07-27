library(bigreadr)

long <- FALSE
if (long) {
  csv2 <- "tmp-data/mtcars-long.csv"
  block <- 1e6
  M <- 11
  block2 <- 3
} else {
  csv2 <- "tmp-data/mtcars-wide.csv"
  block <- 1e3
  M <- 11e3
  block2 <- 3
}


library(bigstatsr)
(n1 <- bigreadr::nlines(csv2))

# debugonce(big_read)
# tmp <- gc(reset = TRUE)
# system.time(
#   test <- big_read(csv2, header = TRUE, sep = ",",
#                    nlines = n1, confirmed = TRUE,
#                    nlines.block = block, type = "double")
# ) # 38 sec  //  912 sec
# gc() - tmp

tmp <- gc(reset = TRUE)
system.time({
  X <- FBM(n1 - 1, M)
  offset <- 0
  test2 <- big_fread1(csv2, block, .transform = function(df) {
    ind <- rows_along(df)
    X[offset + ind, ] <- as.matrix(df)
    offset <<- offset + length(ind)
    NULL
  }, .combine = c)
}) # 16 sec  //  122 sec
gc() - tmp

# all.equal(dim(test$FBM), dim(X))
# all.equal(test$FBM[, 1], X[, 1])
# all.equal(test$FBM[, 11], X[, 11])

tmp <- gc(reset = TRUE)
system.time({
  X2 <- FBM(n1 - 1, M)
  offset <- 0
  test3 <- big_fread2(csv2, block2, .transform = function(df) {
    print(offset)
    ind <- cols_along(df)
    X2[, offset + ind] <- as.matrix(df)
    offset <<- offset + length(ind)
    NULL
  }, .combine = c)
}) # 16 sec  //  122 sec
gc() - tmp

all.equal(dim(X2),  dim(X))
all.equal(X2[, 1],  X[, 1])
all.equal(X2[, 11], X[, 11])
all.equal(X2[, M],  X[, M])

