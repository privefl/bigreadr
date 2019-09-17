################################################################################

#' Number of lines
#'
#' Get the number of lines of a file.
#'
#' @param file Path of the file.
#'
#' @return The number of lines as one integer.
#' @export
#'
#' @examples
#' tmp <- fwrite2(iris)
#' nlines(tmp)
#'
nlines <- function(file) {
  nlines_cpp( normalizePath(file, mustWork = TRUE) )
}

################################################################################

#' Split file every nlines
#'
#' @param file Path to file that you want to split.
#' @param every_nlines Maximum number of lines in new file parts.
#' @param prefix_out Prefix for created files. Default uses `tempfile()`.
#' @param repeat_header Whether to repeat the header row in each file.
#'   Default is `FALSE`.
#'
#' @return A list with
#'   - `name_in`: input parameter `file`,
#'   - `prefix_out`: input parameter `prefix_out``,
#'   - `nfiles`: Number of files (parts) created,
#'   - `nlines_part`: input parameter `every_nlines`,
#'   - `nlines_all`: total number of lines of `file`.
#' @export
#'
#' @examples
#' tmp <- fwrite2(iris)
#' infos <- split_file(tmp, 100)
#' str(infos)
#' get_split_files(infos)
split_file <- function(file, every_nlines,
                       prefix_out = tempfile(),
                       repeat_header = FALSE) {

  split_every_nlines(
    name_in       = normalizePath(file, mustWork = TRUE),
    prefix_out    = path.expand(prefix_out),
    every_nlines  = every_nlines,
    repeat_header = repeat_header
  )
}

################################################################################

#' Get files from splitting.
#'
#' @param split_file_out Output of [split_file].
#'
#' @return Vector of file paths created by [split_file].
#' @export
#' @rdname split_file
#'
get_split_files <- function(split_file_out) {

  sprintf("%s_%s.txt",
          split_file_out[["prefix_out"]],
          seq_len(split_file_out[["nfiles"]]))
}

################################################################################
