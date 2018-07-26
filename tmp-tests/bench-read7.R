csv <- "tmp-data/mtcars-long.csv"
csv2 <- "tmp-data/mtcars-wide.csv"

tmp <- gc(reset = TRUE)
system.time(
  test2 <- data.table::fread(sprintf("cut -f1-5 -s -d',' %s", csv))
)
gc() - tmp

tmp <- gc(reset = TRUE)
system.time(
  test2 <- data.table::fread(sprintf("cut -f1-50000 -s -d',' %s", csv2))
)
gc() - tmp


tmp <- gc(reset = TRUE)
system.time(
  test2 <- data.table::fread(csv, select = 1:5)
)
gc() - tmp

tmp <- gc(reset = TRUE)
system.time(
  test2 <- data.table::fread(csv2, select = 1:50000)
)
gc() - tmp


tmp <- gc(reset = TRUE)
system.time(
  test2 <- data.table::fread(csv2, select = 1:10000)
)
gc() - tmp



# system.time(
#   df4 <- limma::read.columns(csv, names(mtcars)[1:4], sep = ",")
# )  # 32 sec
