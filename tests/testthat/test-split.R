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
    infos <- split_file(tmp, every, tmp2 <- tempfile())
    files <- get_split_files(infos)
    expect_true(all(file.exists(files)))
    expect_identical(infos[["name_in"]], tmp)
    expect_identical(infos[["prefix_out"]], tmp2)
    expect_equal(ceiling(infos[["nlines_all"]] / infos[["nlines_part"]]),
                 infos[["nfiles"]])
    expect_identical(infos[["nlines_all"]], 24L)
  }
})

################################################################################
