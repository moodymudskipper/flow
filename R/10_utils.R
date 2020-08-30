# imports and lower level unexported functions

#' @importFrom utils head getS3method browseURL tail
NULL

## usethis namespace: start
#' @importFrom Rcpp sourceCpp
## usethis namespace: end
NULL


add_comment_calls <- function(fun, prefix = "##"){
  if (is.null(prefix)) return(fun)
  src <- deparse(fun, width.cutoff = 500, control = "useSource")

  src <- paste(src, collapse = "\n")

  # some header comments might be misplaced, i.e. placed before or after
  # arguments to a function. arguments start or finish with parentheses or commas,
  # so we wan remove those with regex

  # remove comments after "("
  src <- gsub("\\(\\n([\\s\\n]+#.*?\\n)+", "(", src, perl = TRUE)

  # remove comments before ")"
  src <- gsub("([\\s\\n]+#.*?\\n)+[\\s\\n]*\\)", ")", src, perl = TRUE)

  # remove comments after ","
  src <- gsub(",\\n([\\s\\n]+#.*?\\n)+", ",", src, perl = TRUE)

  # remove comments before ","
  src <- gsub("([\\s\\n]+#.*?\\n)+[\\s\\n]*,", ",", src, perl = TRUE)

  src <- strsplit(src, "\\n")[[1]]
  pattern <- paste0("^\\s*(", prefix, ".*?)$")
  src <- gsub(pattern, "`#`(\"\\1\")", src)
  src <- paste(src, collapse = "\n")
  src <- str2lang(src)
  eval(src)
}

get_last_id <- function(data) {
  if (!nrow(data$nodes)) return(0)
  max(data$nodes$id)
}

deparse2 <- function(x){
  x <- as.call(c(quote(`{`),x))
  x <- deparse(x, width.cutoff = 500)
  x <- x[-c(1, length(x))]
  x <- sub("^    ","",x)
  paste(x, collapse = "\n")
}

`%call_in%` <- function(calls, constructs){
  sapply(as.list(calls), function(x)
    is.call(x) && as.character(x[[1]]) %in% constructs)
}

get_last_call_type <- function(expr){
  if (is.call(expr) && identical(expr[[1]], quote(`{`))) {
    expr <- expr[[length(expr)]] # could be a call or a symbol
  }
  last_call_type <- if (is.call(expr))
    deparse(expr[[1]], width.cutoff = 500)
  # else if (deparse(expr) %in% c("break","next")) {
  #   deparse(expr)}
  else
    "standard"
  if(last_call_type %in% c("abort", "rlang::abort"))
    last_call_type <- "stop"
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

    no_surrounded_by_curly <-
      is.call(expr[[4]]) && identical(expr[[4]][[1]], quote(`{`))
    if (no_surrounded_by_curly)
      # change the last expression into an assignment to var
      expr[[4]][[length(expr[[4]])]] <- call("<-", var, expr[[4]][[length(expr[[4]])]])
    else
      # change unique expression into an asignment to var
      expr[[4]] <- call("<-", var, expr[[4]])
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
  {
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

 # getS3methodSym("mutate", starwars)
 # getS3methodSym("head", letters)
