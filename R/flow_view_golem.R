flow_view_golem <- function(
  fun,
  max_depth = Inf,
  trim = NULL,
  promote = NULL,
  hide = NULL,
  show_imports = c("functions", "packages", "none"),
  out = NULL,
  lines = TRUE) {
  show_imports <- match.arg(show_imports)
  fun_sym <- substitute(fun)
  ns <- environment(fun) # not robust
  pkg <- namespace_name(ns)
  pkg_objs <- ls(ns)
  pkg_funs <- names(Filter(is.function, mget(pkg_objs, ns)))
  pkg_non_funs <- setdiff(pkg_objs, pkg_funs)
  module_funs <- grep("(_ui)|(_server)$", pkg_funs, value = TRUE)
  # this should be recursive
  calls_ui_or_server <- sapply(
    pkg_funs,
    \(x) any(grepl("(_ui)|(_server)$", all.names(body(getFromNamespace(x, pkg))))))
  new <- pkg_funs[calls_ui_or_server]
  new <- setdiff(new, module_funs)
  module_funs <- c(module_funs, new)
  while(length(new)) {
    new <- Filter(
      \(x) any(all.names(body(getFromNamespace(x, pkg))) %in% module_funs),
      pkg_funs)
    new <- setdiff(new, module_funs)
    module_funs <- c(module_funs, new)
  }
  demote <- paste0(pkg, ":::", c(setdiff(pkg_funs, module_funs), pkg_non_funs))

  eval.parent(bquote(
    flow_view_deps(
      .(fun_sym),
      .(max_depth),
      .(trim),
      .(promote),
      .(demote),
      .(hide),
      .(show_imports),
      .(out),
      .(lines))))
}
