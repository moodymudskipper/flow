# imports and lower level unexported functions

#' @importFrom utils head getS3method browseURL tail getFromNamespace lsf.str
#' @importFrom utils txtProgressBar setTxtProgressBar capture.output
#' @importFrom utils installed.packages
#' @importFrom graphics plot
#' @importFrom stats setNames aggregate
#' @importFrom methods formalArgs
NULL


.onLoad <- function(libname, pkgname) {
  #nocov start
  ns <- asNamespace(pkgname)
  makeActiveBinding("d", flow_draw, ns)
  namespaceExport(ns, "d")

  op <- options()
  op.flow <- list(
    flow.indenter = "\u2800",
    flow.svg = TRUE
  )
  toset <- !(names(op.flow) %in% names(op))
  if(any(toset)) options(op.flow[toset])

  invisible()
  #nocov end
}
