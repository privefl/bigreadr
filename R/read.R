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
#' @param list_df A list of multiple data frames with the same variables in the
#'   same order.
#'
#' @return One merged data frame with the names of the first input data frame.
#' @export
#'
#' @examples
#' rbind_df(list(iris, iris))
rbind_df <- function(list_df) {

  first_df <- list_df[[1]]
  if (data.table::is.data.table(first_df)) {
    data.table::rbindlist(list_df)
  } else if (is.data.frame(first_df)) {
    list_df_merged <- lapply(seq_along(first_df), function(k) {
      unlist(lapply(list_df, function(l) l[[k]]))
    })
    list_df_merged_named <- stats::setNames(list_df_merged, names(list_df[[1]]))
    as.data.frame(list_df_merged_named, stringsAsFactors = FALSE)
  } else {
    stop2("'list_df' should contain data tables or data frames.")
  }
}

################################################################################

#' Merge data frames
#'
#' @param list_df A list of multiple data frames with the same observations in
#'   the same order.
#'
#' @return One merged data frame.
#' @export
#'
#' @examples
#' cbind_df(list(iris, iris))
cbind_df <- function(list_df) {
  do.call(cbind.data.frame, list_df)
}

################################################################################

#' Read large text file
#'
#' Read large text file by splitting lines.
#'
#' @param file Path to file that you want to read.
#' @inheritParams split_file
#' @param .transform Function to transform each data frame corresponding to each
#'   part of the `file`. Default doesn't change anything.
#' @param .combine Function to combine results (list of data frames).
#' @param skip Number of lines to skip at the beginning of `file`.
#' @param ... Other arguments to be passed to [data.table::fread],
#'   excepted `input`, `file`, `skip` and `col.names`.
#' @param print_timings Whether to print timings? Default is `TRUE`.
#'
#' @inherit fread2 return
#' @export
#'
big_fread1 <- function(file, every_nlines,
                       .transform = identity, .combine = rbind_df,
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

  ## Combine
  res <- .combine(c(list(part1), other_parts))

  print_proc("Combining")

  res
}

################################################################################

cut_in_nb <- function(x, nb) {
  split(x, sort(rep_len(seq_len(nb), length(x))))
}

#' Read large text file
#'
#' Read large text file by splitting columns.
#'
#' @param file Path to file that you want to read.
#' @param nb_parts Number of parts in which to split reading (and transforming).
#'   Parts are referring to blocks of selected columns.
#' @param .transform Function to transform each data frame corresponding to each
#'   block of selected columns. Default doesn't change anything.
#' @param .combine Function to combine results (list of data frames).
#' @param skip Number of lines to skip at the beginning of `file`.
#' @param select Indices of columns to keep (sorted). Default keeps them all.
#' @param ... Other arguments to be passed to [data.table::fread],
#'   excepted `input`, `file`, `skip` and `select`.
#'
#' @inherit fread2 return
#' @export
#'
big_fread2 <- function(file, nb_parts,
                       .transform = identity,
                       .combine = cbind_df,
                       skip = 0, select = NULL, ...) {

  ## Split selected columns in nb_parts
  if (is.null(select)) {
    nb_cols <- ncol(fread2(file, nrows = 1, skip = skip, ...))
    select <- seq_len(nb_cols)
  } else {
    if (is.unsorted(select, strictly = TRUE))
      stop2("Argument 'select' should be sorted.")
  }
  split_cols <- cut_in_nb(select, nb_parts)

  ## Read + transform other parts
  all_parts <- lapply(split_cols, function(cols) {
    .transform(fread2(file, skip = skip, select = cols, ...))
  })

  ## Combine
  .combine(unname(all_parts))
}

################################################################################
