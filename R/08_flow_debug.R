#' Debug With Flow Diagrams
#'
#' These functions are named after the base functions `debug()`, `undebug()` and
#' `debugonce()`. `flow_debug()` will call `flow_run()`, with the same additional arguments, on all the following
#' calls to `f()` until `flow_undebug()` is called. `flow_debugonce()` will only
#' call `flow_run()` on the next call to `f()`.
#'
#' By default, unlike `debug()` and `debugonce()`, `flow_debug()` and
#' `flow_debugonce()` don't trigger a debugger but only draw diagrams, this is
#' consistent with `flow_run()`'s defaults. To browse through the code, use
#' the `browse` argument.
#'
#' @param f function to debug
#' @inheritParams flow_run
#' @export
flow_debug <- function(
  f, prefix = NULL, swap = TRUE, code = TRUE, ...,
  out = NULL, svg = FALSE, browse = FALSE) {
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
    trace(.(substitute(f)), quote(.(tracer)), print = FALSE)
  )
  eval.parent(trace_call)
  invisible()
}


#' @export
#'
#' @rdname flow_debug
flow_debugonce <- function(
  f, prefix = NULL, swap = TRUE, code = TRUE, ...,
  out = NULL, svg = FALSE, browse = FALSE) {
  call <- match.call()
  call[[1]] <- quote(flow::flow_run)
  names(call)[names(call) == "f"] <- "x"
  call[["x"]] <- quote(.(call))
  tracer <- bquote({
    call <- sys.call(-4) # we have to go back a few more steps when in doTrace
    flow_run_call <- bquote(.(call))
    on.exit(untrace(call[[1]]))
    #browser()
    return(eval.parent(flow_run_call, 5))
  })
  trace_call <- bquote(
    trace(.(substitute(f)), quote(.(tracer)), print = FALSE)
  )
  eval.parent(trace_call)
  invisible()
}

is_flow_traced <- function(f){
  if(length(body(f)) < 2) return(FALSE)
  #nocov start
  traces <- expression(
    .doTrace({
      call <- sys.call(-4)
      flow_run_call <- bquote(flow::flow_run(x = .(call)))
      return(eval.parent(flow_run_call, 5))
    }),
    tracer <- bquote({
      call <- sys.call(-4) # w have to go back a few more steps when in doTrace
      flow_run_call <- bquote(.(call))
      #browser()
      on.exit(untrace(call[[1]]))
      return(eval.parent(flow_run_call, 5))
    }))
  #nocov end
  any(sapply(traces, function(x) identical(deparse(x), deparse(body(f)[[2]]))))
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
