allNames <- function (x) {
  value <- names(x)
  if (is.null(value))
    character(length(x))
  else value
}

add_comment_calls <- function(fun, prefix = "##"){

  ## deparse function
  src <- deparse(fun, width.cutoff = 500, control = "useSource")
  src <- paste(src, collapse = "\n")

  ## remove misplaced comments

  # some header comments might be misplaced, i.e. placed before or after
  # arguments to a function. arguments start or finish with parentheses or commas,
  # so we wan remove those with regex

  # remove comments after "("
  src <- gsub("\\(\\n([\\s\\n]+#.*?\\n)+", "(", src, perl = TRUE)

  # remove comments before ")"
  src <- gsub("([\\s\\n]+#.*?\\n)+[\\s\\n]*\\)", ")", src, perl = TRUE)

  # remove comments after "," where
  src <- gsub("(\n[\\s]+[^#\\s].*?),\\n([\\s\\n]+#.*?\\n)+", "\\1,", src, perl = TRUE)

  # remove comments before ","
  src <- gsub("([\\s\\n]+#.*?\\n)+[\\s\\n]*,", ",", src, perl = TRUE)

  ## split by line
  src <- strsplit(src, "\\n")[[1]]

  for (prefix in prefix) {
    ## replace comments by call to `#`()
    pattern <- paste0("^\\s*(", prefix, ".*?)$")

    coms_lgl <- grepl(pattern, src)

    com <- gsub(pattern, "\\1", src[coms_lgl])

    # remove comment prefix
    com <- sub(paste0("^\\s*", prefix,"\\s*"), "", com)

    # escape quotes
    com <- gsub('"', '\\\\"', com)
    com <- sprintf('`#`("%s")', com)

    ## rebuild function

    src[coms_lgl] <- com
  }

  src <- paste(src, collapse = "\n")
  src <- str2lang(src)
  eval(src)
}

get_last_id <- function(data) {
  if (!nrow(data$nodes)) return(0)
  max(data$nodes$id)
}

deparse1 <- function (expr, collapse = " ", width.cutoff = 500L, ...)
  paste(deparse(expr, width.cutoff, ...), collapse = collapse)

str2lang <- function(s) {
  parse(text=s)[[1]]
}

trimws <- function (x, which = c("both", "left", "right"), whitespace = "[ \t\r\n]") {
  which <- match.arg(which)
  mysub <- function(re, x) sub(re, "", x, perl = TRUE)
  switch(
    which,
    left = mysub(paste0("^", whitespace, "+"),x),
    right = mysub(paste0(whitespace, "+$"), x),
    both = mysub(paste0(whitespace, "+$"), mysub(paste0("^", whitespace, "+"), x))
  )
}

# deparse2 <- function(x){
#   x <- as.call(c(quote(`{`),x))
#   x <- deparse(x, width.cutoff = 500)
#   x <- x[-c(1, length(x))]
#   x <- sub("^    ","",x)
#   paste(x, collapse = "\n")
# }

`%call_in%` <- function(calls, constructs){
  sapply(as.list(calls), function(x)
    is.call(x) && deparse1(x[[1]]) %in% constructs)
}

get_last_call_type <- function(expr){
  ## is `expr` a {} expression ?
  if (is.call(expr) && identical(expr[[1]], quote(`{`))) {
    ## set `expr` to the last expression
    expr <- expr[[length(expr)]] # could be a call or a symbol
  }

  ## is `expr` a call ?
  if (is.call(expr)) {
    ## get the last call type from the name of the called function
    last_call_type <- deparse(expr[[1]], width.cutoff = 500)
    # else if (deparse(expr) %in% c("break","next")) {
    #   deparse(expr)}
  } else  {
    ## set the last call type to "standard"
    last_call_type <- "standard"
  }

  ## is the last call type `abort` ?
  if(last_call_type %in% c("abort", "rlang::abort")) {
    ## set it to "stop"
    last_call_type <- "stop"
  }

  ## return the last call type
  last_call_type
}

