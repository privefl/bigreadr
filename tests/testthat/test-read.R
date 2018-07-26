################################################################################

context("test-read.R")

iris$Species <- as.character(iris$Species)
fwrite2(iris, tmp <- tempfile())

################################################################################

test_that("'fread2' changes default", {
  no_dt <- fread2(tmp)
  expect_s3_class(no_dt, "data.frame")
  expect_failure(expect_s3_class(no_dt, "data.table"))
  expect_s3_class(fread2(tmp, data.table = TRUE), "data.table")
})

################################################################################

test_that("'big_fread2' works", {

  iris1 <- big_fread2(file = tmp, 1)
  expect_identical(iris1, iris)

  ind2 <- c(5, 1, 3)
  iris2 <- big_fread2(file = tmp, 2, select = ind2, skip = 0)
  expect_identical(iris2, iris[ind2])

  ind3 <- c(4, 1:3)
  iris3 <- big_fread2(file = tmp, 7, select = ind3, skip = 1)
  expect_equal(iris3, iris[ind3], check.attributes = FALSE)
  expect_identical(names(iris3), paste0("V", ind3))
})

################################################################################

test_that("Same column accessor", {
  iris_dt <- data.table::as.data.table(iris)
  expect_equal(iris[, 1:3], as.data.frame(iris_dt[, 1:3]))
  expect_equal(iris[, 3, drop = FALSE],
               as.data.frame(iris_dt[, 3, drop = FALSE]))
})

################################################################################

test_that("Use 'scan' correctly", {
  expect_identical(scan(tmp, "", skip = 0, nlines = 1, sep = "\n", quiet = TRUE),
                   paste(names(iris), collapse = ","))
  expect_identical(scan(tmp, "", skip = 1, nlines = 1, sep = "\n", quiet = TRUE),
                   paste(as.matrix(iris)[1, ], collapse = ","))
})

################################################################################
