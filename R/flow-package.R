#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom lifecycle deprecated
## usethis namespace: end
NULL

# nomnoml is called only through htmlwidgets::createWidget
# to pass tests on old ubuntu releases we need to call at least a function once,
# hence the following line
nomnoml::nomnoml
