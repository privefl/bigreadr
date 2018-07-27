################################################################################

message2 <- function(...) message(sprintf(...))
# warning2 <- function(...) warning(sprintf(...), call. = FALSE)
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
