################################################################################

fread2 <- function(..., data.table = FALSE) {
  data.table::fread(..., data.table = data.table)
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
  list_df_merged_named <- setNames(list_df_merged, names(list_df[[1]]))
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
#'   expected `input`, `file`, `skip` and `col.names`.
#'
#' @return A vector of paths to the new files.
#' @export
#'
big_fread <- function(file, .transform = identity, .combine = my_rbind,
                      skip = 0, ...,
                      every_x_mb = 100, split = "split") {

  begin <- proc.time()[3]

  ## Split file
  file_parts <- split_file(file, every_x_mb = every_x_mb, split = split)

  cat("Splitting:", round(proc.time()[3] - begin, 1), "\n")

  ## Read first part to get names and to skip some lines
  part1 <- .transform(fread2(file_parts[1], skip = skip, ...))

  cat("Part 1:", round(proc.time()[3] - begin, 1), "\n")

  ## Read other parts
  other_parts <- lapply(file_parts[-1], function(file_part) {
    .transform(fread2(file_part, skip = 0, col.names = names(part1), ...))
  })

  cat("Other parts:", round(proc.time()[3] - begin, 1), "\n")

  ## Combine all parts
  res <- do.call(.combine, c(list(part1), other_parts))

  cat("Combining:", round(proc.time()[3] - begin, 1), "\n")

  res
}

################################################################################
