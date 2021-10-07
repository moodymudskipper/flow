#' Draw the dependencies of variables in a functiomn
#'
#' Experimental, and probably can never been made 100% robust
#' @param fun The function to draw
#'
#' @return Called for side effects
#' @export
flow_view_vars <- function(fun) {

  fun_chr <- deparse1(substitute(fun))
  body_ <- body(fun)
  if(!is.call(body_) || !identical(body_[[1]], quote(`{`)))
    body_ <- call("{", body_) #as.call(c(quote(`{`), body_))
  body_[[length(body_)]] <- call("<-", "*OUT*", body_[[length(body_)]])


  return_i <- 0
  fetch_var_deps <- function(call, add_vars = NULL) {
    if(!is.call(call)) return(NULL)
    fun <- deparse1(call[[1]])
    if(fun == "for") {
      add_vars <- unique(c(add_vars, all.names(call[[2]]), all.names(call[[3]])))
      return(fetch_var_deps(call[[4]], add_vars))
    }

    if(fun == "while") {
      add_vars <- unique(c(add_vars, all.names(call[[2]])))
      return(fetch_var_deps(call[[3]], add_vars))
    }

    if(fun == "if") {
      add_vars <- unique(c(add_vars, all.names(call[[2]])))
      if_res <- fetch_var_deps(call[[3]], add_vars)
      else_res <- if(length(call) == 4) fetch_var_deps(call[[4]], add_vars)
      return(c(if_res, else_res))
    }

    if(fun == "return") {
      return_i <<- return_i + 1
      call <- call("<-", sprintf("*OUT%s*", return_i), call[[2]])
      return(fetch_var_deps(call, add_vars))
    }

    if (fun %in% c("<-", "=")) {
      lhs <- call[[2]]
      rhs <- call[[3]]

      while(is.call(lhs)) lhs <- lhs[[2]]
      # hide result in call so it's not vulnerable to unlist
      # here we might consider the add_vars separately so we can define a different
      # link when a variable is used in parent control flow rather than as a direct input
      res <- call(as.character(lhs), all.names(rhs), add_vars)
      c(res, fetch_var_deps(rhs, add_vars))
    } else {
      unlist(lapply(call, fetch_var_deps, add_vars))
    }
  }


  var_deps <- fetch_var_deps(body_)
  dfs <- lapply(var_deps, function(call) {
    lhs <- as.character(call[[1]])
    rhs <- call[[2]]
    add_vars <- call[[3]]
    df_direct <- if(length(rhs)) data.frame(lhs, rhs, link = "direct")
    df_cf     <- if(length(add_vars)) data.frame(lhs, rhs = add_vars, link = "cf")
    rbind(df_direct, df_cf)
  })
  df <- do.call(rbind, dfs)
  # reorder so we have "cf" coming after "direct" and full lines have priority over dashed
  df <- df[order(-xtfrm(df$link)),]
  args <- formalArgs(fun)
  df <- subset(df, lhs != rhs & rhs %in% c(lhs, args))
  df <- rbind(
    data.frame(lhs = args, rhs = fun_chr, link = "args"),
    df
  )
  df <- unique(df)
  nomnoml_code <- "
# direction: right
#.arg: visual=roundrect fill=#ddebf7 title=bold
#.var: visual=roundrect fill=#fff2cc title=bold
#.return: visual=end fill=#70ad47  empty
#.deadcode: visual=roundrect fill=#fce4d6 dashed title=bold
"

  df$lhs <- paste0(
    "[<",
    ifelse(
      grepl("^\\*OUT\\d*\\*$", df$lhs), "return",
      ifelse(df$lhs %in% args, "arg", "var")),
    "> ",
    df$lhs,
    "]"
  )

  df$rhs <- paste0(
    "[<",
    ifelse(df$rhs %in% args, "arg", "var"),
    "> ",
    df$rhs,
    "]"
  )

  nomnoml_code <- paste0(
    nomnoml_code,
    paste(df$rhs, ifelse(df$link == "cf",  "-->", "->"), df$lhs, collapse = "\n")
  )
  #cat(nomnoml_code)

  nomnoml::nomnoml(nomnoml_code)
}

