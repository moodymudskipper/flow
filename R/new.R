#' @export
#' @rdname flow_view
flow_data <-
  function(x, subset = NULL, prefix = NULL, sub_fun_id = NULL) {
    f_sym <- substitute(x)

    # build data from the function body
    data <- new_data()

    # put comments in `#`() calls
    x <- add_comment_calls(x, prefix)

    sub_funs <- find_funs(x)
    if(!is.null(sub_fun_id)){
      f_sym <- quote(fun)
      x <- eval(sub_funs[[sub_fun_id]])
    } else {
      if(length(sub_funs)){
        message("We found function definitions in this code, ",
                "use the argument sub_fun_id to inspect them")
        print(sub_funs)
      }
    }
    if(is.function(x)){
      title <- head(deparse(args(x)), -1)
      title <- paste(title, collapse = "\n  ")
      title <- sub("^function ", deparse(f_sym), title)
      data <- add_node(
        data,
        id = 0L,
        "header",
        code = f_sym,
        code_str = title)
      data <- add_edge(data, from=0L, to = 1L)
      data <- add_data_from_expr(data, body(x))
    } else if (is.call(x)) {
      data <- add_data_from_expr(data, x)
    } else {
      stop("x must be a function or a call")
    }

    # add the final node
    id = get_last_id(data) + 1
    data <- add_node(data, id, "return")
    if(!is.null(prefix)){
      prefix <- paste0("^\\s*", prefix,"\\s*")
      data$nodes$label <- sub(prefix, "", data$nodes$label)
    }
    if(!is.null(subset)){
      matches <- which(data$nodes$id %in% subset)
      start <- min(matches)
      end   <- max(matches)
      data0 <- data
      if(min(subset) <= 1) {
        data$nodes <- data$nodes[1:end,]
        data$edges <- data$edges[
          data$edges$from %in% data$nodes$id &
            data$edges$to %in% data$nodes$id,]
      } else {
        data$nodes <- rbind(
          data.frame(id = 0, block_type = "header", code_str = ". . .",
                     label = "", code = ""),
          data$nodes[start:end,])
        data$edges <- data$edges[
          data$edges$from %in% data$nodes$id &
            data$edges$to %in% data$nodes$id,]
        entry_points <- unique(
          data$edges$from[!data$edges$from %in% data$edges$to])
        data$edges <- rbind(
          data.frame(from = 0, to = entry_points, edge_label = "", arrow = "--:>"),
          data$edges)
      }

      max_id <- max(data0$nodes$id)
      if(max(subset) < max_id) {
        data$nodes <- rbind(
          data$nodes,
          data.frame(id = max_id, block_type = "header", code_str = "...",
                     label = "", code = ""))
        exit_points <- data$edges$to[!data$edges$to %in% data$edges$from]
        exit_points <- data$nodes$id[data$nodes$id %in% exit_points &
                                       !data$nodes$block_type %in% c("stop", "return")]
        data$edges <- rbind(
          data$edges,
          data.frame(from = exit_points, to = max_id, edge_label = "", arrow = "--:>"))
      }

    }
data
}

#' @export
#' @rdname flow_view
flow_code <-
  function(x, subset = NULL, prefix = NULL, sub_fun_id = NULL, code = TRUE, ...) {
    data <- eval.parent(substitute(flow_data(x, subset, prefix, sub_fun_id)))
    code <- build_nomnoml_code(data, code = code, ...)
    code
  }

#' View function as flow chart
#'
#' @param x A call or a function
#' @param prefix Prefix to use for special comments, must start with `"#"`
#' @param subset The range of boxes to zoom in
#' @param sub_fun_id if not NULL, the index of the function definition found in
#'   x that we wish to inspect.
#' @param ... Additional parameters passed to `build_nomnoml_code()`
#' @inheritParams build_nomnoml_code
#' @param width Width in pixels
#' @param height height in pixels
#' @param path path to save to. By default saves to temp file and prints path.
#'
#' @export
flow_view <-
  function(x, subset = NULL, prefix = NULL, sub_fun_id = NULL, code = TRUE, width = NULL,
           height = NULL, ...) {
    data <- eval.parent(substitute(flow_data(x, subset, prefix, sub_fun_id)))
    code <- build_nomnoml_code(data, code = code, ...)
    x <- list(code = code, svg = FALSE)
    htmlwidgets::createWidget(
      name = "nomnoml", x,
      width = width,
      height = height,
      package = "nomnoml")


    #nomnoml::nomnoml(code, png = png, width = width, height = height, svg = svg)
  }

#' @export
#' @rdname flow_view
flow_html <-
  function(x, subset = NULL, prefix = NULL, sub_fun_id = NULL, code = TRUE, width = NULL,
           height = NULL,
           path = tempfile("flow", fileext = ".html"), ...) {
    data <- eval.parent(substitute(flow_data(x, subset, prefix, sub_fun_id)))
    code <- build_nomnoml_code(data, code = code, ...)
    x <- list(code = code, svg = FALSE)
    widget <- htmlwidgets::createWidget(
      name = "nomnoml", x,
      width = width,
      height = height,
      package = "nomnoml")
    htmlwidgets::saveWidget(widget, path)
    if(missing(path)) message(sprintf("The diagram was saved at '%s'", path))
  }

# #' @export
# #' @rdname flow_view
# flow_svg <-
#   function(x, prefix = NULL, code = TRUE, width = NULL,
#            height = NULL,
#            path = tempfile("flow", fileext = ".svg"), ...) {
#     data <- eval.parent(substitute(flow_data(x, subset, prefix)))
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
  function(x, subset = NULL, prefix = NULL, sub_fun_id = NULL, code = TRUE, width = NULL,
           height = NULL,
           path = tempfile("flow", fileext = ".png"), ...) {
    data <- eval.parent(substitute(flow_data(x, subset, prefix, sub_fun_id)))
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
    if(missing(path)) message(sprintf("The diagram was saved at '%s'", path))
  }
