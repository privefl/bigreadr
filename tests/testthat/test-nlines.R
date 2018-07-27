################################################################################

context("test-nlines.R")

################################################################################

test_that("'nlines' works", {
  SEQ <- seq_len(nrow(iris))
  strings <- c("", "", " ", sapply(10^(seq(0, 4, by = 0.2)), function(i) {
    paste(as.matrix(iris)[sample(SEQ, i, TRUE), ], collapse = " ")
  }))
  replicate(10, {
    writeLines(sample(strings, replace = TRUE), tmp <- tempfile())
    expect_identical(nlines(tmp), 24L)
  })
})

################################################################################
