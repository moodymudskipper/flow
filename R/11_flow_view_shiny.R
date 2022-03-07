#' Visualize a shiny app's dependency graph
#'
#' A wrapper around `flow_view_deps` which demotes every object that is not
#' a server function, a ui function or a function calling either. What is or isn't considered as a
#' server or ui function depends on a regular expression provided through the `pattern`
#' argument.
#'
#' @description
#' `r lifecycle::badge("experimental")`
#' @param fun The function that runs the app
#' @param pattern A regular expression used to detect ui and server functions
#' @inheritParams flow_view_deps
#' @export
#' @examples
#' if (requireNamespace("esquisse", quietly = TRUE)) {
#'   flow_view_shiny(esquisse::esquisser, show_imports = "none")
#' }
flow_view_shiny <- function(
  fun,
  max_depth = Inf,
  trim = NULL,
  promote = NULL,
  demote = NULL,
  hide = NULL,
  show_imports = c("functions", "packages", "none"),
  out = NULL,
  lines = TRUE,
  pattern = "(_ui)|(_server)|(Ui)|(Server)|(UI)|(SERVER)") {
  show_imports <- match.arg(show_imports)
  fun_sym <- substitute(fun)
  ns <- environment(fun) # not robust
  pkg <- namespace_name(ns)
  pkg_objs <- ls(ns)
  pkg_funs <- names(Filter(is.function, mget(pkg_objs, ns)))
  pkg_non_funs <- setdiff(pkg_objs, pkg_funs)
  module_funs <- grep(pattern, pkg_funs, value = TRUE)
  # this should be recursive
  calls_ui_or_server <- sapply(
    pkg_funs,
    function (x) any(grepl(pattern, all.names(body(getFromNamespace(x, pkg))))))
  new <- pkg_funs[calls_ui_or_server]
  new <- setdiff(new, module_funs)
  module_funs <- c(module_funs, new)
  while(length(new)) {
    new <- Filter(
      function (x) any(all.names(body(getFromNamespace(x, pkg))) %in% module_funs),
      pkg_funs)
    new <- setdiff(new, module_funs)
    module_funs <- c(module_funs, new)
  }
  auto_demote <- paste0(pkg, ":::", c(setdiff(pkg_funs, module_funs), pkg_non_funs))
  # not sure about it, we should at least namespace them first
  auto_demote <- setdiff(auto_demote, promote)
  demote <- c(auto_demote, demote)

  do.call(flow_view_deps, list(fun_sym, max_depth, trim, promote, demote, hide, show_imports, out, lines))
}
