################################################################################

every_nlines <- function(file, nlines) {
  size_max <- 1024^3 / 2  ## 500 MB
  nlines_max <- size_max * nlines / file.size(file)
  max(2, floor(nlines_max))
}

################################################################################

#' Split file
#'
#' @param file Path to file.
#' @param every_nlines Number of lines per new file.
#'   Default splits the file in files of 500 MB.
#' @param nlines Number of lines of `file` (including possible header).
#'   Default uses `fpeek::peek_count_lines(file)` to count the number of lines.
#' @param split Path to system command 'split'. See README.
#'
#' @return A vector of paths to the new files.
#' @export
#'
split_file <- function(file, every_nlines = NULL, nlines = NULL, split = "split") {

  split <- utils::shortPathName(split)  ## useful when there are spaces in the path
  if (suppressWarnings(system(sprintf("%s --version", split))) != 0) {
    stop("System command 'split' is needed to use this package. See README.")
  }

  if (is.null(every_nlines)) {
    if (is.null(nlines)) {
      nlines <- fpeek::peek_count_lines(file)
    }
    every_nlines <- every_nlines(file, nlines)
  }

  tmp <- tempfile()
  system(sprintf("%s -l %d %s %s", split, every_nlines, file, tmp))
  file_parts <- list.files(dirname(tmp), basename(tmp), full.names = TRUE)
}

################################################################################
