# reboot of build data
add_data_from_expr <-  function(data, expr){
  blocks <- build_blocks(expr)
  for (i in seq_along(blocks)){
    id <- get_last_id(data)
    block <- blocks[[i]]
    if(missing(block)) # deal with empty expr (`{}`)
      block_type <- NULL
    else
      block_type <- attr(block, "block_type")
    if (is.null(block_type)){
      data <- add_data_from_standard_block(data, block)
    # } else if (block_type == "commented"){
    #   data <- add_data_from_commented_block(data, block)
    } else if (block_type == "if"){
      data <- add_data_from_if_block(data, block)
    } else if (block_type == "for"){
      data <- add_data_from_for_block(data, block)
    } else if (block_type == "while"){
      data <- add_data_from_while_block(data, block)
    } else if (block_type == "repeat"){
      data <- add_data_from_repeat_block(data, block)
    }
  }
  data
}

add_data_from_standard_block <- function(data, block){
  # increment id
  id <-get_last_id(data) + 1
  # build code string to display in node
  if(missing(block)) {
    data <- add_node(
      data,
      id,
      block_type = "standard",
      code = substitute(),
      code_str = "")
  } else {
  code_str <- trimws(paste(unlist(sapply(as.list(block), deparse)), collapse=";"))
  # add current node
  data <- add_node(
    data,
    id,
    block_type = "standard",
    code = block,
    code_str = code_str,
    label = attr(block, "label"))
  }
  # draw edge from current node to next (yet undefined) node
  data <- add_edge(data, from = id, to = id + 1)
  data
}


# add_data_from_commented_block <- function(data, block){
#   # increment id
#   id <-get_last_id(data) + 1
#   # build code string to display in node
#   code_str <- paste(unlist(sapply(as.list(block), deparse)), collapse=";")
#   # add current node
#   data <- add_node(
#     data,
#     id,
#     block_type = "commented",
#     code = block,
#     code_str = code_str,
#     label = attr(block, "label"))
#   # draw edge from current node to next (yet undefined) node
#   data <- add_edge(data, from = id, to = id + 1)
#   data
# }


add_data_from_if_block <- function(data, block){
  # increment id
  id_if <- get_last_id(data) + 1
  id_end <- -id_if
  id_yes <- id_if +1
  # build code string to display in node

  code_str <- sprintf("if (%s)", deparse2(block[[2]]))
  code_str <- gsub("||","||\n", code_str,fixed = TRUE)
  code_str <- gsub("&&","&&\n", code_str,fixed = TRUE)

  # add IF node
  data <- add_node(
    data,
    id_if,
    "if",
    code = block[[2]],
    code_str = code_str,
    label = attr(block, "label"))

  # add edge from IF node to yes branch
  data <- add_edge(data, from=id_if, to = id_yes, edge_label = "y")

  # build data from "yes" expression
  yes_expr <- block[[3]]
  data <-  add_data_from_expr(data, yes_expr)

  # end of yes will not be linked to incremented
  # node id but either to stop/return/ or end of if


  id_last_yes <- get_last_id(data)

  last_call_type <- get_last_call_type(yes_expr)

  if(last_call_type %in% c("stop", "return", "next", "break")){
    # if yes branch ends with a stop or return call
    data <- add_node(data, -id_last_yes, block_type = last_call_type)
    data$edges$to[nrow(data$edges)] <- -id_last_yes
    yes_stopped <- TRUE
  } else if (last_call_type == "if" && with(data$edges,(to+from)[length(to)] == 0)) {
    # note : last condition means that we finished on a dead end
    # if yes branch is dead end
    data$edges <- head(data$edges, -1)
     yes_stopped <- TRUE
  } else {
    # if yes branch is regular the end of yes branch will go to the end node,
    data$edges$to[nrow(data$edges)] <- id_end
    yes_stopped <- FALSE
  }

  if(length(block) == 4){
    # if there is an `else` statement
    id_no <- id_last_yes + 1

    # add edge from IF node to no branch
    data <- add_edge(data, from=id_if, to = id_no, edge_label = "n")

    # build data from "no" expression
    no_expr <- block[[4]]
    data <-  add_data_from_expr(data, no_expr)

    # end of no will not be linked to incremented
    # node id but either to stop/return/ or end of if


    id_last_no <- get_last_id(data)

    last_call_type <- get_last_call_type(no_expr)

    if(last_call_type %in% c("stop", "return")){
      # if yes branch ends with a stop or return call
      data <- add_node(data, -id_last_no, block_type = last_call_type)
      data$edges$to[nrow(data$edges)] <- -id_last_no
      no_stopped <- TRUE
    } else if (last_call_type == "if" && with(data$edges,(to+from)[length(to)] == 0)) {
      # note : last condition means that we finished on a dead end
      # if yes branch is dead end
      data$edges <- head(data$edges, -1)
      no_stopped <- TRUE
    } else {
      # if 'no' branch is regular the end of 'no' branch will go to the end node,
      data$edges$to[nrow(data$edges)] <- id_end
      no_stopped <- FALSE
    }
  } else {
    # add edge from IF node to end node
    data <- add_edge(data, from=id_if, to = id_end, edge_label = "n")
    no_stopped <- FALSE
  }

  is_dead_end <- yes_stopped && no_stopped

  if(!is_dead_end){
  # materialize end_node
    data <- add_node(data, id_end, "end")
    # add edge from the end node to the next block
    id_next <- get_last_id(data) + 1
    data <- add_edge(data, from = id_end, to = id_next)
  }

  data
}


