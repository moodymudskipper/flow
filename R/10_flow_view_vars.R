globalVariables(c("lhs", "rhs"))


#' Draw the dependencies of variables in a function
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This draws the dependencies between variables. This function
#' is useful to detect dead code and variable clusters. By default the variable
#' is shown a new time when it's overwritten or modified, this can be changed by
#' setting `expand` to `FALSE`.
#'
#' @details
#' Colors and lines are to be understood as follows:
#' * The function is blue
#' * The arguments are green
#' * The variables starting as constants are yellow
#' * The dead code or pure side effect branches are orange and dashed
#' * dashed lines represent how variables are undirectly impacted by control flow conditions,
#'  for instance the expression `if(z == 1) x <- y` would give you a full arrow
#'  from `y` to `x` and a dashed arrow from `z` to `x`
#'
#' `expand = TRUE` gives a sense of the chronology, and keep separate the
#'  unrelated uses of temp variables. `expand = FALSE` is more compact and shows
#'  you directly what variables might impact a given variable, and what variables
#'  it impacts.
#'
#' This function will work best if the function doesn't draw from or assign to other
#' environments and doesn't use `assign()` or `attach()`. The output might
#' be polluted by variable names found in some lazily evaluated function arguments.
#' We ignore variable names found in calls to `quote()` and `~` as well as
#' nested function definitions, but complete robustness is probably impossible.
#'
#' The diagram assumes that for / while / repeat loops were at least run once,
#' if a value is modified in a branch of an if call (or both branches) and
#' `expand` is `TRUE`, the modified variable(s) will point to a new one at the
#' end of the `ìf` call.
#' @param x The function, script or expression to draw
#' @param expand A boolean, if `FALSE` a variable name is only shown once, else
#'   (the default) it's repeated and suffixed with a number of `*`
#' @param refactor If using 'refactor' package, whether to consider original or refactored code
#' @inheritParams flow_view
#'
#' @return Called for side effects
#' @export
#' @examples
#' flow_view_vars(ave)
flow_view_vars <- function(x, expand = TRUE, refactor = c("refactored", "original"), out = NULL) {
  refactor <- match.arg(refactor)

  # build fun ------------------------------------------------------------------
  fun <- flow_view_vars..build_fun(x, substitute(x), parent.frame())

  # clean body to mitigate lazy eval pollution ---------------------------------
  clean_body <- flow_view_vars..clean_body(fun$body, refactor)

  # have body of function wrapped in {} ----------------------------------------
  clean_body <- flow_view_vars..wrap_body(clean_body)

  # build and call recursive fun to fetch dependencies -------------------------
  var_deps <- flow_view_vars..fetch_var_deps(clean_body, fun$name, fun$args)

  # format dependencies into a data frame containing graph and metadata --------
  df <- flow_view_vars..format_deps(var_deps, fun$name, fun$args, expand)

  # return the data frame, not documented at the moment ------------------------
  if(identical(out, "data")) {
    return(df)
  }

  # build nomnoml code ---------------------------------------------------------
  nomnoml_code <- flow_view_vars..build_nomnoml_code(df,  fun$name, fun$args)

  # output ---------------------------------------------------------------------
  svg <- is.null(out) || endsWith(out, ".html") || endsWith(out,".html")
  out <- save_nomnoml(nomnoml_code, svg, out)
  if(inherits(out, "htmlwidget")) out else invisible(out)
}

flow_view_vars..build_fun <- function(x, x_lng, env) {
  name <- deparse1(x_lng)
  if(is.language(x)) {
    value <- as.function(list(x), envir = env)
    name <- "expression"
    fun_body <- x
    args <- NULL
  } else if(is.character(x)) {
    fun_body <- as.call(c(quote(`{`), parse(file = x)))
    fun <- as.function(list(fun_body), envir = env)
    name <- "script"
    args <- NULL
  } else {
    fun <- x
    fun_body <- body(fun)
    args <- formalArgs(fun)
  }
  list(fun = fun, name = name, body = fun_body, args = args)
}

flow_view_vars..clean_body <- function(call, refactor) {
  # clean up code from calls to `quote`, `~`, `function`, and the unobserved side of
  # `{refactor}` functions.
  if(!is.call(call)) return(call)
  if(deparse1(call[[1]]) %in% c("quote", "~", "function")) {
    return(NULL)
  }
  if(deparse1(call[[1]]) %in% c(
    "%refactor%", "%refactor_chunk%", "%refactor_value%",
    "%refactor_chunk_and_value%", "%refactor_chunk_efficiently%",
    "%refactor_value_efficiently%", "%refactor_chunk_and_value_efficiently%",
    "%ignore_original%", "%ignore_refactored%"
  )) {
    if(refactor == "refactored") call[2] <- list(NULL) else call[3] <- list(NULL)
  }
  as.call(lapply(call, flow_view_vars..clean_body))
}

