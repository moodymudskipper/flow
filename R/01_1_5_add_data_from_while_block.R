add_data_from_while_block <- function(data, block, narrow = FALSE){

  ## add data from `while` header and "body"

  # increment id
  id <- get_last_id(data) + 1
  id_end <- -id

  code_str <- robust_deparse(call("while", block[[2]]))
  code_str <- styler::style_text(code_str)
  code_str[length(code_str)] <- sub(" NULL$","", code_str[length(code_str)])
  if(length(code_str) == 1) code_str <- c(code_str, "\u2800")
  code_str <- paste("\u2800", code_str, "\u2800", collapse = "\n")
  code_str <- sub(" \\{ \u2800\\n\u2800   NULL \u2800\\n\u2800 \\} \u2800", "", code_str)

  # add node for `while`
  data <- add_node(
    data,
    id,
    block_type = "while",
    #code = block, #as.list(block[[2]]),
    code_str = code_str,
    label = attr(block, "label"))

  # add edge from while node to block
  data <- add_edge(data, from = id, to = id + 1)

  # build data from while's "body"
  while_expr = block[[3]]
  data <-  add_data_from_expr(data, while_expr, narrow = narrow)

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
