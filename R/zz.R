.onLoad <- function(libname, pkgname) {
  ns <- asNamespace(pkgname)
  makeActiveBinding("d", flow_draw, ns)
  namespaceExport(ns, "d")
}
