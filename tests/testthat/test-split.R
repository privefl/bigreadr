################################################################################

context("test-split.R")

################################################################################

test_that("'split_file()' works", {

  strings <- c("", "", " ", sapply(10^(seq(0, 4, by = 0.2)), function(i) {
    paste(as.matrix(iris)[sample(nrow(iris), i, TRUE), ], collapse = " ")
  }))
  for (every in c(1, 2, 4, 12, 24, 25)) {
    writeLines(sample(strings, replace = TRUE), tmp <- tempfile())
    # Infos are correct
    infos <- split_file(tmp, every, tmp2 <- tempfile())
    expect_identical(infos[["name_in"]], normalizePath(tmp))
    expect_identical(infos[["prefix_out"]], path.expand(tmp2))
    expect_identical(infos[["repeat_header"]], FALSE)
    expect_equal(ceiling(infos[["nlines_all"]] / infos[["nlines_part"]]),
                 infos[["nfiles"]])
    expect_equal(infos[["nlines_all"]], 24)
    # New files all exist
    files <- get_split_files(infos)
    expect_true(all(file.exists(files)))
    # Number of lines and size is summing to whole input file
    expect_identical(sum(sapply(files, nlines)), nlines(tmp))
    expect_identical(sum(file.size(files)), file.size(tmp))
    # Content is the same
    expect_identical(do.call('c', lapply(files, readLines)), readLines(tmp))
  }
})

################################################################################

test_that("'split_file()' works with a repeated header", {

  # Reading splitted files is easier
  tf <- fwrite2(cars, tempfile(fileext = ".csv"))
  sf1 <- split_file(tf, 10)
  gsf1 <- get_split_files(sf1)
  expect_equal(sum(sapply(gsf1, nlines)), 51)
  expect_error(Reduce(rbind, lapply(gsf1, fread2)),
               "names do not match previous names")

  sf2 <- split_file(tf, 10, repeat_header = TRUE)
  gsf2 <- get_split_files(sf2)
  expect_equal(sapply(gsf2, readLines, n = 1), rep(readLines(tf, n = 1), 6),
               check.attributes = FALSE)

  loaded_df <- Reduce(rbind, lapply(gsf2, read.csv))
  expect_equal(names(loaded_df), c("speed", "dist"))
  expect_equal(nrow(loaded_df), 50)

  # Content is the same
  first_part <- readLines(gsf2[1])
  other_parts <- unlist(lapply(gsf2[-1], function(f) readLines(f)[-1]))
  expect_identical(c(first_part, other_parts), readLines(tf))
})

################################################################################

test_that("'split_file()' works with a repeated header (special cases)", {

  strings <- c("", "", " ", sapply(10^(seq(0, 4, by = 0.2)), function(i) {
    paste(as.matrix(iris)[sample(nrow(iris), i, TRUE), ], collapse = " ")
  }))
  for (every in c(1, 2, 4, 12, 24, 25)) {
    writeLines(sample(strings, replace = TRUE), tmp <- tempfile())
    # Infos are correct
    infos <- split_file(tmp, every, tmp2 <- tempfile(), repeat_header = TRUE)
    expect_identical(infos[["name_in"]], normalizePath(tmp))
    expect_identical(infos[["prefix_out"]], path.expand(tmp2))
    expect_identical(infos[["repeat_header"]], TRUE)
    nlines_all_without_header <- infos[["nlines_all"]] - infos[["nfiles"]]
    expect_equal(nlines_all_without_header + 1, 24)
    expect_equal(ceiling((nlines_all_without_header + 1) / infos[["nlines_part"]]),
                 infos[["nfiles"]])
    # New files all exist
    files <- get_split_files(infos)
    expect_true(all(file.exists(files)))
    # Same first line for each file
    expect_equal(sapply(files, readLines, n = 1),
                 rep(readLines(tmp, n = 1), infos[["nfiles"]]),
                 check.attributes = FALSE)
    # Content is the same
    first_part <- readLines(files[1])
    other_parts <- unlist(lapply(files[-1], function(f) readLines(f)[-1]))
    expect_identical(c(first_part, other_parts), readLines(tmp))
  }
})

################################################################################