flow_view_vars..wrap_body <- function(clean_body) {
  if(!is.call(clean_body) || !identical(clean_body[[1]], quote(`{`)))
    clean_body <- call("{", clean_body)
  clean_body[[length(clean_body)]] <- call("<-", "*OUT*", clean_body[[length(clean_body)]])
  clean_body
}

flow_view_vars..fetch_var_deps <- function(clean_body, fun_name, args) {

  return_i <- 0
  defs <- local_defs <- setNames(rep(1, length(args)), args)
  fetch_var_deps <- function(call, add_vars = NULL) {

    if(!is.call(call)) return(NULL)
    fun_name <- deparse1(call[[1]])
    if(fun_name == "for") {
      add_vars <- unique(c(add_vars, all.names(call[[2]]), all.names(call[[3]])))
      add_vars <- intersect(add_vars, names(defs))
      return(fetch_var_deps(call[[4]], add_vars))
    }

    if(fun_name == "while") {
      add_vars <- unique(c(add_vars, all.names(call[[2]])))
      add_vars <- intersect(add_vars, names(defs))
      return(fetch_var_deps(call[[3]], add_vars))
    }

    if(fun_name == "if") {

      # need to handle cases without else,

      local_defs_start_bkp <- local_defs
      add_vars <- unique(c(add_vars, all.names(call[[2]])))
      add_vars <- intersect(add_vars, names(defs))
      if_res <- fetch_var_deps(call[[3]], add_vars)
      local_defs_end_bkp1 <- local_defs


      if(length(call) == 3) {
        common_nms <- intersect(names(local_defs_end_bkp1), names(local_defs_start_bkp))
        common_nms_changed <- common_nms[local_defs_end_bkp1[common_nms] != local_defs_start_bkp[common_nms]]
        if(length(common_nms_changed)) {
          new_stars <- pmax(
            local_defs_end_bkp1[common_nms_changed],
            local_defs_start_bkp[common_nms_changed])
          new_nms  <- paste0(common_nms_changed, strrep("*", new_stars))
          old_nms1 <- paste0(common_nms_changed, strrep("*", local_defs_end_bkp1[common_nms_changed]-1))
          old_nms2 <- paste0(common_nms_changed, strrep("*", local_defs_start_bkp[common_nms_changed]-1))
          new_calls <- mapply(call, rep(new_nms, 2) , c(old_nms1, old_nms2), action = "write", USE.NAMES = FALSE)
          defs[common_nms_changed] <<- defs[common_nms_changed] + 1
        } else {
          new_calls <- NULL
        }
        local_defs <<- defs
        return(c(if_res, new_calls))

      } else {
        local_defs <<- local_defs_start_bkp
        else_res <- fetch_var_deps(call[[4]], add_vars)

        local_defs_end_bkp2 <- local_defs
        common_nms <- intersect(names(local_defs_end_bkp1), names(local_defs_end_bkp2))
        common_nms_changed <- common_nms[local_defs_end_bkp1[common_nms] != local_defs_end_bkp2[common_nms]]
        if(length(common_nms_changed)) {
          new_stars <- pmax(
            local_defs_end_bkp1[common_nms_changed],
            local_defs_end_bkp2[common_nms_changed])
          new_nms  <- paste0(common_nms_changed, strrep("*", new_stars))
          old_nms1 <- paste0(common_nms_changed, strrep("*", local_defs_end_bkp1[common_nms_changed]-1))
          old_nms2 <- paste0(common_nms_changed, strrep("*", local_defs_end_bkp2[common_nms_changed]-1))
          new_calls <- mapply(call, rep(new_nms, 2) , c(old_nms1, old_nms2), action = "write", USE.NAMES = FALSE)
          defs[common_nms_changed] <<- defs[common_nms_changed] + 1
        } else {
          new_calls <- NULL
        }
        local_defs <<- defs
        return(c(if_res, else_res, new_calls))
      }
    }

    if(fun_name == "return") {
      if(length(call) == 1) call <- quote(return(NULL))
      return_i <<- return_i + 1
      call <- call("<-", sprintf("*OUT%s*", return_i), call[[2]])
      return(fetch_var_deps(call, add_vars))
    }

    if (fun_name %in% c("<-", "=")) {
      # RHS
      rhs <- call[[3]]
      rhs_nms <- intersect(all.names(rhs), names(local_defs))
      if(length(rhs_nms)) {
        rhs_nms_bkp <- rhs_nms
        rhs_nms <- paste0(rhs_nms, strrep("*", local_defs[rhs_nms]-1))
        rhs_nms_no_dots <- setdiff(rhs_nms, "...")
        subst_list <- setNames(
          lapply(rhs_nms_no_dots, as.name),
          setdiff(rhs_nms_bkp, "...")
        )
        rhs <- do.call(substitute, list(rhs, subst_list))
      }

      # LHS
      lhs <- call[[2]]
      action <- "write"
      while(is.call(lhs)) {
        action <- "edit"
        lhs <- lhs[[2]]
      }
      lhs <- as.character(lhs)
      if(!lhs %in% names(defs)) {
        defs[[lhs]] <<- 1
      } else {
        defs[[lhs]] <<- defs[[lhs]] + 1
      }

      if(!lhs %in% names(local_defs)) {
        local_defs[[lhs]] <<- 1
      } else {
        local_defs[[lhs]] <<- local_defs[[lhs]] + 1
      }

      # taking the previous star is wrong, if we're at the first mod on an else branch we want to take the backup
      if(action == "edit") rhs_nms <- c(rhs_nms,  paste0(lhs, strrep("*", local_defs[[lhs]]-2)))

      if(!length(rhs_nms)) rhs_nms <- "*CONSTANT*"
      # after this data is modified we must update the local defs so future rhs will have correct stars
      local_defs[[lhs]] <<- defs[[lhs]]
      lhs <- paste0(lhs, strrep("*", defs[[lhs]]-1))

      # hide result in call so it's not vulnerable to unlist
      # here we might consider the add_vars separately so we can define a different
      # link when a variable is used in parent control flow rather than as a direct input
      res <- call(lhs, rhs_nms, add_vars = add_vars, action = action)

      c(res, fetch_var_deps(rhs, add_vars))
    } else {
      unlist(lapply(call, fetch_var_deps, add_vars))
    }
  }

  fetch_var_deps(clean_body)
}

