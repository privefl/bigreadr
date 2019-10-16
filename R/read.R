################################################################################

#' Read text file(s)
#'
#' @param input Path to the file(s) that you want to read from.
#'   This can also be a command, some text or an URL.
#'   If a vector of inputs is provided, resulting data frames are appended.
#' @param ... Other arguments to be passed to [data.table::fread].
#' @param data.table Whether to return a `data.table` or just a `data.frame`?
#'   Default is `FALSE` (and is the opposite of [data.table::fread]).
#' @param nThread Number of threads to use. Default uses all threads minus one.
#'
#' @return A `data.frame` by default; a `data.table` when `data.table = TRUE`.
#' @export
#'
#' @examples
#' tmp <- fwrite2(iris)
#' iris2 <- fread2(tmp)
#' all.equal(iris2, iris)  ## fread doesn't use factors
fread2 <- function(input, ...,
                   data.table = FALSE,
                   nThread = getOption("bigreadr.nThread")) {

  if (missing(input)) {
    data.table::fread(..., data.table = data.table, nThread = nThread)
  } else if (length(input) > 1) {
    rbind_df(lapply(input, fread2, ..., data.table = data.table, nThread = nThread))
  } else {
    data.table::fread(input, ..., data.table = data.table, nThread = nThread)
  }
}

################################################################################

#' Write a data frame to a text file
#'
#' @param x Data frame to write.
#' @param file Path to the file that you want to write to.
#'   Defaults uses `tempfile()`.
#' @param ... Other arguments to be passed to [data.table::fwrite].
#' @param quote Whether to quote strings (default is `FALSE`).
#' @param nThread Number of threads to use. Default uses all threads minus one.
#'
#' @return Input parameter `file`, invisibly.
#' @export
#'
#' @examples
#' tmp <- fwrite2(iris)
#' iris2 <- fread2(tmp)
#' all.equal(iris2, iris)  ## fread doesn't use factors
fwrite2 <- function(x, file = tempfile(), ...,
                    quote = FALSE,
                    nThread = getOption("bigreadr.nThread")) {

  data.table::fwrite(x, file, ..., quote = quote, nThread = nThread)
  invisible(file)
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
#'   excepted `input`, `file`, `skip`, `col.names` and `showProgress`.
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
  part1 <- fread2(file_parts[1], skip = skip, ..., showProgress = FALSE)
  names_df <- names(part1)
  part1 <- .transform(part1)

  print_proc("Reading + transforming first part")

  ## Read + transform other parts
  other_parts <- lapply(file_parts[-1], function(file_part) {
    .transform(fread2(file_part, skip = 0, col.names = names_df,
                      ..., showProgress = FALSE))
  })

  print_proc("Reading + transforming other parts")

  ## Combine
  all_parts <- unname(c(list(part1), other_parts))
  res <- tryCatch(.combine(all_parts), error = function(e) {
    warning2("Combining failed. Returning list of parts instead..")
    all_parts
  })

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
#'   Default uses `part_size` to set a good value.
#' @param .transform Function to transform each data frame corresponding to each
#'   block of selected columns. Default doesn't change anything.
#' @param .combine Function to combine results (list of data frames).
#' @param skip Number of lines to skip at the beginning of `file`.
#' @param select Indices of columns to keep (sorted). Default keeps them all.
#' @param ... Other arguments to be passed to [data.table::fread],
#'   excepted `input`, `file`, `skip`, `select` and `showProgress`.
#' @param progress Show progress? Default is `FALSE`.
#' @param part_size Size of the parts if `nb_parts` is not supplied.
#'   Default is `500 * 1024^2` (500 MB).
#'
#' @return The outputs of `fread2` + `.transform`, combined with `.combine`.
#' @export
#'
big_fread2 <- function(file, nb_parts = NULL,
                       .transform = identity,
                       .combine = cbind_df,
                       skip = 0,
                       select = NULL,
                       progress = FALSE,
                       part_size = 500 * 1024^2,  ## 500 MB
                       ...) {

  assert_exist(file)
  ## Split selected columns in nb_parts
  if (is.null(select)) {
    nb_cols <- ncol(fread2(file, nrows = 1, skip = skip, ...))
    select <- seq_len(nb_cols)
  } else {
    assert_int(select); assert_pos(select)
    if (is.unsorted(select, strictly = TRUE))
      stop2("Argument 'select' should be sorted.")
  }
  # Number of parts
  if (is.null(nb_parts)) {
    nb_parts <- ceiling(file.size(file) / part_size)
    if (progress) message2("Will read the file in %d parts.", nb_parts)
  }
  split_cols <- cut_in_nb(select, nb_parts)

  if (progress) {
    pb <- utils::txtProgressBar(min = 0, max = length(select), style = 3)
    on.exit(close(pb), add = TRUE)
  }

  ## Read + transform other parts
  already_read <- 0
  all_parts <- lapply(split_cols, function(cols) {
    part <- .transform(
      fread2(file, skip = skip, select = cols, ..., showProgress = FALSE)
    )
    already_read <<- already_read + length(cols)
    if (progress) utils::setTxtProgressBar(pb, already_read)
    part
  })
  all_parts <- unname(all_parts)

  ## Combine
  tryCatch(.combine(all_parts), error = function(e) {
    warning2("Combining failed. Returning list of parts instead..")
    all_parts
  })
}

################################################################################
