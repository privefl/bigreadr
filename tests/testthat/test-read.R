################################################################################

context("test-read.R")

iris$Species <- as.character(iris$Species)
csv <- fwrite2(iris, tempfile(fileext = ".csv"))

################################################################################

test_that("'fread2' changes default", {
  no_dt <- fread2(csv)
  expect_equal(no_dt, iris)
  expect_s3_class(no_dt, "data.frame")
  expect_failure(expect_s3_class(no_dt, "data.table"))
  expect_s3_class(fread2(csv, data.table = TRUE), "data.table")
})

test_that("'fread2' works with multiple files", {
  csv2 <- rep(csv, 3)
  no_dt <- fread2(csv2)
  expect_equal(no_dt, rbind(iris, iris, iris))
  expect_s3_class(no_dt, "data.frame")
  expect_failure(expect_s3_class(no_dt, "data.table"))
  expect_s3_class(fread2(csv2, data.table = TRUE), "data.table")

  expect_equal(dim(fread2(csv2, nrows = 5)), c(15, 5))
  expect_equal(dim(fread2(csv2, select = "Species")), c(450, 1))
})

test_that("'fread2' can use different types of input", {

  cmd <- sprintf("grep -v setosa %s", fwrite2(datasets::iris))
  expect_identical(fread2(cmd), data.table::fread(cmd, data.table = FALSE))

  url <- "https://raw.githubusercontent.com/privefl/bigsnpr/master/inst/extdata/example.fam"
  expect_identical(fread2(url), data.table::fread(url, data.table = FALSE))

  text <- paste(readLines(url), collapse = "\n")
  expect_identical(fread2(text), data.table::fread(url, data.table = FALSE))
})

################################################################################

test_that("'big_fread1' works", {

  iris1 <- big_fread1(file = csv, 50, print_timings = FALSE)
  expect_identical(iris1, iris)

  expect_warning(
    iris1 <- big_fread1(file = csv, 50, print_timings = FALSE,
                        .combine = function() stop("ERROR")),
    "Combining failed.")
  expect_length(iris1, 4)
  expect_identical(rbind_df(iris1), iris)

  iris2 <- big_fread1(file = csv, 250, print_timings = FALSE)
  expect_identical(iris2, iris)

  ind3 <- 1:4
  iris3 <- big_fread1(file = csv, 7, select = ind3, skip = 1, print_timings = FALSE)
  expect_equal(iris3, iris[ind3], check.attributes = FALSE)
  expect_identical(names(iris3), paste0("V", ind3))

  iris4 <- big_fread1(file = csv, 50, print_timings = FALSE,
                      .transform = function(df) subset(df, Species == "virginica"))
  expect_equal(iris4, subset(iris, Species == "virginica"), check.attributes = FALSE)

  expect_message(big_fread1(file = csv, 50, print_timings = TRUE), "seconds")
})

################################################################################

test_that("'big_fread2' works", {

  for (nb_parts in 1:7) {

    iris1 <- big_fread2(file = csv, nb_parts)
    expect_identical(iris1, iris)

    expect_warning(
      iris1 <- big_fread2(file = csv, nb_parts,
                          .combine = function() stop("ERROR")),
      "Combining failed.")
    expect_length(iris1, min(nb_parts, ncol(iris)))
    expect_identical(cbind_df(iris1), iris)

    ind2 <- 1
    iris2 <- big_fread2(file = csv, nb_parts, select = ind2, skip = 0)
    expect_identical(iris2, iris[ind2])

    ind3 <- 1:4
    iris3 <- big_fread2(file = csv, nb_parts, select = ind3, skip = 1)
    expect_equal(iris3, iris[ind3], check.attributes = FALSE)
    expect_identical(names(iris3), paste0("V", ind3))

    expect_error(big_fread2(file = csv, nb_parts, select = c(4, 1:3), skip = 0),
                 "Argument 'select' should be sorted.", fixed = TRUE)
  }
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
  expect_identical(scan(csv, "", skip = 0, nlines = 1, sep = "\n", quiet = TRUE),
                   paste(names(iris), collapse = ","))
  expect_identical(scan(csv, "", skip = 1, nlines = 1, sep = "\n", quiet = TRUE),
                   paste(as.matrix(iris)[1, ], collapse = ","))
})

################################################################################
