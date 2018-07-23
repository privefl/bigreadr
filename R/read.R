################################################################################

fread2 <- function(file, ..., data.table = FALSE) {
  data.table::fread(file = file, ..., data.table = data.table)
}

fwrite2 <- function(x, file, ..., quote = FALSE) {
  data.table::fwrite(x, file, ..., quote = quote)
}

################################################################################

#' Merge data frames
#'
#' @param ... Multiple data frames with the same variables in the same order.
#'
#' @return One merged data frame with the names of the first input data frame.
#' @export
#'
#' @examples
#' my_rbind(iris, iris)
my_rbind <- function(...) {
  list_df <- list(...)
  list_df_merged <- lapply(seq_along(list_df[[1]]), function(k) {
    do.call(c, lapply(list_df, function(l) l[[k]]))
  })
  list_df_merged_named <- stats::setNames(list_df_merged, names(list_df[[1]]))
  as.data.frame(list_df_merged_named, stringsAsFactors = FALSE)
}

################################################################################

#' Read large text file
#'
#' Read large text file by flitting it before.
#'
#' @inheritParams split_file
#' @param .transform Function to transform each data frame corresponding to each
#'   part of the `file`. Default doesn't change anything.
#' @param .combine Function to combine results. Should accept multiple arguments
#'   (`...`) such as `rbind` (the default).
#' @param skip Number of lines to skip at the beginning of `file`.
#' @param ... Other arguments to be passed to [data.table::fread],
#'   excepted `input`, `file`, `skip` and `col.names`.
#' @param print_timings Whether to print timings? Default is `TRUE`.
#'
#' @return A vector of paths to the new files.
#' @export
#'
big_fread <- function(file, .transform = identity, .combine = my_rbind,
                      skip = 0, ...,
                      every_x_mb = 100, split = getOption("bigreadr.split"),
                      print_timings = TRUE) {

  begin <- proc.time()[3]
  print_proc <- function(action) {
    if (print_timings) {
      reset <- proc.time()[3]
      message2("%s: %s seconds.", action, round(reset - begin, 1))
      begin <<- reset
    }
  }

  ## Split file
  file_parts <- split_file(file, every_x_mb = every_x_mb, split = split)

  print_proc("Splitting")

  ## Read first part to get names and to skip some lines
  part1 <- .transform(fread2(file_parts[1], skip = skip, ...))

  print_proc("Reading + transforming first part")

  ## Read + transform other parts
  other_parts <- lapply(file_parts[-1], function(file_part) {
    .transform(fread2(file_part, skip = 0, col.names = names(part1), ...))
  })

  print_proc("Reading + transforming other parts")

  ## Combine + transform all parts
  res <- do.call(.combine, c(list(part1), other_parts))

  print_proc("Combining")

  res
}

################################################################################
