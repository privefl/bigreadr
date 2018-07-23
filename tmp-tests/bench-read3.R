
## LONG CSV
csv2 <- "tmp-data/mtcars-long.csv"
# data.table::fwrite(df[rep(seq_len(nrow(df)), 500000), ], csv2,
#                    quote = FALSE, row.names = FALSE)

library(bigreadr)
system.time(
  test <- split_file(csv2)
)

rm(test2); gc(reset = TRUE)
system.time(
  test2 <- big_fread(csv2, every_x_mb = 1000)
)
gc() # + 2 GB

rm(test2); gc(reset = TRUE)
system.time(
  test2 <- data.table::fread(csv2)
)
gc() # + 1 GB

# system.time(test <- split_file(csv2, every_x_mb = 1000))
# system.time(test <- split_file(csv2, every_x_mb = 10))
system.time(tmp <- lapply(test, function(f) data.table::fread(f, data.table = FALSE)))

system.time(tmp2 <- do.call(my_rbind, tmp))

system.time(
  test2 <- big_fread(csv2, every_x_mb = 100)
)
system.time(
  test3 <- data.table::fread(csv2)
)


tmp <- tempfile()
system.time(
  status <- system(sprintf("%s -C %dm %s %s", "split", 100, csv2, tmp))
)
file_parts <- list.files(dirname(tmp), basename(tmp), full.names = TRUE)

dt1 <- data.table::fread(file_parts[1])

system.time(df2 <- data.table::fread(csv2, data.table = FALSE))
system.time(df3 <- bigreadr::big_fread(
  csv2, .transform = identity
))
