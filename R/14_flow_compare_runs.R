#' @export
#' @rdname flow_view
#' @param ref the reference expression for `flow_compare_runs()`
flow_compare_runs <- function(x, ref,
                              prefix = NULL,
                              code = TRUE,
                              narrow = FALSE,
                              truncate = NULL,
                              swap = TRUE,
                              out = NULL) {

  svg <- is.null(out) || endsWith(out, ".html") || endsWith(out, ".html")
  data_x <- eval.parent(substitute(flow_run(x, prefix, code, narrow, truncate, swap, out = "data", browse = FALSE)))
  data_ref <- eval.parent(substitute(flow_run(ref, prefix, code, narrow, truncate, swap, out = "data", browse = FALSE)))

  # take x as a reference
  data <- data_x

  # color green blocks that are "x only"
  data$nodes$block_type <- ifelse(
    data_x$nodes$passes & !data_ref$nodes$passes & data_ref$nodes$block_type == "standard",
    "standardr",
    data$nodes$block_type
  )

  # color orange blocks that are "y only"
  data$nodes$block_type <- ifelse(
    data_ref$nodes$passes & !data_x$nodes$passes & data_ref$nodes$block_type == "standard",
    "standardg",
    data$nodes$block_type
  )

  # create composite labels
  data$edges$edge_label <- ifelse(
    data_x$edges$passes == data_ref$edges$passes,
    ifelse(
      data$edges$passes == 0,
      data$edges$edge_label,
      trimws(sprintf("%s (%s)", data$edges$edge_label, data$edges$passes))
      ),
    ifelse(
      data_x$edges$passes == 0,
      trimws(sprintf("%s (ref: %s)", data$edges$edge_label, data_ref$edges$passes)),
      ifelse(
        data_ref$edges$passes == 0,
        trimws(sprintf("%s (x: %s)", data$edges$edge_label, data_x$edges$passes)),
        trimws(sprintf("%s (x: %s,ref: %s)", data$edges$edge_label, data_x$edges$passes, data_ref$edges$passes))
      )
    )
  )

  # coalesce to fullest arrow
  data$edges$arrow <- ifelse(
    data_x$edges$arrow == "->" | data_ref$edges$arrow == "->",
    "->",
    ifelse(
      data_x$edges$arrow == "<-" | data_ref$edges$arrow == "<-",
      "<-",
      data$edges$arrow
    )
  )

  # copied from flow_view_nomnoml

  if(identical(out, "data")) return(data)

  ## build code from data
  code <- do.call(build_nomnoml_code, c(list(data,code = code)))
  class(code) <- "flow_code"

  if(identical(out, "code")) return(code)

  out <- save_nomnoml(code, out)
  if(inherits(out, "htmlwidget")) as_flow_diagram(out, data, code) else invisible(out)
}
