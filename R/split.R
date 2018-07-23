################################################################################

#' Split file
#'
#' @param file Path to file.
#' @param every_x_mb Maximum size of new files (default is `100` Mo).
#' @param split Path to system command 'split'. See README.
#'
#' @return A vector of paths to the new files.
#' @export
#'
split_file <- function(file, every_x_mb = 100, split = "split") {

  assert_exist(file)

  ## Useful when there are spaces in the path on Windows
  if (Sys.info()[["sysname"]] == "Windows") split <- utils::shortPathName(split)
  if (suppressWarnings(system(sprintf("%s --version", split))) != 0) {
    stop2("System command 'split' is needed to use this package. See README.")
  }

  tmp <- tempfile()
  status <- system(sprintf("%s -C %dm %s %s", split, every_x_mb, file, tmp))
  if (status != 0) warning2("Something potentially went wrong when splitting.")

  file_parts <- list.files(dirname(tmp), basename(tmp), full.names = TRUE)
}

################################################################################
