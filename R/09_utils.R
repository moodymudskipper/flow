# imports and lower level unexported functions

#' @importFrom utils head isS3stdGeneric getS3method
NULL

add_comment_calls <- function(fun, prefix = "##"){
  if (is.null(prefix)) return(fun)
  src <- deparse(fun, width.cutoff = 500, control = "useSource")
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
  x <- deparse(x)
  x <- x[-c(1, length(x))]
  x <- sub("^    ","",x)
  paste(x, collapse = "\n")
}

`%call_in%` <- function(calls, constructs){
  sapply(as.list(calls), function(x)
    is.call(x) && as.character(x[[1]]) %in% constructs)
}

get_last_call_type <- function(expr){
  if (is.call(expr) && identical(expr[[1]], quote(`{`))){
    expr <- expr[[length(expr)]] # could be a call or a symbol
  }
  if (is.call(expr))
    deparse(expr[[1]])
  else if (deparse(expr) %in% c("break","next")) {
    deparse(expr)
  } else
    "standard"
}

find_funs <- function(call){
  env <- new.env()
  env$funs <- list()
  find_funs0 <- function(x, env){
    if (!is.call(x)) return(invisible())
    if (identical(x[[1]], quote(`function`))){
      env$funs <- append(env$funs, x)
    }
    lapply(x, find_funs0, env)
  }
  if (is.function(call)) call <- body(call)
  find_funs0(call, env)
  env$funs
}

swap_calls <- function(expr){
  if (!is.call(expr)) return(expr)
  if (is.call(expr) && identical(expr[[1]], quote(`<-`)) &&
     is.call(expr[[3]]) && identical(expr[[3]][[1]], quote(`if`))) {
    var <- expr[[2]]
    expr <- expr[[3]]

    if (is.call(expr[[3]]) && identical(expr[[3]][[1]], quote(`{`)))
      expr[[3]][[length(expr[[3]])]] <- call("<-", var, expr[[3]][[length(expr[[3]])]])
    else
      expr[[3]] <- call("<-", var, expr[[3]])

    if (is.call(expr[[4]]) && identical(expr[[4]][[1]], quote(`{`)))
      expr[[4]][[length(expr[[4]])]] <- call("<-", var, expr[[4]][[length(expr[[4]])]])
    else
      expr[[4]] <- call("<-", var, expr[[4]])
    return(expr)
  }
  expr[] <- lapply(expr, swap_calls)
  expr
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

