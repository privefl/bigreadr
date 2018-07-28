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
#' tmp <- fwrite2(iris)
#' nlines(tmp)
nlines <- function(file) {
  fpeek::peek_count_lines(file)
}

################################################################################
