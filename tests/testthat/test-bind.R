################################################################################

context("test-bind.R")

################################################################################

test_that("No copies with 'cbind.data.frame'", {
  iris$Species <- as.character(iris$Species)
  addr <- sapply(iris, data.table::address)
  iris2 <- cbind_df(iris, iris)
  expect_identical(sapply(iris2, data.table::address), c(addr, addr))
})

################################################################################

test_that("My implementation of 'rbind' works", {
  fct_merged <- unlist(list(factor(letters[1:3]), factor(letters[3:5])))
  expect_identical(levels(fct_merged), letters[1:5])
  expect_identical(rbind(iris, iris), rbind_df(iris, iris))
})

################################################################################
