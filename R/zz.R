# imports and lower level unexported functions

#' @importFrom utils head getS3method browseURL tail getFromNamespace lsf.str
#' @importFrom utils txtProgressBar setTxtProgressBar capture.output
#' @importFrom utils installed.packages
#' @importFrom stats setNames aggregate
NULL

## usethis namespace: start
#' @importFrom Rcpp sourceCpp
## usethis namespace: end
NULL

## usethis namespace: start
#' @useDynLib flow, .registration = TRUE
## usethis namespace: end
NULL



.onLoad <- function(libname, pkgname) {
  #nocov start
  ns <- asNamespace(pkgname)
  makeActiveBinding("d", flow_draw, ns)
  namespaceExport(ns, "d")


  op <- options()
  op.flow <- list(
    flow.auto_draw = FALSE
  )
  toset <- !(names(op.flow) %in% names(op))
  if(any(toset)) options(op.flow[toset])

  invisible()
  #nocov end
}
