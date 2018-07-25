################################################################################

.onLoad <- function(libname, pkgname) {
  options(
    bigreadr.nThread = parallel::detectCores() - 1L
  )
}

################################################################################

.onUnload <- function(libpath) {
  options(
    bigreadr.nThread = NULL
  )
}

################################################################################
