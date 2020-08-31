# imports and lower level unexported functions

#' @importFrom utils head getS3method browseURL tail
NULL

## usethis namespace: start
#' @importFrom Rcpp sourceCpp
## usethis namespace: end
NULL

## usethis namespace: start
#' @useDynLib flow
## usethis namespace: end
NULL

# , .registration = TRUE

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
