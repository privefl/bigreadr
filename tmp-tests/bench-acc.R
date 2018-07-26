
library(data.table)
iris_dt <- as.data.table(iris)
microbenchmark::microbenchmark(
  iris[, 1:3],
  iris[1:3],
  iris_dt[, 1:3],
  iris[, 3, drop = FALSE],
  iris[3],
  iris_dt[, 3, drop = FALSE]
)

