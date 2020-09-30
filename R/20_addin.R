flow_view_addin <- function() {
  # nocov start
  context <- rstudioapi::getSourceEditorContext()
  selection <- rstudioapi::primary_selection(context)[["text"]]

  # if we select between quotes we still make it work as conflicts are unlikely
  if (file.exists(selection)) {
    print(flow::flow_view(selection))
    return(invisible())
  }
  selection_lng <- parse(text = selection)

  if (length(selection_lng) == 1) {
    # if length 1 it should be a function, a path as a string litteral or
    # a path in a variable
    print(eval.parent(bquote(flow::flow_view(.(selection_lng[[1]])))))
  } else {
    # convert expression as in output from `expression()` to `{` expression
    selection_lng <- as.call(c(quote(`{`), selection_lng))
    print(flow::flow_view(selection_lng))
  }
  invisible()
  # nocov end
}

flow_run_addin <- function() {
  # nocov start
  context <- rstudioapi::getSourceEditorContext()
  selection <- rstudioapi::primary_selection(context)[["text"]]

  selection_lng <- str2lang(selection)
  print(eval.parent(bquote(flow::flow_view(.(selection_lng[[1]])))))
  invisible()
  # nocov end
}
