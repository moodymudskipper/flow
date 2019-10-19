
update_data_with_standard_block <- function(data, block, id){
  code_str <- paste(unlist(sapply(as.list(block), deparse)), collapse=";")
  data <- add_node(data, new_node(
    id,
    block_type = "none",
    code = block,
    code_str = code_str)
  )
  data <- add_edge(data, new_edge(to = id))
  data
}

update_data_with_commented_block <- function(data, block, id){
  code_str <- paste(unlist(sapply(as.list(block), deparse)), collapse=";")
  data <- add_node(data, new_node(
    id,
    block_type = "commented",
    code = block,
    code_str = code_str)
  )
  data <- add_edge(data, new_edge(to = id))
  data
}

update_data_with_if_block <- function(data, block, id){

  # add IF node
  data <- add_node(data, new_node(
    id, "if", code = block[[c(1,2)]],
    code_str = sprintf("if (%s)", deparse2(block[[c(1,2)]]))))

  # add edge TO IF node
  data <- add_edge(data, new_edge(to = id))

  # build data from "yes" expression
  yes_expr <- block[[c(1 ,3)]]
  yes_data <-  build_data(yes_expr, id + 1)

  # label first edge
  yes_data$edges$edge_label[1] <- "y"

  # combine data
  data <- add_data(data, yes_data)

  #
  id_last_yes <- get_last_id(data)

  if(length(block[[1]]) == 4){
    # if there is an `else` statement

    # build data from "no" expression
    no_expr <- block[[c(1 ,4)]]
    no_data <-  build_data(no_expr, id_last_yes + 1)

    # first edge needs to be corrected so it comes from if node
    no_data$edges$from[1] <- id
    no_data$edges$edge_label[1] <- "n"
    data <- add_data(data, no_data)

    id_last_no <- get_last_id(data)
    id_end <- id_last_no + 1

    # link end of last no to end
    data <- add_edge(data, new_edge(from = id_last_no, to = id_end))

  } else {
    # there is no else, so link if to end
    id_end <- id_last_yes + 1
    # link end of if to end
    data <- add_edge(data, new_edge(from = id, to = id_end, edge_label = "n"))
  }

  # link end of yes to end
  data <- add_edge(data, new_edge(from = id_last_yes, to = id_end))

  # add the end node
  data <- add_node(data, new_node(id_end, "end"))

  data
}

update_data_with_for_block <- function(data, block, id){
  #browser()


  # add node for `for` statement
  code_str = sprintf(
    "for (%s in %s)",
    deparse2(block[[1]][[2]]),
    deparse2(block[[1]][[3]]))

  data <- add_node(data,new_node(
    id, "for",
    code = as.list(block[[1]][2:3]),
    code_str = code_str))

  # add edge to `for` statement
  data <- add_edge(data,new_edge(id))

  # build data from for's "body"
  for_expr <- block[[c(1 ,4)]] # the 4th item contains the code
  for_data <-  build_data(for_expr, id + 1)
  data <- add_data(data, for_data)

  id_end <- get_last_id(data) + 1
  # add the end node
  data <- add_node(data, new_node(id_end, "end"))

  # link end of for to end
  data <- add_edge(data, new_edge(id_end))

  # add loop edge
  data <- add_edge(
    data, new_edge(from = id, to = id_end, edge_label = "next", arrow = "<-"))

  data
}

update_data_with_while_block <- function(data, block, id){
  #browser()
  # add node for `while`
  data <- add_node(data, new_node(
    id,
    block_type = "while",
    code = as.list(block[[1]][[2]]),
    code_str = sprintf("while (%s)", deparse2(block[[1]][[2]]))))

  # add edge to while node
  data <- add_edge(data, new_edge(id))


  # build data from while's "body"
  while_expr = block[[c(1 ,3)]]
  while_data <-  build_data(while_expr, id + 1)
  data <- add_data(data, while_data)

  id_end <- get_last_id(data) + 1

  # add the end node
  data <- add_node(data, new_node(id_end, "end"))

  # link end of for to end
  data <- add_edge(data, new_edge(id_end))

  # add loop
  data <- add_edge(data, new_edge(from = id, to = id_end ,edge_label = "next", arrow = "<-"))

  data
}

update_data_with_repeat_block <- function(data, block, id){

  # add repeat node
  data <- add_node(data, new_node(
    id,
    block_type = "repeat",
    code = as.list(block[[1]][[1]]),
    code_str = "repeat"))

  # add edge to repeat node
  data <- add_edge(data, new_edge(to = id))

  # build data from repeat's "body"
  repeat_expr <- block[[c(1 ,2)]]
  repeat_data <-  build_data(repeat_expr, id + 1)
  data <- add_data(data, repeat_data)

  id_end <- get_last_id(data) + 1

  # add the end node
  data <- add_node(data, new_node(id_end, "end"))

  # link end of repeat to end
  data <- add_edge(data, new_edge(id_end))

  # add loop
  data <- add_edge(data, new_edge(
    from = id, to = id_end ,edge_label = "next", arrow = "<-"))

  data
}
