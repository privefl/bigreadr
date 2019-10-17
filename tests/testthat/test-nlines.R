################################################################################

context("test-nlines.R")

################################################################################

test_that("'nlines()' works", {

  expect_error(nlines("does_not_exist.txt"))

  strings <- readRDS(system.file("testdata", "wrong_string.rds", package = "bigreadr"))
  writeLines(strings, tmp <- tempfile())
  expect_equal(nlines(tmp), 24)

  strings <- c("", "", " ", sapply(10^(seq(0, 4, by = 0.2)), function(i) {
    paste(as.matrix(iris)[sample(nrow(iris), i, TRUE), ], collapse = " ")
  }))
  replicate(100, {
    writeLines(sample(strings, replace = TRUE), tmp <- tempfile())
    expect_equal(nlines(tmp), length(readLines(tmp)))
  })
})

################################################################################

test_that("'nlines()' works with or without newline", {
  csv1 <- system.file("testdata", "cars_with_newline.csv",    package = "bigreadr")
  expect_identical(nlines(csv1), 51)
  csv2 <- system.file("testdata", "cars_without_newline.csv", package = "bigreadr")
  expect_identical(nlines(csv2), 51)
})

################################################################################
