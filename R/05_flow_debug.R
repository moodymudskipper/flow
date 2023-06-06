#' Debug With Flow Diagrams
#'
#' These functions are named after the base functions `debug()` and `undebug()`.
#' `flow_debug()` will call `flow_run()`, with the same additional arguments, on
#' all the following calls to `f()` until `flow_undebug()` is called.
#'
#' By default, unlike `debug()`, `flow_debug()` doesn't trigger a debugger but
#' only draw diagrams, this is consistent with `flow_run()`'s defaults. To browse
#' through the code, use the `browse` argument.
#'
#' @param f function to debug
#' @inheritParams flow_run
#' @return These functions return `NULL` invisibly (called for side effects)
#' @export
flow_debug <- function(
  f,
  prefix = NULL,
  code = TRUE,
  narrow = FALSE,
  truncate = NULL,
  swap = TRUE,
  out = NULL,
  browse = FALSE) {
  call <- match.call()
  call[[1]] <- quote(flow::flow_run)
  names(call)[names(call) == "f"] <- "x"
  call[["x"]] <- quote(.(call))
  tracer <- bquote({
    call <- sys.call(-4) # w have to go back a few more steps when in doTrace
    flow_run_call <- bquote(.(call))
    return(eval.parent(flow_run_call, 5))
  })
  trace_call <- bquote(
    trace(.(substitute(f)), quote(.(tracer)), print = FALSE, where = environment())
  )
  eval.parent(trace_call)
  invisible()
}

is_flow_traced <- function(f){
  if(length(body(f)) < 2) return(FALSE)
  identical(
    deparse(body(f)[[2]], width.cutoff = 500)[c(1,5)],
    c(".doTrace({", "    return(eval.parent(flow_run_call, 5))"))
}

#' @export
#'
#' @rdname flow_debug
flow_undebug <- function(f){
  if(!"functionWithTrace" %in% class(f))
    warning("argument is not being debugged")
  else if(is_flow_traced(f)) eval.parent(substitute(untrace(f)))
  invisible()
}

#' Deprecated
#'
#' @param ... ...
#' @keywords internal
#' @export
#' @return Fails with deprecation error
flow_debugonce <- function(...) {
  stop("`flow_debugonce()` is defunct, use `flow_debug()`")
}