find_funs <- function(call){
  env <- new.env()
  env$funs <- list()
  find_funs0 <- function(x, env){
    if (!is.call(x)) return(invisible())
    is_assignment <-
      identical(x[[1]], quote(`<-`)) || identical(x[[1]], quote(`=`))
    if (is_assignment) {
      is_function_assignment <-
        is.call(x[[3]]) && identical(x[[c(3,1)]], quote(`function`))
      if(is_function_assignment){
        env$funs <- append(env$funs, x[[3]])
        names(env$funs)[length(env$funs)] <- paste(deparse(x[[2]]), collapse="\n")
        return(lapply(x[[3]], find_funs0, env))
      }
    } else if (identical(x[[1]], quote(`function`))) {
      env$funs <- append(env$funs, x)
      names(env$funs)[length(env$funs)] <- ""
    }
    lapply(x, find_funs0, env)
  }
  if (is.function(call)) call <- body(call)
  find_funs0(call, env)
  env$funs
}

swap_calls <- function(expr){
  # if not a call return as is
  if (!is.call(expr)) return(expr)
  # if call is of form foo <- if(...
  is_if_assignment <- identical(expr[[1]], quote(`<-`)) &&
    is.call(expr[[3]]) && identical(expr[[3]][[1]], quote(`if`))
  if (is_if_assignment) {
    # var is the lhs of <-
    var <- expr[[2]]
    # expr is the rhs of <-
    expr <- expr[[3]]

    yes_surrounded_by_curly <-
      is.call(expr[[3]]) && identical(expr[[3]][[1]], quote(`{`))
    if (yes_surrounded_by_curly)
      # change the last expression into an assignment to var
      expr[[3]][[length(expr[[3]])]] <- call("<-", var, expr[[3]][[length(expr[[3]])]])
    else
      # change unique expression into an asignment to var
      expr[[3]] <- call("<-", var, expr[[3]])

    if(length(expr) == 4) {
      no_surrounded_by_curly <-
        is.call(expr[[4]]) && identical(expr[[4]][[1]], quote(`{`))
      if (no_surrounded_by_curly)
        # change the last expression into an assignment to var
        expr[[4]][[length(expr[[4]])]] <- call("<-", var, expr[[4]][[length(expr[[4]])]])
      else
        # change unique expression into an asignment to var
        expr[[4]] <- call("<-", var, expr[[4]])
    }
    return(expr)
  }

  # is_stopifnot <-
  #   identical(expr[[1]], quote(stopifnot))
  # if (is_stopifnot){
  #   expr <- call("if", call("!",expr[[2]]), bquote({
  #     `#`("Adapted from stopifnot")
  #     stop(.(
  #     paste(deparse(expr[[2]]),"is not TRUE")))}))
  # }
  # apply recursively
  expr[] <- lapply(expr, swap_calls)
  expr
}

# a fixed version of utils::isS3stdGeneric so it works on symbols, NULL bodied
# functions and traced functions (if trace is first)
isS3stdGeneric <- function(f) {
  if("functionWithTrace" %in% class(f))
    bdexpr <- body(attr(f, "original"))
  else
    bdexpr <- body(f)
  while(is.call(bdexpr) && (as.character(bdexpr[[1L]]) == "{"))
    bdexpr <- as.list(bdexpr[[2]])
  ret <- is.call(bdexpr) && identical(bdexpr[[1L]], as.name("UseMethod"))
  if (ret)
    names(ret) <- bdexpr[[2L]]
  ret
}

getS3methodSym <- function(fun, x){
  s3methods <- sapply(class(x),getS3method, f = fun, optional = TRUE, envir = parent.frame())
  s3methods <- Filter(Negate(is.null), s3methods)
  suffix <- names(s3methods)[1]
  if (is.na(suffix)) {
    suffix <- "default"
    fun_eval <- get0(fun, mode = "function")
    nmspc <- getNamespaceName(environment(fun_eval))
    nm <- paste0(fun,".",suffix)
    if (!exists(nm, environment(fun_eval)))
      stop("error when trying to guess S3 method")
    nm <- paste0(nmspc,"::", nm)
    test <- try(eval(str2lang(nm)), silent = TRUE)
    if (inherits(test, "try-error")) nm <- sub("::", ":::", nm, fixed = TRUE)
    #method <- get0(nm, mode = "function", envir = environment(fun_eval))
  } else {
    method <- s3methods[[1]]
    nmspc <- getNamespaceName(environment(method))
    nm <- paste0(fun,".",suffix)
    if (!exists(nm, environment(method)))
      stop("error when trying to guess S3 method")
    nm <- paste0(nmspc,"::", nm)
    test <- try(eval(str2lang(nm)), silent = TRUE)
    if (inherits(test, "try-error")) nm <- sub("::", ":::", nm, fixed = TRUE)
  }

  nm
}