add_data_from_for_block <- function(data, block, id){
  # increment id
  id <-get_last_id(data) + 1
  id_end <- -id
  # add node for `for` statement
  code_str = sprintf(
    "for (%s in %s)",
    deparse2(block[[2]]),
    deparse2(block[[3]]))

  data <- add_node(
    data,
    id, "for",
    code = as.list(block[2:3]),
    code_str = code_str,
    label = attr(block, "label"))

  # add edge from `for` statement
  data <- add_edge(data, from = id, to = id + 1)

  # build data from for's "body"
  for_expr <- block[[4]] # the 4th item contains the code
  data <-  add_data_from_expr(data, for_expr)

  # we edit last edge because last of loop
  # node id but to end
  data$edges$to[nrow(data$edges)] <- id_end

  # add the end node
  data <- add_node(data, id_end, "start")

  # add loop edge
  data <- add_edge(data, from = id, to = id_end, edge_label = "next", arrow = "<-")

  # link end to next block

  id_next <- get_last_id(data) + 1
  data <- add_edge(data, from= id_end, to = id_next)

  data
}




add_data_from_while_block <- function(data, block){
  # increment id
  id <-get_last_id(data) + 1
  id_end <- -id

  # add node for `while`
  data <- add_node(
    data,
    id,
    block_type = "while",
    code = as.list(block[[2]]),
    code_str = sprintf("while (%s)", deparse2(block[[2]])),
    label = attr(block, "label"))

  # add edge from while node to block
  data <- add_edge(data, from = id, to = id + 1)

  # build data from while's "body"
  while_expr = block[[3]]
  data <-  add_data_from_expr(data, while_expr)

  # we edit last edge because last of loop
  # node id but to end
  data$edges$to[nrow(data$edges)] <- id_end

  # add the end node
  data <- add_node(data, id_end, "start")

  # add loop edge
  data <- add_edge(data, from = id, to = id_end, edge_label = "next", arrow = "<-")

  # link end to next block

  id_next <- get_last_id(data) + 1
  data <- add_edge(data, from= id_end, to = id_next)

  data
}

add_data_from_repeat_block <- function(data, block, id){
  # increment id
  id <-get_last_id(data) + 1
  id_end <- -id

  # add repeat node
  data <- add_node(
    data,
    id,
    block_type = "repeat",
    code = as.list(block[[1]]),
    code_str = "repeat",
    label = attr(block, "label"))

  # add edge from repeat node to block
  data <- add_edge(data, from=id, to = id+1)

  # build data from repeat's "body"
  while_expr = block[[2]]
  data <-  add_data_from_expr(data, while_expr)

  # we edit last edge because last of loop
  # node id but to end
  data$edges$to[nrow(data$edges)] <- id_end

  # add the end node
  data <- add_node(data, id_end, "start")

  # add loop edge
  data <- add_edge(data, from = id, to = id_end, edge_label = "next", arrow = "<-")

  # link end to next block

  id_next <- get_last_id(data) + 1
  data <- add_edge(data, from= id_end, to = id_next)

  data
}

