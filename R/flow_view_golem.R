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
  module_funs <- grep("(_ui)|(_server)$", pkg_objs, value = TRUE)
  # this should be recursive
  calls_ui_or_server <- sapply(
    pkg_objs,
    \(x) any(grepl("(_ui)|(_server)$", all.names(body(getFromNamespace(x, pkg))))))
  new <- pkg_objs[calls_ui_or_server]
  new <- setdiff(new, module_funs)
  module_funs <- c(module_funs, new)
  while(length(new)) {
    new <- Filter(
      \(x) any(all.names(body(getFromNamespace(x, pkg))) %in% module_funs),
      pkg_objs)
    new <- setdiff(new, module_funs)
    module_funs <- c(module_funs, new)
  }
  demote <- paste0(pkg, ":::", setdiff(pkg_objs, module_funs))

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
