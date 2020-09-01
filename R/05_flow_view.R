#' View function as flow chart
#'
#' `flow_view()` shows the code of a function as a flow diagram, `flow_run()`
#' runs a call and draws the logical path taken by the code, `flow_data()` is
#' the lower level function, which builds the edge and node data rendered by
#' `flow_view()` and `flow_run()`.
#'
#' @param x A call, a function, or a path to a script
#' @param range numeric vector used to compute the range of boxes to zoom in
#' @param prefix prefix to use for special comments in our code used as block headers,
#'   must start with `"#"`
#' @param sub_fun_id if not NULL, the index or name of the function definition found in
#'   x that we wish to inspect
#' @param swap whether to change `var <- if(cond) expr` into
#'   `if(cond) var <- expr` so the diagram displays better
#' @param narrow `TRUE` makes sure the diagram stays centered on one column
#'   (they'll be longer but won't shift to the right)
#' @param ... Additional parameters passed to `build_nomnoml_code()`
#' @inheritParams build_nomnoml_code
#' @param width,height Width and height in pixels, passed to `htmlwidgets::createWidget()`
#' @param browse whether to debug step by step (block by block),
#'   can also be a vector of block ids, in this case `browser()` calls will be
#'   inserted at the start of these blocks
#' @param show_passes label the edges with the number of passes
#' @param out a path to save the diagram to.
#'   Special values "html", "htm", "png", "pdf", "jpg" and "jpeg" can be used to
#'   export the objec to a temp file of the relevant format and open it,
#'   if a regular path is used the format will be guessed from the extension.
#' @param svg only for default or html outut, whether to use svg rendering, rendering
#'   is more robust without it, but it makes text selectable on output which is
#'    sometimes useful
#' @param engine Either `"nomnoml"` (default) or `"plantuml"` (experimental), if
#'   the latter, arguments `range`, `prefix`, `narrow`, `code`, `width`,
#'   `height` and `...` will be ignored.
#'
#' @export
flow_view <-
  function(x, range = NULL, prefix = NULL, sub_fun_id = NULL,
           swap = TRUE, narrow = FALSE, code = TRUE, width = NULL,
           height = NULL, ..., out = NULL, svg = FALSE, engine = c("nomnoml", "plantuml")) {
    engine = match.arg(engine)
    if(engine == "plantuml") {
      if(!requireNamespace("plantuml"))
        stop("The package plantuml needs to be installed to use this feature. ",
             'To install it run `remotes::install_github("rkrug/plantuml")`, ',
             "You might also need to install java ('https://www.java.com'), ",
             "ghostcript ('https://www.ghostcript.com'), ",
             "and graphViz ('https://graphviz.org/')")

      # we should aim at diminishing this list as much as possible
      # range, narrow, width, height, and ... should not be relevant
      # code = FALSE is easy
      # prefix and code = NA are hard
      if(!missing(range) || !missing(prefix) ||
         !missing(narrow) || !missing(code) ||
         !missing(width) || !missing(height) || length(list(...)))
        warning("The following arguments are ignored if `engine` is set to
                \"plantuml\" : `range`, `prefix`, `narrow`, `code`, `width`,
                `height` , `...`")
      flow_view_plantuml(
        deparse(substitute(x)), x,
        prefix = prefix, sub_fun_id = sub_fun_id, swap = swap, out = out, svg = svg)
      return(invisible(NULL))
    }
    data <- eval.parent(substitute(flow::flow_data(x, range, prefix, sub_fun_id, swap, narrow)))
    code <- build_nomnoml_code(data, code = code, ...)
    x <- list(code = code, svg = svg)
    widget <- htmlwidgets::createWidget(
      name = "nomnoml", x,
      width = width,
      height = height,
      package = "nomnoml")

    if (is.null(out)) return(widget)

    is_tmp <- out %in% c("html", "htm", "png", "pdf", "jpg", "jpeg")
    if (is_tmp) {
      out <- tempfile("flow_", fileext = paste0(".", out))
    }
    ext <- sub(".*?\\.([[:alnum:]]+)$", "\\1", out)
    if (tolower(ext) %in% c("html", "htm"))
      htmlwidgets::saveWidget(widget, out)
    else {
      html <- tempfile("flow_", fileext = ".html")
      htmlwidgets::saveWidget(widget, html)
      webshot::webshot(html, out, selector = "canvas")
    }

    if (is_tmp) {
      message(sprintf("The diagram was saved to '%s'", gsub("\\\\","/", out)))
      browseURL(out)
    }
    out
}


