build_data <-  function(fun_body, id){
  #browser()
  blocks <- build_blocks(fun_body)

  # nodes <- new_nodes()
  # edges <- new_edges()
  data <- new_data()

  for (i in seq_along(blocks)){
    # data might have been just initiated, in which case we use id arg
    # else use max id from node df
    id <- max(data$nodes$id,id) +1
    block <- blocks[[i]]
    block_type <- attr(block, "block_type")
    if (is.null(block_type)){
      data <- update_data_with_standard_block(data, block, id)
    } else if (block_type == "commented"){
      data <- update_data_with_commented_block(data, block, id)
    } else if (block_type == "if"){
      data <- update_data_with_if_block(data, block, id)
    } else if (block_type == "for"){
      data <- update_data_with_for_block(data, block, id)
    } else if (block_type == "while"){
      data <- update_data_with_while_block(data, block, id)
    } else if (block_type == "repeat"){
      data <- update_data_with_repeat_block(data, block, id)
    }
  }
  data
}
