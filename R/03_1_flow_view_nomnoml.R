flow_view_nomnoml <- function(
  f_chr, x, range, prefix, sub_fun_id, swap, narrow, code, width, height, ..., out, svg, engine) {

  ## build data
  data <- flow_data(setNames(list(x), f_chr), range, prefix, sub_fun_id, swap, narrow)

  ## build code from data
  code <- build_nomnoml_code(data, code = code, ...)

  ## buildwidget
  x <- list(code = code, svg = svg)
  widget <- htmlwidgets::createWidget(
    name = "nomnoml", x,
    width = width,
    height = height,
    package = "nomnoml")

  ## is the out argument NULL ?
  if (is.null(out)) {
    ## return the widget
    return(widget)
  }

  # flag if out is a temp file shorthand
  is_tmp <- out %in% c("html", "htm", "png", "pdf", "jpg", "jpeg")

  ## is it ?
  if (is_tmp) {
    ## set out to a temp file with the right extension
    out <- tempfile("flow_", fileext = paste0(".", out))
  }

  ## extract extension from path
  ext <- sub(".*?\\.([[:alnum:]]+)$", "\\1", out)

  ## is `out` a path to a web page ?
  if (tolower(ext) %in% c("html", "htm")) {
    ## save to file
    htmlwidgets::saveWidget(widget, out)
  } else {
    ## save to a temp html file then convert to required output
    html <- tempfile("flow_", fileext = ".html")
    htmlwidgets::saveWidget(widget, html)
    webshot::webshot(html, out, selector = "canvas")
  }

  ## was the out argument a temp file shorthand ?
  if (is_tmp) {
    ## print location of output and open it
    message(sprintf("The diagram was saved to '%s'", gsub("\\\\","/", out)))
    browseURL(out)
  }
  ## return the path to the output invisibly
  invisible(out)
}
