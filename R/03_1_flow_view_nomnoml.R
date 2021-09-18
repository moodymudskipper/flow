flow_view_nomnoml <- function(
  f_chr, x, prefix, truncate, nested_fun, swap, narrow, code, out, svg,
  engine) {

  ## build data
  data <- flow_data(
    setNames(list(x), f_chr),
    prefix = prefix,
    narrow = narrow,
    nested_fun = nested_fun,
    swap = swap,
    truncate = truncate)

  ## build code from data
  code <- do.call(build_nomnoml_code, c(list(data,code = code)))

  out <- save_nomnoml(code, svg, out)
  if(inherits(out, "htmlwidget")) out else invisible(out)
}

save_nomnoml <- function(code, svg, out) {
  ## buildwidget
  x <- list(code = code, svg = svg)
  widget <- do.call(
    htmlwidgets::createWidget,
    c(list(name = "nomnoml", x,package = "nomnoml")))

  ## is the out argument NULL ?
  if (is.null(out)) {
    ## return the widget
    return(widget)
  }

  ## flag if out is a temp file shorthand
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
    do.call(htmlwidgets::saveWidget, c(list(widget, out)))
  } else {
    ## save to a temp html file then convert to required output
    html <- tempfile("flow_", fileext = ".html")
    do.call(htmlwidgets::saveWidget, c(list(widget, html)))
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
