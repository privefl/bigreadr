################################################################################

context("test-bind.R")

################################################################################

test_that("'cbind_df' works", {

  # No copies with 'cbind.data.frame'
  iris$Species <- as.character(iris$Species)
  addr <- sapply(iris, data.table::address)
  iris2 <- cbind_df(list(iris, iris))
  expect_identical(sapply(iris2, data.table::address), c(addr, addr))

  # Data frame with factors
  df <- datasets::iris
  df2 <- cbind_df(list(df))
  expect_identical(df2, df)
  df3 <- cbind_df(list(df, df, df))
  expect_equal(dim(df3), c(150, 15))
  expect_identical(class(df3), "data.frame")

  # Data table
  dt <- data.table::as.data.table(df)
  dt2 <- cbind_df(list(dt))
  expect_identical(class(dt2), c("data.table", "data.frame"))
  expect_identical(dt2, dt)
  dt3 <- cbind_df(list(dt, dt, dt))
  expect_equal(dim(dt3), c(150, 15))
  expect_identical(class(dt3), c("data.table", "data.frame"))

  # Data frame without factors
  df$Species <- as.character(df$Species)
  df2 <- cbind_df(list(df))
  expect_identical(df2, df)
  df3 <- cbind_df(list(df, df, df))
  expect_equal(dim(df3), c(150, 15))
  expect_identical(class(df3), "data.frame")
})

################################################################################

test_that("'rbind_df' works", {

  # Data frame with factors
  df <- datasets::iris
  df2 <- rbind_df(list(df))
  expect_identical(df2, df)
  df3 <- rbind_df(list(df, df, df))
  expect_equal(dim(df3), c(450, 5))
  expect_identical(class(df3), "data.frame")

  # Data table
  dt <- data.table::as.data.table(df)
  dt2 <- rbind_df(list(dt))
  expect_identical(class(dt2), c("data.table", "data.frame"))
  expect_identical(dt2, dt)
  dt3 <- rbind_df(list(dt, dt, dt))
  expect_equal(dim(dt3), c(450, 5))
  expect_identical(class(dt3), c("data.table", "data.frame"))

  # Data frame without factors
  df$Species <- as.character(df$Species)
  df2 <- rbind_df(list(df))
  expect_identical(df2, df)
  df3 <- rbind_df(list(df, df, df))
  expect_equal(dim(df3), c(450, 5))
  expect_identical(class(df3), "data.frame")

  # Error
  expect_error(rbind_df(list(as.matrix(iris), iris)),
               "'list_df' should contain data tables or data frames.", fixed = TRUE)
})

################################################################################
