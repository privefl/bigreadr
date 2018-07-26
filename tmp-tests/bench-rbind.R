mtcars <- datasets::mtcars
mtcars <- mtcars[rep(1:32, 1000), rep(1:11, 10)]
mtcars_dt <- data.table::as.data.table(mtcars)

list_mtcars <- rep(list(mtcars), 10)
list_mtcars_dt <- rep(list(mtcars_dt), 10)

rbind_df <- function(list_df) {
  list_df_merged <- lapply(seq_along(list_df[[1]]), function(k) {
    unlist(lapply(list_df, function(l) l[[k]]))
  })
  list_df_merged_named <- stats::setNames(list_df_merged, names(list_df[[1]]))
  as.data.frame(list_df_merged_named, stringsAsFactors = FALSE)
}

rbind_df2 <- function(list_df) {
  data.table::rbindlist(list_df)
}

microbenchmark::microbenchmark(

  A1 = rbind.data.frame(mtcars),
  A2 = rbind.data.frame(mtcars_dt),
  B1 = rbind_df(list(mtcars)),
  B2 = rbind_df(list(mtcars_dt)),
  C1 = rbind_df2(list(mtcars)),
  C2 = rbind_df2(list(mtcars_dt)),

  AA1 = do.call(rbind.data.frame, list_mtcars),
  AA2 = do.call(rbind.data.frame, list_mtcars_dt),
  BB1 = rbind_df(list_mtcars),
  BB2 = rbind_df(list_mtcars_dt),
  CC1 = rbind_df2(list_mtcars),
  CC2 = rbind_df2(list_mtcars_dt),

  times = 10
)
