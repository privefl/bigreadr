################################################################################

.onLoad <- function(libname, pkgname) {
  options(
    bigreadr.nThread = parallel::detectCores() - 1L,
    bigreadr.part.size = 500 * 1024^2   ## 500 MB
  )
}

################################################################################

.onUnload <- function(libpath) {
  options(
    bigreadr.nThread = NULL,
    bigreadr.part.size = NULL
  )
}

################################################################################
