################################################################################

#' Read a text file
#'
#' @param file Path to the file that you want to read from.
#' @param ... Other arguments to be passed to [data.table::fread].
#' @param data.table Whether to return a `data.table` or just a `data.frame`?
#'   Default is `FALSE` (and is the opposite of [data.table::fread]).
#' @param nThread Number of threads to use. Default uses all threads minus one.
#'
#' @return A `data.frame` by default; a `data.table` when `data.table = TRUE`.
#' @export
#'
#' @examples
#' tmp <- fwrite2(iris, tempfile())
#' iris2 <- fread2(tmp)
#' all.equal(iris2, iris)  ## fread doesn't use factors
fread2 <- function(file, ...,
                   data.table = FALSE,
                   nThread = getOption("bigreadr.nThread")) {

  data.table::fread(file = file, ..., data.table = data.table, nThread = nThread)
}

#' Write a data frame to a text file
#'
#' @param x Data frame to write.
#' @param file Path to the file that you want to write to.
#' @param ... Other arguments to be passed to [data.table::fwrite].
#' @param quote Whether to quote strings (default is `FALSE`).
#' @param nThread Number of threads to use. Default uses all threads minus one.
#'
#' @return Input parameter `file`, invisibly.
#' @export
#'
#' @examples
#' tmp <- fwrite2(iris, tempfile())
#' iris2 <- fread2(tmp)
#' all.equal(iris2, iris)  ## fread doesn't use factors
fwrite2 <- function(x, file, ...,
                    quote = FALSE,
                    nThread = getOption("bigreadr.nThread")) {

  data.table::fwrite(x, file, ..., quote = quote, nThread = nThread)
  invisible(file)
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
big_fread <- function(file, every_nlines,
                      .transform = identity, .combine = my_rbind,
                      skip = 0, ...,
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
  infos_split <- split_file(file, every_nlines = every_nlines)
  file_parts <- get_split_files(infos_split)
  on.exit(unlink(file_parts), add = TRUE)

  print_proc("Splitting")

  ## Read first part to get names and to skip some lines
  part1 <- fread2(file_parts[1], skip = skip, ...)
  names_df <- names(part1)
  part1 <- .transform(part1)

  print_proc("Reading + transforming first part")

  ## Read + transform other parts
  other_parts <- lapply(file_parts[-1], function(file_part) {
    .transform(fread2(file_part, skip = 0, col.names = names_df, ...))
  })

  print_proc("Reading + transforming other parts")

  ## Combine + transform all parts
  res <- do.call(.combine, c(list(part1), other_parts))

  print_proc("Combining")

  res
}

################################################################################
