
## LONG CSV
csv2 <- "tmp-data/mtcars-long.csv"

Rcpp::sourceCpp('tmp-tests/test-setvbuf.cpp')

system.time(test <- test_setvbuf(csv2, 10))
system.time(test <- test_setvbuf2(csv2, 100))
system.time(tst2 <- fpeek::peek_count_lines(csv2))
