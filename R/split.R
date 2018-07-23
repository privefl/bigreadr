################################################################################

get_every_nlines <- function(file, nlines) {
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
#'   This argument is only used to guess `every_nlines`.
#' @param split Path to system command 'split'. See README.
#'
#' @return A vector of paths to the new files.
#' @export
#'
split_file <- function(file, every_nlines = NULL, nlines = NULL, split = "split") {

  assert_exist(file)

  ## Useful when there are spaces in the path on Windows
  if (Sys.info()[["sysname"]] == "Windows") split <- utils::shortPathName(split)
  if (suppressWarnings(system(sprintf("%s --version", split))) != 0) {
    stop2("System command 'split' is needed to use this package. See README.")
  }

  if (is.null(every_nlines)) {
    if (is.null(nlines)) {
      nlines <- fpeek::peek_count_lines(file)
      message2("%s lines detected.", format(nlines, nsmall = 0, big.mark = ","))
    }
    every_nlines <- get_every_nlines(file, nlines)
    message2("The file will be separated every %s lines.",
             format(every_nlines, nsmall = 0, big.mark = ","))
  }

  tmp <- tempfile()
  status <- system(sprintf("%s -l %d %s %s", split, every_nlines, file, tmp))
  if (status != 0) warning2("Something potentially went wrong when splitting.")

  file_parts <- list.files(dirname(tmp), basename(tmp), full.names = TRUE)
  message2("Splitting: %d temporary files have been created.", length(file_parts))

  structure(file_parts, every_nlines = every_nlines, nlines = nlines)
}

################################################################################
