################################################################################

fread2 <- function(..., data.table = FALSE) {
  data.table::fread(..., data.table = data.table)
}

fwrite2 <- function(x, file, ..., quote = FALSE) {
  data.table::fwrite(x, file, ..., quote = quote)
}

################################################################################

#' Read large text file
#'
#' Read large text file by flitting it before.
#'
#' @inheritParams split_file
#' @param .transform Function to transform each part. See examples.
#' @param .combine Function to combine results.
#'   Should accept multiple arguments (`...`) such as `rbind`.
#' @param skip Number of lines to skip at the beginning of `file`.
#' @param ... Other arguments to be passed to [data.table::fread],
#'   expected `input`, `file`, `skip` and `col.names`.
#'
#' @return A vector of paths to the new files.
#' @export
#'
big_fread <- function(file, .transform, .combine, skip = 0, ...,
                      every_nlines = NULL, nlines = NULL, split = "split") {

  ## Split file
  file_parts <- split_file(file, every_nlines = every_nlines,
                           nlines = nlines, split = split)
  # every_nlines <- attr(file_parts, "every_nlines")
  # nlines       <- attr(file_parts, "nlines")

  ## Read first part and..
  part1 <- .transform(fread2(file_parts[1], skip = skip, ...))

  other_parts <- lapply(file_parts[-1], function(file_part) {
    .transform(fread2(file_part, skip = 0, col.names = names(part1), ...))
  })

  # n <- nlines - every_nlines + nrow(part1)

  do.call(.combine, c(list(part1), other_parts))
}

################################################################################
