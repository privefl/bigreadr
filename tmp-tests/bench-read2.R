# https://sourceforge.net/projects/gnuwin32/files/coreutils/5.3.0/coreutils-5.3.0.exe/download

csv <- readr::readr_example("mtcars.csv")
split <- shortPathName("C:\\Program Files (x86)\\GnuWin32/bin/split.exe")

system(sprintf("%s --version", split)) == 0
system(sprintf("%s -l 5 %s", split, csv))

## LONG CSV
df <- data.table::fread(csv, data.table = FALSE)
csv2 <- tempfile(fileext = ".csv")
data.table::fwrite(df[rep(seq_len(nrow(df)), 500000), ], csv2,
                   quote = FALSE, row.names = FALSE)
file.size(csv2)

system.time(system(sprintf("find /c /v \"aabbccdd\" %s", csv2)))

tmp <- tempfile()
system.time(data.table::fread(csv2, nThread = 1))  ## 2.2
system.time(data.table::fread(csv2, nThread = 2))  ## 1.5
system.time(data.table::fread(csv2, nThread = 4))  ## 1
system.time(data.table::fread(csv2, nThread = 7))  ## 0.7
system.time(system(sprintf("%s -l 200000 %s %s", split, csv2, tmp))) ## 12 sec
system.time(fpeek::peek_count_lines(csv2))                           ## 3 sec

files <- list.files(dirname(tmp), basename(tmp), full.names = TRUE)
df1 <- data.table::fread(files[1], data.table = FALSE)
data.table::fread(tail(files, 1), col.names = names(df1), data.table = FALSE)

scan(csv, "", sep = ",", nlines = 1, skip = 0)


df <- mtcars
df2 <- unname(mtcars)

sapply(df, data.table::address)
sapply(df2, data.table::address)


microbenchmark::microbenchmark(
  as.matrix(unname(mtcars), rownames.force = FALSE),
  as.matrix(mtcars)
)
