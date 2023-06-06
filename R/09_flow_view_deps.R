#  TODO: max depth should be applied on min depth where fun is found, else inconsistent ouput
# as object can have several depths and here first found is taken

#' Show dependency graph of a function
#'
#' Exported objects are shown in blue, unexported objects are shown in yellow.
#'
#' Regular expressions can be used in `trim`, `promote`, `demote` and `hide`,
#' they will be used on function names in the form `pkg::fun` or `pkg:::fun`
#' where `pkg` can be any package mentioned in these arguments, the namespace
#' of the explored function, or any of the direct dependencies of the package.
#' These arguments must be named, using the name "pattern". See examples below.
#'
#' @description
#' `r lifecycle::badge("experimental")`
#' @param fun A function, can be of the form `fun`, `pkg::fun`, `pkg:::fun`,
#'   if in the form `fun`, the binding should be located in a package namespace
#'   or the global environment. It can also be a named list of functions, such as
#'   one you'd create with `dplyr::lst()`, for instance `lst(fun1, pkg::fun2)`.
#' @param max_depth An integer, the maximum depth to display
#' @param trim A vector or list of function names where the recursion will stop
#' @param promote A vector or list of external functions to show as internal functions
#' @param demote A vector or list of internal functions to show as external functions
#' @param hide A vector or list of internal functions to completely remove from the chart
#' @param show_imports Whether to show imported "functions", only "packages", or "none"
#' @param lines Whether to show the number of lines of code next to the function name
#' @param include_formals Whether to fetch dependencies in the default values of the
#'   function's arguments
#' @inheritParams flow_view
#' @return `flow_view_deps()` returns a `"flow_diagram"` object by default, and the output path invisibly if `out` is not
#' `NULL` (called for side effects).
#' @examples
#' flow_view_deps(here::i_am)
#' flow_view_deps(here::i_am, demote = "format_dr_here")
#' flow_view_deps(here::i_am, trim = "format_dr_here")
#' flow_view_deps(here::i_am, hide = "format_dr_here")
#' flow_view_deps(here::i_am, promote = "rprojroot::get_root_desc")
#' flow_view_deps(here::i_am, promote = c(pattern = ".*::g"))
#' flow_view_deps(here::i_am, promote = c(pattern = "rprojroot::.*"))
#' flow_view_deps(here::i_am, hide = c(pattern = "here:::s"))
#' @export
flow_view_deps <- function(
  fun,
  max_depth = Inf,
  trim = NULL,
  promote = NULL,
  demote = NULL,
  hide = NULL,
  show_imports = c("functions", "packages", "none"),
  out = NULL,
  lines = TRUE,
  include_formals = TRUE) {
  fun_lng <- substitute(fun)
  call_env <- parent.frame()

  if (is.list(fun)) {
    objs <- Map(flow_view_deps_df, names(fun), fun, MoreArgs = list(trim, promote, demote, hide, lines, default_env = call_env))
    objs <- do.call(rbind, objs)
    objs <- unique(objs)
  } else {
    target_fun_name <- deparse(fun_lng)
    nm <- raw_fun_name(fun_lng)
    # A data frame with all potentially relevant functions + info
    objs <- flow_view_deps_df(target_fun_name, fun, trim, promote, demote, hide, lines, default_env = call_env)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # initiate global objects

  show_imports <- match.arg(show_imports)

  nomnoml_setup <- c(
    "# direction: right",
    "#.expfun: visual=roundrect fill=#ddebf7 title=bold",
    "#.unexpfun: visual=roundrect fill=#fff2cc title=bold",
    "#.trimmed: visual=roundrect fill=#fce4d6 dashed title=bold",
    "#.expdata: visual=database fill=#e2efda title=bold",
    "#.unexpdata: visual=database fill=#fff2cc title=bold",
    "#.callroutine: visual=transceiver fill=#ededed"
  )
  nomnoml_data_rows <- list()

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # recurse
  # we don't pass around nomnoml_code and objs, we just edit it with `<<-`
  rec <- function(row, depth = 1, parent = NULL) {
    dependency_df <- get_dependency_df(row, objs, include_formals)
    # gather info from obs

    if(NROW(dependency_df)) {
      internal_ref_df <- subset(dependency_df, style != "external_reference")


      if(show_imports == "functions") {
        external_ref <- with(
          subset(dependency_df, style == "external_reference"),
          if(length(ns_nm)) paste0(ns_nm, ifelse(exported, "::", ":::"), quote_non_syntactic(nm))
          #header
        )
      } else if(show_imports == "packages") {
        external_ref <- with(
          subset(dependency_df, style == "external_reference"),
          if(length(ns_nm)) paste0("{", unique(ns_nm), "}"))
      } else {
        external_ref <- NULL
      }
    } else {
      internal_ref_df <- external_ref <- NULL
    }

    covered <- row$covered
    if(depth == max_depth && NROW(internal_ref_df) && !row$covered) {
      style   <- "trimmed"
      covered <- TRUE
    } else {
      style   <- row$style # funs$style[funs$nm == nm]
    }

    id <- paste(escape_pipes_and_brackets(c(row$header, external_ref)) , collapse = "|")
    new_nomnoml_code <- paste0("[<", style, "> ", id, "]")
    if(!is.null(parent)) {
      new_nomnoml_code <- paste0("[<", parent$style, "> ", parent$header, "] -> ", new_nomnoml_code)
    }

    nomnoml_data_rows[[length(nomnoml_data_rows) + 1]] <<- list(
      child_header = row$header,
      external_ref = external_ref,
      child_style = style,
      parent_header = parent$header %||% NA_character_,
      parent_style = parent$style %||% NA_character_,
      code = new_nomnoml_code
    )

    # update "covered status"
    row_ind <- objs$ns_nm == row$ns_nm & objs$nm == row$nm
    objs[row_ind, "covered"] <<- TRUE

    if(covered) return(NULL)

    if(NROW(internal_ref_df)) {
      for(i in seq(NROW(internal_ref_df))) {
        rec(internal_ref_df[i,, drop = FALSE], depth + 1, parent = row)
      }
    }
  }

  if (!is.list(fun)) {
    target_nm <- sub("^[^:]+[:]{2,3}`?([^`]+)`?", "\\1", target_fun_name)
    target_ns_nm <- namespace_name(target_fun_name, parent.frame())
    rec (objs[objs$nm == target_nm & objs$ns_nm == target_ns_nm,, drop = FALSE])
  } else {
    for (target_fun_name in names(fun)) {
      target_nm <- sub("^[^:]+[:]{2,3}`?([^`]+)`?", "\\1", target_fun_name)
      target_ns_nm <- namespace_name(target_fun_name, parent.frame())
      rec (objs[objs$nm == target_nm & objs$ns_nm == target_ns_nm,, drop = FALSE])
    }
  }

  nomnoml_data <- as.data.frame(do.call(rbind, nomnoml_data_rows))
  nomnoml_data$external_ref <- as.list(nomnoml_data$external_ref)
  if (identical(out, "data")) return(nomnoml_data)

  nomnoml_code <- paste(c(nomnoml_setup, nomnoml_data$code), collapse = "\n")
  if (identical(out, "code")) return(nomnoml_code)

  out <- save_nomnoml(nomnoml_code, out)
  if(inherits(out, "htmlwidget")) as_flow_diagram(out, data = nomnoml_data, code = nomnoml_code)  else invisible(out)
}

# A data frame containing all functions from all namespaces found in functions mentionned
# in target_fun_name,trim, promote, demote, hide
# ns_nm: namespace name
# nm: function name
# exported, is_function, is_call_routine
# style: a label for the style to apply with nomnoml (expfun, unexpfun etc)
# n_lines
# trim, promote, demote, hide,
# covered: whether we already defined the node
# in_target_ns: Whether the object is bound in the same
# header: the label of the node
flow_view_deps_df <- function(target_fun_name, target_fun, trim, promote, demote, hide, lines, default_env) {
  # make a data.frame with every fun from every namespace

  fallback_ns_nm <- namespace_name(target_fun_name, default_env)
  if(fallback_ns_nm == "R_GlobalEnv") {
    fallback_ns <- globalenv()
  } else {
    fallback_ns <- asNamespace(fallback_ns_nm)
  }
  edit0 <- list(trim = trim, promote = promote, demote = demote, hide = hide)
  patterns <- lapply(edit0, function(x) x[names(x) == "pattern"])
  edit <- lapply(edit0, function(x) if(is.null(names(x))) x else x[names(x) == ""])

  funs_raw <- unique(c(target_fun_name, unlist(edit)))
  namespaced_funs_lgl <- grepl("::", funs_raw)
  obj_names <- sub("^[^:]+[:]{2,3}`?([^`]+)`?", "\\1", funs_raw)
  namespaces <- sapply(funs_raw, namespace_name, default_env, fallback_ns, USE.NAMES = FALSE)

  all_pkgs <- unique(c(namespaces, deps(fallback_ns_nm)))
  objs <- do.call(
    rbind,
    lapply(all_pkgs, get_ns_obj_df, lines = lines)
  )
  edit_df <- data.frame(
    ns_nm = namespaces[-1],
    nm = obj_names[-1],
    edit = rep(names(edit), lengths(edit)),
    stringsAsFactors = FALSE
  )
  edit_df <- unique(edit_df)

  # combine info from namespaces and `edit`, then preprocess before recursion
  trim_df <- subset(edit_df, edit == "trim", select = c("ns_nm", "nm"))
  trim_df$trim <- TRUE[nrow(trim_df) > 0]
  promote_df <- subset(edit_df, edit == "promote", select = c("ns_nm", "nm"))
  promote_df$promote <- TRUE[nrow(promote_df) > 0]
  demote_df <- subset(edit_df, edit == "demote", select = c("ns_nm", "nm"))
  demote_df$demote <- TRUE[nrow(demote_df) > 0]
  hide_df <- subset(edit_df, edit == "hide", select = c("ns_nm", "nm"))
  hide_df$hide <- TRUE[nrow(hide_df) > 0]
  objs <- merge(objs, trim_df, all.x = TRUE)
  objs <- merge(objs, promote_df, all.x = TRUE)
  objs <- merge(objs, demote_df, all.x = TRUE)
  objs <- merge(objs, hide_df, all.x = TRUE)
  objs$trim    <- !is.na(objs$trim)
  objs$promote <- !is.na(objs$promote)
  objs$demote  <- !is.na(objs$demote)
  objs$hide    <- !is.na(objs$hide)

  full_nms <- sprintf("%s%s%s", objs$ns_nm, ifelse(startsWith(objs$style, "unexp"), ":::", "::"), objs$nm)
  for (pattern in patterns$trim) {
    objs$trim <- objs$trim | grepl(pattern, full_nms) &
      !objs$promote & !objs$demote & !objs$hide
  }
  for (pattern in patterns$promote) {
    objs$promote <- objs$promote | grepl(pattern, full_nms) &
      !objs$trim & !objs$demote & !objs$hide
  }
  for (pattern in patterns$demote) {
    objs$demote <- objs$demote | grepl(pattern, full_nms) &
      !objs$trim & !objs$promote & !objs$hide
  }
  for (pattern in patterns$hide) {
    objs$hide <- objs$hide | grepl(pattern, full_nms) &
      !objs$trim & !objs$promote & !objs$demote
  }

  objs$covered <- objs$trim

  objs$in_target_ns <- objs$ns_nm == fallback_ns_nm
  objs$style[objs$trim] <- "trimmed"
  objs$style[objs$is_call_routine] <- "callroutine"
  objs$style[!objs$in_target_ns &!objs$promote] <- "external_reference"
  objs$style[objs$in_target_ns & objs$demote] <- "external_reference"
  objs$style[objs$hide] <- "hide"
  objs$header <- with(objs, ifelse(
    in_target_ns,
    nm,
    paste0(ns_nm, ifelse(exported, "::", ":::"), quote_non_syntactic(nm)))
  )
  if(lines) {
    objs$header <- ifelse(objs$n_lines == 0, objs$nm, paste0(objs$header, " (", objs$n_lines,")"))
  }

  objs
}

deps <- function(pkg) {
  desc <- read.dcf(system.file("DESCRIPTION", package = pkg))
  desc <- desc[,intersect(c("Imports", "Depends"), colnames(desc))]
  setdiff(trimws(unique(unlist(
    strsplit(gsub("\\(.*?\\)", "", desc), "\\s?,\\s?")
  ))), c("R", NA))
}

get_ns_obj_df <- function(ns_nm, lines) {
  if (ns_nm == "R_GlobalEnv") {
    ns <- globalenv()
  } else {
    ns <- asNamespace(ns_nm)
  }

  objs <- data.frame(
    ns_nm = ns_nm,
    nm = ls(ns),
    stringsAsFactors = FALSE)

  # FIXME: this ignores functions built in .onLoad and .onAttach
  objs$exported <- objs$nm %in% get_namespace_exports(ns)
  objs$is_function <- sapply(objs$nm, function(nm) is.function(ns[[nm]]))
  objs$is_call_routine <- sapply(objs$nm, function(nm) inherits(ns[[nm]], "CallRoutine"))
  objs$style <- with(objs, ifelse(
    exported,
    ifelse(is_function, "expfun", "expdata"),
    ifelse(is_function, "unexpfun", "unexpdata")))

  n_lines <- sapply(objs$nm, function(x) {length(deparse(ns[[x]]))})
  n_lines <- pmax(1, n_lines-3) # so we only count actual body content if brackets
  objs$n_lines <- ifelse(objs$is_function, n_lines, 0)
  objs
}

get_dependency_df <- function(row, objs, include_formals) {
  ns_nm <- hide <- NULL # for notes
  if(row$ns_nm == "R_GlobalEnv") {
    obj <- get(row$nm, globalenv())
  } else {
    obj <- getFromNamespace(row$nm, row$ns_nm)
  }
  if(!is.function(obj)) return(NULL)
  namespaced_objs_df <- get_namespaced_objs_df(obj, include_formals)
  short_objs_df <- get_short_objs_df(obj, include_formals)
  dependency_df <- unique(rbind(namespaced_objs_df, short_objs_df))
  dependency_df <- subset(dependency_df, ns_nm != "base" & ns_nm != "")
  dependency_df <- merge(dependency_df, objs, all.x = TRUE)
  dependency_df$hide[is.na(dependency_df$hide)] <- FALSE
  dependency_df <- subset(dependency_df, !hide)
  dependency_df$style[is.na(dependency_df$style)] <- "external_reference"
  dependency_df$exported[is.na(dependency_df$exported)] <- TRUE
  dependency_df
}

get_namespaced_objs_df <- function(obj, include_formals) {
  call <- body(obj)
  extract_namespaced_objs_impl <- function(call) {
    if(!is.call(call)) return(NULL)
    if(length(call) == 3 && (
      identical(call[[1]], quote(`::`)) ||
      identical(call[[1]], quote(`:::`))
    )) {
      return(call)
    }
    lapply(call, extract_namespaced_objs_impl)
  }
  calls <- extract_namespaced_objs_impl(call)
  if (include_formals) {
    calls_from_fmls <- lapply(formals(obj), extract_namespaced_objs_impl)
    calls <- c(calls, calls_from_fmls)
  }
  calls <- unlist(calls)
  do.call(rbind, lapply(calls, function (x) data.frame(
    ns_nm = as.character(x[[2]]),
    nm = as.character(x[[3]]),
    stringsAsFactors = FALSE)))
}

get_short_objs_df <- function(obj, include_formals) {
  body_ <- remove_namespaced_calls(body(obj))
  all_nms <- all.names(body_)
  if (include_formals) {
    fmls <- lapply(formals(obj), remove_namespaced_calls)
    all_nms <- unique(unlist(c(all_nms, lapply(fmls, all.names))))
  }
  objs <- setdiff(all_nms, c(formalArgs(obj), extract_assignment_targets(body_)))
  namespaces <- sapply(objs, namespace_name, environment(obj), fail_if_not_found = FALSE)
  # NA namespaces are false positives, symbols found in NSE expressions
  # FIXME: We could at least ignore rhs of $ for those because if we have lhs$rhs
  #        at the moment if rhs exists in package but is not used it will still be referenced
  data.frame(
    ns_nm = namespaces[!is.na(namespaces)],
    nm = objs[!is.na(namespaces)],
    stringsAsFactors = FALSE
  )
}

remove_namespaced_calls <- function(call) {
  if(!is.call(call)) return(call)
  if(length(call) == 3 && (
    identical(call[[1]], quote(`::`)) ||
    identical(call[[1]], quote(`:::`))
  )) {
    return(NULL)
  }
  as.call(lapply(call, remove_namespaced_calls))
}

extract_namespaced_calls <- function(call) {
  extract_namespaced_calls_impl <- function(call) {
  if(!is.call(call)) return(NULL)
  if(length(call) == 3 && (
    identical(call[[1]], quote(`::`)) ||
    identical(call[[1]], quote(`:::`))
  )) {
    return(call)
  }
  lapply(call, extract_namespaced_calls_impl)
  }
  calls <- extract_namespaced_calls_impl(call)
  calls <- unlist(calls)
  vapply(calls, deparse, character(1))
}

extract_assignment_targets <- function(call) {
  extract_assignment_targets_impl <- function(call) {
    if(!is.call(call)) return(NULL)
    if(length(call) == 3 && (
      identical(call[[1]], quote(`<-`)) ||
      identical(call[[1]], quote(`=`))
    )) {
      if(!is.symbol(call[[2]])) call[2] <- list(NULL)
      return(c(call[[2]], extract_assignment_targets_impl(call[[3]])))
    }
    lapply(call, extract_assignment_targets_impl)
  }
  calls <- extract_assignment_targets_impl(call)
  calls <- unlist(calls)
  vapply(calls, deparse, character(1))
}
