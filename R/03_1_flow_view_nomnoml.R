flow_view_nomnoml <- function(
  f_chr, x, prefix, truncate, nested_fun, swap, narrow, code, out,
  engine) {

  ## build data
  data <- flow_data(
    setNames(list(x), f_chr),
    prefix = prefix,
    narrow = narrow,
    nested_fun = nested_fun,
    swap = swap,
    truncate = truncate)

  if(identical(out, "data")) return(data)

  ## build code from data
  code <- do.call(build_nomnoml_code, c(list(data,code = code)))
  class(code) <- "flow_code"

  if(identical(out, "code")) return(code)

  out <- save_nomnoml(code, out)
  if(inherits(out, "htmlwidget")) as_flow_diagram(out, data, code) else invisible(out)
}

as_flow_diagram <- function(widget, data, code) {
  out <- list(widget = widget, data = data, code = code)
  class(out) <- "flow_diagram"
  out
}

#' @export
print.flow_diagram <- function(x, ...) {
  if(isTRUE(getOption('knitr.in.progress'))) {
    widget <- x$widget
    widget$x$svg <- FALSE
    png <- tempfile("flow_", fileext = ".png")
    html <- tempfile("flow_", fileext = ".html")
    do.call(htmlwidgets::saveWidget, c(list(widget, html, FALSE)))
    webshot::webshot(html, png, selector = "canvas")
    #FIXME: printing should return the input, but couldn't find another way here
    return(knitr::include_graphics(png))
  } else {
    print(x$widget)
  }
 invisible(x)
}

#' @export
print.flow_code <- function(x, out = NULL, ...) {
  # FIXME: it would be nice to color the [<foo> ] with block color, and item number in another color
  #  but not super crucial as this won't be used that much, we might also have an option to describe
  #  how to deal with the braille character: show, hide, show as UTF8
  writeLines(x)
  invisible(x)
}

save_nomnoml <- function(code, out) {
  ## set svg to TRUE if flow.svg is TRUE and output to viewer or html
  svg <- getOption("flow.svg") &&
    (is.null(out) || out %in% c("htm", "html") || endsWith(out, ".htm") || endsWith(out, ".html"))

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
