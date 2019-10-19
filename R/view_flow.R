view_flow <- function(f, prefix = NULL, ...){
  nodes <- new_node(1L, "header", code = substitute(f), code_str =
                      deparse(substitute(f)))
  edges <- new_edge(integer(0),integer(0),character(0),character(0)) # empty edge df
  # put comments in `#`() calls
  f <- add_comment_calls(f, prefix)
  # build data from the function body
  data <- build_data(body(f), 2)
  # data$nodes$code <- NULL # so printing doesn't bug
  # return(data)
  # join to header
  data <- add_data(list(nodes = nodes, edges = edges), data)
  # temp, for display
  data$nodes$code <- sapply(data$nodes$code, function(x) {
    paste(unlist(sapply(x, deparse)), collapse="\n")
  })
  code <- build_nomnoml_code(data, ...)
  nomnoml::nomnoml(code)
}
