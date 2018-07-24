
## LONG CSV
csv2 <- "tmp-data/mtcars-long.csv"

Rcpp::sourceCpp('tmp-tests/test-setvbuf2.cpp')

# system.time(test <- test_setvbuf(csv2, 10))
system.time(test <- test_setvbuf2(csv2))
system.time(test2 <- fpeek::peek_count_lines(csv2))


Rcpp::sourceCpp('tmp-tests/test-setvbuf2.cpp')

csv2.2 <- sub("\\.csv$", "2.csv", csv2)
system.time(test <- test_setvbuf3(csv2, csv2.2)) # 5
system.time(test2 <- test_setvbuf4(csv2, csv2.2)) # 5


system.time(data.table::fread(csv2))
system.time(data.table::fread(csv2.2))
# df1 <- data.table::fread(csv2)
# df2 <- data.table::fread(csv2.2)
# identical(df1, df2)

system.time(file.copy(csv2, sub("\\.csv$", "3.csv", csv2))) # 4
