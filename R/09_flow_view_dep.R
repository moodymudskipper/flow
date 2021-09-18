get_namespace_exports <- function(ns) {
  current_pkg <- sub("^Package: (.*)$", "\\1", readLines("DESCRIPTION")[[1]])
  if(is.environment(ns)) ns <- sub("^namespace:", "", environmentName(ns))
  if(ns != current_pkg) return(getNamespaceExports(ns))
  ns_lines <- readLines("NAMESPACE")
  pattern <- "^export\\((.*)\\)$"
  sub(pattern, "\\1", ns_lines)[grepl(pattern, ns_lines)]
}

is_namespaced <- function(call) {
  is.call(call) &&
    length(call) == 3 &&
    deparse1(call[[1]]) %in% c("::", ":::")
}

raw_fun_name <- function(call) {
  if(is_namespaced(call)) call <- call[[3]]
  if(length(call) > 1) stop("invalid name")
  as.character(call)
}

#  TODO: if argument is named foo, variable foo should be discarded as potential ns::foo object
#  same if we find `foo <-` of `foo =`

#  TODO: max depth should be applied on min depth where fun is found, else inconsistent ouput
# as object can have several depths and here first found is taken

#' Show dependency tree of a function
#'
#' @param fun A function
#' @param max_depth An integer, the maximum depth to display
#' @param trim A vector of list of function names where the recursion will stop
#' @param show_imports Whether to show imported functions, only packages, or neither.
#' @inheritParams flow_view
#' @export
flow_view_deps <- function(
  fun, max_depth = Inf, trim = NULL, show_imports = c("functions", "packages", "none"), out = NULL) {
  nm <- raw_fun_name(substitute(fun))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # initiate global objects

  show_imports <- match.arg(show_imports)
  # in all rigor we'll have to look above until we find a namespace
  # because some manufactured functions will have their env be a child of the namespace
  ns <- environment(fun)
  ns_nm <- sub("package:","", environmentName(ns))
  funs <- data.frame(nm = ls(ns))
  funs$covered <- funs$nm %in% trim
  funs$exported <- funs$nm %in% get_namespace_exports(ns)
  funs$is_function <- sapply(funs$nm, function(nm) is.function(ns[[nm]]))
  funs$is_call_routine <- sapply(funs$nm, function(nm) inherits(ns[[nm]], "CallRoutine"))
  funs$style <- with(funs, ifelse(
    exported,
    ifelse(is_function, "expfun", "expdata"),
    ifelse(is_function, "unexpfun", "unexpdata")))
  funs$style[funs$covered] <- "trimmed"
  funs$style[funs$is_call_routine] <- "callroutine"
  nomnoml_code <- "
# direction: right
#.expfun: visual=roundrect fill=#ddebf7 title=bold
#.unexpfun: visual=roundrect fill=#fff2cc title=bold
#.trimmed: visual=roundrect fill=#fce4d6 dashed title=bold
#.expdata: visual=database fill=#e2efda title=bold
#.unexpdata: visual=database fill=#fff2cc title=bold
#.callroutine: visual=transceiver fill=#ededed
"

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # recurse

  rec <- function(nm, depth = 1, parent = NULL) {
    # browser()
    # if(nm == "funs") browser()
    fun <- ns[[nm]]
    if(is.function(fun)) {
      deps_nms <- unique(all.names(body(fun)))
      # remove argument names as these would override function def
      deps_nms <- setdiff(deps_nms, formalArgs(fun))

      deps <- subset(funs, nm %in% deps_nms)
    } else {
      deps <- data.frame()
    }

    if(show_imports == "functions") {
      imported <- get_imported_funs(nm, ns, ns_nm)
    } else if(show_imports == "packages") {
      imported <- get_imported_pkgs(nm, ns, ns_nm)
    } else {
      imported <- NULL
    }

    covered <- funs$covered[funs$nm == nm]
    if(depth == max_depth && nrow(deps) && !covered) {
      style   <- "trimmed"
      covered <- TRUE
    } else {
      style   <- funs$style[funs$nm == nm]
    }
    new_nomnoml_code <- paste0(
      "[<", style, "> ",
      paste(c(nm, imported), collapse = "|"), #paste_imported_ns(nm, ns, ns_nm, hide_core = hide_core),
      "]")
    if(!is.null(parent)) {
      parent_style <- funs$style[funs$nm == parent]
      new_nomnoml_code <- paste0("[<", parent_style, "> ", parent, "] -> ", new_nomnoml_code)
    }
    nomnoml_code <<- paste0(nomnoml_code, "\n", new_nomnoml_code)

    funs$covered[funs$nm == nm] <<- TRUE
    if(covered) return(NULL)




    if(nrow(deps)) {
      for(dep in deps$nm) {
        rec(dep, depth + 1, parent = nm)
      }
    }
  }

  rec (nm)

  svg <- is.null(out) || endsWith(out, ".html") || endsWith(out,".html")
  out <- save_nomnoml(nomnoml_code, svg, out)
  if(inherits(out, "htmlwidget")) out else invisible(out)
}

get_imported_funs <- function(nm, ns, ns_nm) {
  fun <- ns[[nm]]
  if(!is.function(fun)) return(NULL)
  body_chr <- deparse(body(fun))
  pattern <- "[._a-zA-Z1-9]+\\:\\:\\:?[._a-zA-Z1-9]+"
  namespaced_call_lines <- grep(pattern, body_chr, value = TRUE)
  namespaced_calls1 <- mapply(
    function(x, matches) {
      unlist(sapply(seq_along(matches),
                    function(i) substr(x, matches[[i]], matches[[i]] + attr(matches, "match.length")[[i]] - 1)))
    },
    namespaced_call_lines,
    gregexpr(pattern, namespaced_call_lines),
    USE.NAMES = FALSE)
  namespaced_calls1 <- unique(unlist(namespaced_calls1))
  if(length(namespaced_calls1))
    namespaced_calls1 <- namespaced_calls1[
      !startsWith(namespaced_calls1, paste0(ns_nm, "::")) &&
      !startsWith(namespaced_calls1, "base::")]

  # remove namespaced call for next step
  body_chr <- gsub("[._a-zA-Z1-9]+\\:\\:[._a-zA-Z1-9]+", "`**`", body_chr)
  body_ <- parse(text = body_chr)[[1]]
  funs <- setdiff(all.names(body_), formalArgs(fun))
  namespaces <- sapply(
    funs,
    function(x) environmentName(environment(get0(x, ns))),
    USE.NAMES = FALSE)
  namespaced_calls2 <- ifelse(namespaces %in% c("", ns_nm, "base"), "", paste0(namespaces, "::", funs))
  # TODO: start with base packages
  sort(setdiff(unique(c(namespaced_calls1, namespaced_calls2)), ""))
}

get_imported_pkgs <- function(nm, ns, ns_nm) {
  funs <- get_imported_funs(nm, ns, ns_nm)
  if(!length(funs)) return(NULL)
  paste0("{",unique(sapply(strsplit(funs, ":::?"), `[[`, 1)), "}")
}