gfn <- getFromNamespace


robust_deparse <- function(call) {
  txt <- paste(deparse(call, width.cutoff = 40L, backtick = TRUE), collapse = "\n")
  if (!grepl("\\$!!", txt)) return(txt)
  # replace
  substitute_bad_dollars <- function(call) {
    if(!is.call(call)) return(call)
    if(length(call) == 3 && identical(call[[1]], quote(`$`))) {
      if(!is.character(call[[3]])) {
        call[[1]] <- as.symbol("$\b")
      }
    }
    call <- as.call(lapply(as.list(call), substitute_bad_dollars))
    call
  }
  call <- substitute_bad_dollars(call)
  txt <- paste(deparse(call, width.cutoff = 40L, backtick = TRUE), collapse = "\n")
  gsub("`\\$\\\\b`", "`$`", txt)
}

escape_pipes_and_brackets <- function(x) {
  x <- gsub("]","\\]", x ,fixed = TRUE)
  x <- gsub("[","\\[", x ,fixed = TRUE)
  x <- gsub("|","\\|", x ,fixed = TRUE)
  x
}

quote_non_syntactic <- function(x) {
  ifelse(x == make.names(x), x, paste0("`", x, "`"))
}

get_binding_environment <- function(fun_name, env = parent.frame()) {
  if (identical(env, emptyenv())) {
    stop("Can't find `", fun_name, "`.", call. = FALSE)
  } else if (exists(fun_name, env, inherits = FALSE)) {
    env
  } else {
    get_binding_environment(fun_name, parent.env(env))
  }
}

namespace_name <- function(x, ...) UseMethod("namespace_name")

#' @export
namespace_name.environment <- function(x, env, ...) {
  if(identical(x, globalenv())) return("R_GlobalEnv")
  if(!isNamespace(x)) stop("The provided environment isn't a namespace")
  sub("^namespace:", "", environmentName(x))
}

#' @export
namespace_name.character <- function(x, env, fallback_ns = NULL, fail_if_not_found = TRUE) {

  if(grepl("::", x)) {
    return(sub("^([^:]+)[:]{1,2}.*", "\\1", x))
  }


  # since function's environment is not necessarily its namespace we need to go up
  if (!exists(x, envir = env, inherits = TRUE)) {
    if(!is.null(fallback_ns) && exists(x, envir = fallback_ns, inherits = FALSE))
      return(namespace_name(fallback_ns))
    if(fail_if_not_found)
      stop(sprintf("`%s` cannot be found", x))
    else
      return(NA)
  }
  # handle primitives
  if(is.null(environment(get(x, env)))) return("base")

  bind_env <- get_binding_environment(x, env)
  bind_env_nm <- environmentName(bind_env)
  if(startsWith(bind_env_nm, "imports:")) {
    parent_ns <- sub("^.*?:", "", bind_env_nm)
    imports <- getNamespaceImports(parent_ns)
    pkgs <- names(Filter(function (funs) x %in% funs, imports))
    namespace_name <- pkgs[length(pkgs)] # or pkgs[1] ? not sure
  } else if(startsWith(bind_env_nm, "package:")) {
    namespace_name <- sub("^.*?:", "", bind_env_nm)
  } else if (bind_env_nm == "base") {
    namespace_name <- "base"
  } else if (bind_env_nm == "") {
    # an anonymous closure environment
    # FIXME: deal with those cleanly, should be hidden from diagram
    namespace_name <- "" # capture.output(bind_env)
  } else {
    namespace_name <- namespace_name(bind_env)
  }

  namespace_name
}

get_namespace_exports <- function(ns) {
  if (identical(ns, globalenv())) return(ls(globalenv()))
  if(!file.exists("DESCRIPTION")) return(getNamespaceExports(ns))
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
