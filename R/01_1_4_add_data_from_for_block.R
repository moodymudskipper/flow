add_data_from_for_block <- function(data, block, narrow = FALSE){

  ## add data from `for` header and "body"

  # increment id
  id <- get_last_id(data) + 1
  id_end <- -id
  # add node for `for` statement

  code_str <- robust_deparse(call("for", block[[2]], block[[3]]))
  code_str <- styler::style_text(code_str)
  code_str[length(code_str)] <- sub(" NULL$","", code_str[length(code_str)])
  indenter <- getOption("flow.indenter")
  if(length(code_str) == 1) code_str <- c(code_str, indenter)
  code_str <- paste(indenter, code_str, indenter, collapse = "\n")
  code_str <- sub(sprintf(
    " \\{ %s\\n%s   NULL %s\\n%s \\} %s",
    indenter, indenter, indenter, indenter, indenter),
    "", code_str)

  data <- add_node(
    data,
    id, "for",
    #code = block, #as.list(block[2:3]),
    code_str = code_str,
    label = attr(block, "label"))

  # add edge from `for` statement
  data <- add_edge(data, from = id, to = id + 1)

  # build data from for's "body"
  for_expr <- block[[4]] # the 4th item contains the code
  data <-  add_data_from_expr(data, for_expr, narrow = narrow)

  ## update last edge to target end node, and add end_node

  # we edit last edge because last of loop
  # node id but to end
  data$edges$to[nrow(data$edges)] <- id_end

  # add the end node
  data <- add_node(data, id_end, "start")

  ## add edge back to top

  data <- add_edge(data, from = id, to = id_end, edge_label = "next", arrow = "<-")

  ## add edge to next node

  id_next <- get_last_id(data) + 1
  data <- add_edge(data, from = id_end, to = id_next)

  ## return updated data
  data
}
