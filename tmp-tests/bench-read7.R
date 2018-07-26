csv <- "tmp-data/mtcars-long.csv"
csv2 <- "tmp-data/mtcars-wide.csv"

## System command 'cut' is super slow on my Windows.

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

tryCatch(data.table::fread(file = csv, nrows = 0, skip = 1),
         error = function(e) NULL)
dt <- data.table::fread(file = csv, select = c(5, 1, 3), verbose = TRUE)
names(dt)
names(mtcars)[c(5, 1, 3)]
dt2 <- `[.data.frame`(dt, names(mtcars)[c(5, 1, 3)])
dt2[1]
class(dt2)

library(data.table)
fwrite(iris, tmp <- tempfile())
debugonce(fread)
data.table::fread(file = tmp, select = c(5, 1, 3), skip = 0)
data.table::fread(file = tmp, select = c(5, 1, 3), skip = 1)

system.time(first_line <- fread(csv2, nrows = 1))
system.time(zero_line <- fread(csv2, nrows = 0))
system.time(first_line <- fread(csv2, nrows = 1, skip = 1))

# system.time(
#   df4 <- limma::read.columns(csv, names(mtcars)[1:4], sep = ",")
# )  # 32 sec
