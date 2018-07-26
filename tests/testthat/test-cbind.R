context("test-cbind.R")

test_that("No copies with 'cbind.data.frame'", {
  iris$Species <- as.character(iris$Species)
  addr <- sapply(iris, data.table::address)
  iris2 <- cbind.data.frame(iris, iris)
  expect_identical(sapply(iris2, data.table::address), c(addr, addr))
})
