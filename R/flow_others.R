#' @export
#' @rdname flow_view
flow_code <-
  function(x, range = NULL, prefix = NULL, sub_fun_id = NULL, code = TRUE, ...) {
    data <- eval.parent(substitute(flow_data(x, range, prefix, sub_fun_id)))
    code <- build_nomnoml_code(data, code = code, ...)
    code
  }



#' @export
#' @rdname flow_view
flow_html <-
  function(x, range = NULL, prefix = NULL, sub_fun_id = NULL,
           swap = FALSE, code = TRUE, width = NULL,
           height = NULL,
           path = tempfile("flow", fileext = ".html"), ...) {
    data <- eval.parent(substitute(flow_data(x, range, prefix, sub_fun_id, swap)))
    code <- build_nomnoml_code(data, code = code, ...)
    x <- list(code = code, svg = FALSE)
    widget <- htmlwidgets::createWidget(
      name = "nomnoml", x,
      width = width,
      height = height,
      package = "nomnoml")
    htmlwidgets::saveWidget(widget, path)
    if (missing(path)) message(sprintf("The diagram was saved at '%s'", path))
  }

#' @export
#' @rdname flow_view
flow_browse <-
  function(x, range = NULL, prefix = NULL, sub_fun_id = NULL, swap = FALSE, code = TRUE, width = NULL,
           height = NULL, ...) {
    data <- eval.parent(substitute(flow_data(x, range, prefix, sub_fun_id, swap)))
    code <- build_nomnoml_code(data, code = code, ...)
    x <- list(code = code, svg = FALSE)
    widget <- htmlwidgets::createWidget(
      name = "nomnoml", x,
      width = width,
      height = height,
      package = "nomnoml")
    path <- tempfile("flow", fileext = ".html")
    htmlwidgets::saveWidget(widget, path)
    system(path)
  }

# #' @export
# #' @rdname flow_view
# flow_svg <-
#   function(x, prefix = NULL, code = TRUE, width = NULL,
#            height = NULL,
#            path = tempfile("flow", fileext = ".svg"), ...) {
#     data <- eval.parent(substitute(flow_data(x, range, prefix)))
#     code <- build_nomnoml_code(data, code = code, ...)
#     x <- list(code = code, svg = TRUE)
#     path0 <- tempfile("flow", fileext = ".html")
#     widget <- htmlwidgets::createWidget(
#       name = "nomnoml", x,
#       width = width,
#       height = height,
#       package = "nomnoml")
#     htmlwidgets::saveWidget(widget, path0)
#
#     webshot::webshot(path0, path, selector = "canvas")
#     if(missing(path)) message(sprintf("The diagram was saved at '%s'", path))
#   }

#' @export
#' @rdname flow_view
flow_png <-
  function(x, range = NULL, prefix = NULL, sub_fun_id = NULL, swap = FALSE, code = TRUE, width = NULL,
           height = NULL,
           path = tempfile("flow", fileext = ".png"), ...) {
    data <- eval.parent(substitute(flow_data(x, range, prefix, sub_fun_id, swap)))
    code <- build_nomnoml_code(data, code = code, ...)
    x <- list(code = code, svg = FALSE)
    path0 <- tempfile("flow", fileext = ".html")
    widget <- htmlwidgets::createWidget(
      name = "nomnoml", x,
      width = width,
      height = height,
      package = "nomnoml")
    htmlwidgets::saveWidget(widget, path0)

    webshot::webshot(path0, path, selector = "canvas")
    if (missing(path)) message(sprintf("The diagram was saved at '%s'", path))
  }
