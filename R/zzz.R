################################################################################

.onLoad <- function(libname, pkgname) {
  options(
    bigreadr.nThread = max(parallelly::availableCores() - 1L, 1L)
  )
}

################################################################################

.onUnload <- function(libpath) {
  options(
    bigreadr.nThread = NULL
  )
}

################################################################################