flow_view_vars..format_deps <- function(var_deps, fun_name, fun_args, expand) {

  dfs <- lapply(var_deps, function(call) {
    lhs <- as.character(call[[1]])
    rhs <- call[[2]]
    add_vars <- setdiff(call$add_vars, rhs)
    action <- call$action

    df_direct <- data.frame(
      lhs = lhs,
      rhs = rhs,
      action = action,
      link = "direct",
      stringsAsFactors = FALSE)

    if(length(add_vars)) {
      df_cf <- data.frame(
        lhs = lhs,
        rhs = add_vars,
        action = action,
        link = "cf")
    } else {
      df_cf <- NULL
    }
    rbind(df_direct, df_cf)
  })

  df <- do.call(rbind, dfs)

  # add link between function name and args to df ------------------------------

  df0 <-if(length(fun_args))
    data.frame(lhs = fun_args, rhs = fun_name, link = "args", action = "args", stringsAsFactors = FALSE)
  df <- rbind(
    df0,
    df
  )

  # collapse starred variable if not `expand` ----------------------------------

  if(!expand) {
    df$lhs <- gsub("^([^*]+)\\*+", "\\1", df$lhs)
    df$rhs <- gsub("^([^*]+)\\*+", "\\1", df$rhs)
    df <- unique(df)
    df <- subset(df, lhs != rhs)
  }

  df
}


flow_view_vars..build_nomnoml_code <- function(df, fun_name, fun_args) {
  nomnoml_code <- "
# direction: down
#.fun: visual=roundrect fill=#ddebf7 title=bold
#.arg: visual=roundrect fill=#e2efda title=bold
#.var: visual=roundrect fill=#f0f0f0 title=bold
#.newvar: visual=roundrect fill=#fff2cc title=bold
#.return: visual=end fill=#70ad47  empty
#.deadcode: visual=roundrect fill=#fce4d6 dashed title=bold
"

  arrow <- ifelse(df$link == "cf",  "-->", "->")
  arrow[df$rhs == "*CONSTANT*"] <- ""

  df$lhs <- paste0(
    "[<",
    ifelse(
      grepl("^\\*OUT\\d*\\*$", df$lhs), "return",
      ifelse(df$lhs %in% fun_args, "arg",
             ifelse(df$rhs == "*CONSTANT*", "newvar",
                    ifelse(!df$lhs %in% df$rhs, "deadcode","var")))),
    "> ",
    df$lhs,
    "]"
  )

  df$rhs <- paste0(
    "[<",
    ifelse(
      df$rhs == fun_name, "fun",
      ifelse(df$rhs %in% fun_args, "arg", "var")),
    "> ",
    df$rhs,
    "]"
  )

  df$rhs[arrow == ""] <- ""

  nomnoml_code <- paste0(
    nomnoml_code,
    paste(df$rhs, arrow, df$lhs, collapse = "\n")
  )
  #cat(nomnoml_code)
  nomnoml_code
}
