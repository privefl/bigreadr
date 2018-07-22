################################################################################

block_size <- function(m) {
  block.max <- 1  ## GB
  # 8 * n * m < opt * 1024^3
  # m < opt * 1024^3 / (8 * n)
  max(2, floor(block.max * 1024^3 / (8 * m)))
}

################################################################################

split_file <- function(file, every_nlines = NULL, split = "split") {

  split <- shortPathName(split)  ## useful when there are spaces in the path
  if (suppressWarnings(system(sprintf("%s --version", split))) != 0) {
    stop("System command 'split' is needed to use this package. See README.")
  }
}

################################################################################
