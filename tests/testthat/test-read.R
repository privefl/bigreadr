context("test-read.R")

fwrite2(iris, tmp <- tempfile())

test_that("Use 'scan' correctly", {
  expect_identical(scan(tmp, "", skip = 0, nlines = 1, sep = "\n", quiet = TRUE),
                   paste(names(iris), collapse = ","))
  expect_identical(scan(tmp, "", skip = 1, nlines = 1, sep = "\n", quiet = TRUE),
                   paste(as.matrix(iris)[1, ], collapse = ","))
})


test_that("'fread2' changes default", {
  no_dt <- fread2(tmp)
  expect_s3_class(no_dt, "data.frame")
  expect_failure(expect_s3_class(no_dt, "data.table"))
  expect_s3_class(fread2(tmp, data.table = TRUE), "data.table")
})
