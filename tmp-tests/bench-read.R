library(readr)

csv <- readr_example("mtcars.csv")
df <- data.table::fread(csv, data.table = FALSE)

## LONG CSV
csv2 <- "tmp-data/mtcars-long.csv"
# data.table::fwrite(df[rep(seq_len(nrow(df)), 500000), ], csv2,
#                    quote = FALSE, row.names = FALSE)

system.time(
  df2 <- data.table::fread(csv2)
) # 3.5

system.time(
  df3 <- readr::read_csv(csv2)
) # 25
rm(df2, df3); gc(reset = TRUE)


system.time(nlines <- fpeek::peek_count_lines(csv2)) # 1.8
system.time(nlines2 <- nrow(data.table::fread(csv2, select = 1))) # 2.8

tmp <- tempfile()
if (Sys.info()[["sysname"]] == "Windows") {

  # https://sourceforge.net/projects/gnuwin32/
  awk <- shortPathName("C:/Program Files (x86)/GnuWin32/bin/awk.exe") # Windows
  cmd <- sprintf("%s \"NR%%%d==1{x=\"\"\"%s\"\"\"++i;}{print > x}\" %s",
                 awk, 20, gsub("\\\\", "\\\\\\\\", tmp), normalizePath(csv))

} else {

  cmd <- sprintf("awk 'NR%%%d==1{x=\"%s\"++i;}{print > x}' %s",
                 tmp, 20, normalizePath(csv))

}
system(cmd)
readLines(paste0(tmp, 1), 1)

cmd <- sprintf("%s \"NR%%%d==1{x=\"\"\"%s\"\"\"++i;}{print > x}\" %s",
               awk, 20000, gsub("\\\\", "\\\\\\\\", tmp), normalizePath(csv2))
system.time(system(cmd)) # 1.4
# readLines(paste0(tmp, 1))


## LARGE CSV
csv3 <- "tmp-data/mtcars-wide.csv"
data.table::fwrite(df[rep(seq_len(nrow(df)), 50), rep(seq_len(ncol(df)), 10000)], csv3,
                   quote = FALSE, row.names = FALSE)

system.time(
  df2 <- data.table::fread(csv3, data.table = FALSE)
) # 0.06 -> 0.65 -> 9.8
system.time(
  nlines <- nrow(data.table::fread(csv3, select = 1))
) # 0.1 -> 0.45 -> 4.5
system.time(nlines2 <- fpeek::peek_count_lines(csv3))

# system.time(
#   df3 <- readr::read_csv(csv3)
# ) # 6

cmd <- sprintf("%s \"NR%%%d==1{x=\"\"\"%s\"\"\"++i;}{print > x}\" %s",
               awk, 2, gsub("\\\\", "\\\\\\\\", tmp), normalizePath(csv3))
system.time(system(cmd)) # 1.4
# readLines(paste0(tmp, 1))

