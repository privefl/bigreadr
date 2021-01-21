################################################################################

.onLoad <- function(libname, pkgname) {
  options(
    bigreadr.nThread = parallelly::availableCores() - 1L
  )
}

################################################################################

.onUnload <- function(libpath) {
  options(
    bigreadr.nThread = NULL
  )
}

################################################################################
