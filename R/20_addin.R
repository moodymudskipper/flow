flow_view_addin <- function() {
  # nocov start

  ## fetch context and selection
  context <- rstudioapi::getSourceEditorContext()
  selection <- rstudioapi::primary_selection(context)[["text"]]

  # if we select between quotes we still make it work as conflicts are unlikely

  ## is selection an existing path ?
  if (file.exists(selection)) {
    ## flow_view this path
    print(flow::flow_view(selection))
    return(invisible())
  }

  ## parse the selection
  selection_lng <- parse(text = selection)

  ## is the selection of length 1 (presumably a function) ?
  if (length(selection_lng) == 1 && length(selection_lng[[1]])  == 1) {
    # if length 1 it should be a function, a path as a string literal or
    # a path in a variable

    ## flow_view this function
    print(eval.parent(bquote(flow::flow_view(.(selection_lng[[1]])))))
  } else {
    ## flow_view the selected code
    # convert expression as in output from `expression()` to `{` expression
    selection_lng <- as.call(c(quote(`{`), selection_lng))
    print(flow::flow_view(selection_lng))
  }
  ## return NULL invisibly
  invisible()
  # nocov end
}

flow_run_addin <- function() {
  # nocov start
  ## fetch context and selection
  context <- rstudioapi::getSourceEditorContext()
  selection <- rstudioapi::primary_selection(context)[["text"]]

  ## parse the selection
  selection_lng <- str2lang(selection)
  print(eval.parent(bquote(flow::flow_run(.(selection_lng)))))
  invisible()
  # nocov end
}
