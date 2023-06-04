#' Show graph of callers of a function
#'
#' Experimental function that displays for a given object or function all functions
#' that call it directly or indirectly.
#'
#' The function is not very robust yet, but already useful for many usecases.
#'
#' @param x An object
#' @param pkg A package or environment to fetch callers from, by default `fun`'s environment
#' @inheritParams flow_view
#'
#' @return `flow_view_uses()` returns a `"flow_diagram"` object by default, and the output path invisibly if `out` is not
#' `NULL` (called for side effects).
#' @export
#'
#' @examples
#' flow_view_uses(flow_run)
flow_view_uses <- function(x, pkg = NULL, out = NULL) {
  nm <- deparse(substitute(x))
  # FIXME: undocumented and unfinished
  if (is.list(x)) {
    nm <- names(x)
  } else if (is.character(x)) {
    nm <- x
  }
  if (is.null(pkg)) {
    env <- topenv(environment(x))
  } else if (is.character(pkg)) {
    env <- asNamespace(pkg)
  } else {
    env <- environment(x)
  }
  nm <- sapply(parse(text=nm), raw_fun_name)
  env_lst <- as.list(env)
  env_lst <- Filter(is.function, env_lst)
  all_nms <- names(env_lst)
  data <- Map(all_nms, env_lst, f = function(nm, val) {
    body <- body(val)
    all_nms <- all.vars(body, functions = TRUE)
    if (!length(all_nms)) return(NULL)
    # FIXME: optionally include formals
    data.frame(fun = nm, vars = all_nms)
  })
  data <- do.call(rbind, data)
  row.names(data) <- NULL

  rec <- function(nm) {
    splt <- split(data, data$vars %in% nm)
    used_data <- splt[["TRUE"]]
    data <<- splt[["FALSE"]]
    parents <- unique(used_data$fun)
    new_data <- lapply(parents, rec)
    c(list(used_data),do.call(c, new_data))
  }
  data <- do.call(rbind, rec(nm))
  data$style1 <- data$style2 <- "unexpfun"
  if (isNamespace(env)) {
    exports <- getNamespaceExports(env)
    data$style1[data$fun %in% exports] <- "expfun"
    data$style2[data$vars %in% exports] <- "expfun"
  }

  data$code <- sprintf("[<%s> %s] -> [<%s> %s]", data$style1, data$fun, data$style2, data$vars)
  row.names(data) <- NULL

  if (identical(out, "data")) return(data)

  nomnoml_setup <- c(
    "# direction: right",
    "#.expfun: visual=roundrect fill=#ddebf7 title=bold",
    "#.unexpfun: visual=roundrect fill=#fff2cc title=bold",
    "#.trimmed: visual=roundrect fill=#fce4d6 dashed title=bold",
    "#.expdata: visual=database fill=#e2efda title=bold",
    "#.unexpdata: visual=database fill=#fff2cc title=bold",
    "#.callroutine: visual=transceiver fill=#ededed"
  )
  nomnoml_code <- paste(c(nomnoml_setup, data$code), collapse = "\n")
  if (identical(out, "code")) return(nomnoml_code)

  svg <- is.null(out) || endsWith(out, ".html") || endsWith(out, ".htm")
  out <- save_nomnoml(nomnoml_code, out)
  if(inherits(out, "htmlwidget")) as_flow_diagram(out, data = data, code = nomnoml_code)  else invisible(out)
}
