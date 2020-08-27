.onLoad <- function(libname, pkgname) {
  #nocov start
  ns <- asNamespace(pkgname)
  makeActiveBinding("d", flow_draw, ns)
  namespaceExport(ns, "d")
  #nocov end
}
