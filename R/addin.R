flow_view_addin <- function() {
  # nocov start
  context <- rstudioapi::getSourceEditorContext()
  selection <- rstudioapi::primary_selection(context)[["text"]]

  if(file.exists("selection")) {
    print(flow_view(selection))
    return(invisible())
  }

  selection_lng <- parse(text = selection)

  if(length(selection_lng) == 1) {
    print(eval(bquote(flow_view(.(selection_lng[[1]])))))
  } else {
    selection_lng <- as.call(c(quote(`{`), selection_lng))
    print(flow_view(selection_lng))
  }
  invisible()
}
