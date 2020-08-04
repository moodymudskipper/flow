#' View function as flow chart
#'
#' `flow_view()` shows the code of a function as a flow diagram, `flow_run()`
#' runs a call and draws the logical path taken by the code. `flow_png()` and
#' `flow_html()` are variants of `flow_view()` that allow to print to png or
#'  html
#'
#'
#' @param x A call or a function
#' @param prefix Prefix to use for special comments, must start with `"#"`
#' @param range The range of boxes to zoom in
#' @param sub_fun_id if not NULL, the index of the function definition found in
#'   x that we wish to inspect.
#' @param swap whether to change `var <- if(cond) expr` into
#'   `if(cond) var <- expr` so the diagram
#' @param ... Additional parameters passed to `build_nomnoml_code()`
#' @inheritParams build_nomnoml_code
#' @param width Width in pixels
#' @param height height in pixels
#' @param path path to save to. By default saves to temp file and prints path.
#' @param browse whether to debug step by step (block by block)
#'
#' @export
flow_view <-
  function(x, range = NULL, prefix = NULL, sub_fun_id = NULL,
           swap = FALSE, code = TRUE, width = NULL,
           height = NULL, ...) {
    data <- eval.parent(substitute(flow_data(x, range, prefix, sub_fun_id, swap)))
    code <- build_nomnoml_code(data, code = code, ...)
    x <- list(code = code, svg = FALSE)
    htmlwidgets::createWidget(
      name = "nomnoml", x,
      width = width,
      height = height,
      package = "nomnoml")
  }
