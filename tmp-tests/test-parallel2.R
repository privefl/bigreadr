library(bigreadr)
library(bigstatsr)
library(foreach)

## Need to handle 'skip'
csv2 <- "tmp-data/mtcars-long.csv"
n <- nlines(csv2)
K <- 20
every_lines <- ceiling(n / 20)

parallel <- TRUE
if (!parallel) {
  registerDoSEQ()
} else {
  cl <- parallel::makeCluster(2)
  doParallel::registerDoParallel(cl)
  # on.exit(parallel::stopCluster(cl), add = TRUE)
}

TIME <- 1 / (10 * K)
parts <- FBM(K, 1, init = 0, type = "integer")
tmp <- tempfile()
files <- paste0(tmp, 1:K, ".txt")
system.time({
  res <- foreach(job = 1:2) %dopar% {

    if (job == 1) {
      print(1)
      system.time(
        test <- bigreadr:::test_setvbuf7(csv2, tmp, every_nlines = every_lines, parts)
      )
      # NULL
    } else {
      print(2)
      system.time({
        lapply(seq_along(files), function(k) {
          while (parts[k] == 0) Sys.sleep(TIME)
          bigreadr:::fread2(files[k])
        })
      })
    }
  }
})
parallel::stopCluster(cl)
res
# res <- do.call(bigreadr::my_rbind, res[[2]])


#### PROBLEM: fread reading (second job) is slowing down first job ####


system.time({
  lapply(seq_along(files), function(k) {
    while (parts[k] == 0) Sys.sleep(TIME)
    bigreadr:::fread2(files[k], nThread = 8)
  })
})
