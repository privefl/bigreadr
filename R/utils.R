################################################################################

message2 <- function(...) message(sprintf(...))
warning2 <- function(...) warning(sprintf(...), call. = FALSE)
stop2    <- function(...) stop(sprintf(...), call. = FALSE)

################################################################################

# FILE EXISTS
assert_exist <- function(file) {
  if (!file.exists(file)) stop2("File '%s' doesn't exist.", file)
}

# assert_noexist <- function(file) {
#   if (file.exists(file)) stop2("File '%s' already exists.", file)
# }

################################################################################

# INTEGERS
assert_int <- function(x) {
  if (!is.null(x) && any(x != trunc(x)))
    stop2("'%s' should contain only integers.", deparse(substitute(x)))
}

################################################################################

# POSITIVE INDICES
assert_pos <- function(x)  {
  if (!all(x > 0))
    stop2("'%s' should have only positive values.", deparse(substitute(x)))
}

################################################################################
