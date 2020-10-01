flow_view_nomnoml <- function(
  f_chr, x, range, prefix, sub_fun_id, swap, narrow, code, width, height, ..., out, svg, engine) {

  data <- flow_data(setNames(list(x), f_chr), range, prefix, sub_fun_id, swap, narrow)

  # this should be done upstream
  data$nodes$code_str[data$nodes$block_type == "standard"] <-
    sapply(data$nodes$code_str[data$nodes$block_type == "standard"], function(x) {
      if(x == "") return("")
      paste(styler::style_text(x), collapse = "\n")
    })
  # nomnoml ignores regular spaces so we use braille spaces, these are quite wide
  # when not using monospace so we might want to choose another
  data$nodes$code_str <- gsub(" ", "\u2800", data$nodes$code_str)
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
