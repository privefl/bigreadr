################################################################################

#' Number of lines
#'
#' Get the number of lines of a file using R package {fpeek}.
#'
#' @param file Path of the file.
#'
#' @return The number of lines as one integer.
#' @export
#'
#' @examples
#' csv <- fwrite2(iris, tempfile(fileext = "csv"))
#' nlines(csv)
nlines <- function(file) {
  fpeek::peek_count_lines(file)
}

################################################################################
