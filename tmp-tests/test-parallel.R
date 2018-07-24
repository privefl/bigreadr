library(bigreadr)

## Need to handle 'skip'
csv2 <- "tmp-data/mtcars-long.csv"
n <- nlines(csv2)
K <- 20
every_lines <- ceiling(n / 20)

Rcpp::sourceCpp('tmp-tests/test-setvbuf6.cpp')
tmp <- tempfile()
system.time(
  test <- test_setvbuf7(csv2, tmp, every_nlines = every_lines)
)
as.integer(test)
files <- paste0(tmp, 1:K, ".txt")
file.exists(files)

ncores <- bigstatsr::nb_cores()

if (ncores == 1) {
  registerDoSEQ()
} else {
  cluster_type <- getOption("bigstatsr.cluster.type")
  cl <- parallel::makeCluster(ncores, type = cluster_type)
  doParallel::registerDoParallel(cl)
  on.exit(parallel::stopCluster(cl), add = TRUE)
}

library(foreach)
system.time({
  res <- foreach(ic = 1:K) %dopar% {
    bigreadr:::fread2(files[ic], nThread = 1)
  }
})

system.time({
  res2 <- foreach(ic = 1:K) %do% {
    bigreadr:::fread2(files[ic], nThread = 8)
  }
}) # 0.9 / 1 (8) -> 2.4 (1)
## Either all or only 1


