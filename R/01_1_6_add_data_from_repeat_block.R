
add_data_from_repeat_block <- function(data, block, narrow = FALSE){

  ## add data from `repeat` header and "body"

  # increment id
  id <- get_last_id(data) + 1
  id_end <- -id

  # add repeat node
  data <- add_node(
    data,
    id,
    block_type = "repeat",
    #code = block, #as.list(block[[1]]),
    code_str = "repeat",
    label = attr(block, "label"))

  # add edge from repeat node to block
  data <- add_edge(data, from = id, to = id + 1)

  # build data from repeat's "body"
  while_expr = block[[2]]
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

