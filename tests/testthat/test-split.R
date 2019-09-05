################################################################################

context("test-split.R")

################################################################################

test_that("'split_file' works", {
  SEQ <- seq_len(nrow(iris))
  strings <- c("", "", " ", sapply(10^(seq(0, 4, by = 0.2)), function(i) {
    paste(as.matrix(iris)[sample(SEQ, i, TRUE), ], collapse = " ")
  }))
  for (every in c(1, 2, 4, 12, 24, 25)) {
    writeLines(sample(strings, replace = TRUE), tmp <- tempfile())
    # Infos are correct
    infos <- split_file(tmp, every, tmp2 <- tempfile())
    expect_identical(infos[["name_in"]], tmp)
    expect_identical(infos[["prefix_out"]], tmp2)
    expect_equal(ceiling(infos[["nlines_all"]] / infos[["nlines_part"]]),
                 infos[["nfiles"]])
    expect_identical(infos[["nlines_all"]], 24L)
    # New files all exist
    files <- get_split_files(infos)
    expect_true(all(file.exists(files)))
    # Number of lines and size is summing to whole input file
    expect_identical(sum(sapply(files, nlines)), nlines(tmp))
    expect_identical(sum(file.size(files)), file.size(tmp))
  }
})

test_that("'split_file' with repeated header works", {
  tf <- tempfile()
  write.csv(cars, tf, row.names = FALSE)
  sf <- split_file(tf, 10, repeat_header = TRUE)
  gsf = get_split_files(sf)

  loaded_df <- Reduce(rbind, lapply(gsf, function(.x) {
    read.csv(.x)
  }))

  expect_setequal(names(loaded_df), c("speed", "dist"))

  expect_equal(nrow(loaded_df), 50)

  # clean up
  unlink(tf)
  unlink(gsf)
})

################################################################################

