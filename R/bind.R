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
#' str(iris)
#' str(rbind_df(list(iris, iris)))
#'
rbind_df <- function(list_df) {

  first_df <- list_df[[1]]
  if (data.table::is.data.table(first_df)) {
    data.table::rbindlist(list_df)
  } else if (is.data.frame(first_df)) {
    list_df_merged <- lapply(seq_along(first_df), function(k) {
      unlist(lapply(list_df, function(l) l[[k]]), recursive = FALSE)
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
#' str(iris)
#' str(cbind_df(list(iris, iris)))
#'
cbind_df <- function(list_df) {
  do.call(cbind, list_df)
}

################################################################################
