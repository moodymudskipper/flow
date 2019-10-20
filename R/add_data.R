# reboot of build data
add_data_from_expr <-  function(data, expr){
  blocks <- build_blocks(expr)
  for (i in seq_along(blocks)){
    block <- blocks[[i]]
    block_type <- attr(block, "block_type")
    if (is.null(block_type)){
      data <- add_data_from_standard_block(data, block)
    } else if (block_type == "commented"){
      data <- add_data_from_commented_block(data, block)
    } else if (block_type == "if"){
      data <- add_data_from_if_block(data, block[[1]])
    } else if (block_type == "for"){
      data <- add_data_from_for_block(data, block[[1]])
    } else if (block_type == "while"){
      data <- add_data_from_while_block(data, block[[1]])
    } else if (block_type == "repeat"){
      data <- add_data_from_repeat_block(data, block[[1]])
    }
  }
  data
}


#' Title
#'
#' @param data flow chart data
#' @param block code block
#'
#' @return
#' @export
#'
#' @examples
add_data_from_standard_block <- function(data, block){
  # increment id
  id <-get_last_id(data) + 1
  # build code string to display in node
  code_str <- paste(unlist(sapply(as.list(block), deparse)), collapse=";")
  # add current node
  data <- add_node(
    data,
    id,
    block_type = "none",
    code = block,
    code_str = code_str)
  # draw edge from current node to next (yet undefined) node
  data <- add_edge(data, from = id, to = id + 1)
  data
}


add_data_from_commented_block <- function(data, block){
  # increment id
  id <-get_last_id(data) + 1
  # build code string to display in node
  code_str <- paste(unlist(sapply(as.list(block), deparse)), collapse=";")
  # add current node
  data <- add_node(
    data,
    id,
    block_type = "commented",
    code = block,
    code_str = code_str)
  # draw edge from current node to next (yet undefined) node
  data <- add_edge(data, from = id, to = id + 1)
  data
}


add_data_from_if_block <- function(data, block){
  # increment id
  id <-get_last_id(data) + 1
  # build code string to display in node
  code_str <- sprintf("if (%s)", deparse2(block[[2]]))
  # add IF node
  data <- add_node(
    data,
    id,
    "if",
    code = block[[2]],
    code_str = code_str)

  # add edge from IF node to yes branch
  data <- add_edge(data, from=id, to = id + 1,edge_label = "y")

  # build data from "yes" expression
  yes_expr <- block[[3]]
  data <-  add_data_from_expr(data, yes_expr)

  id_last_yes <- get_last_id(data)

  if(is.call(yes_expr) && identical(yes_expr[[1]], quote(`{`))){
    last_call <- yes_expr[[length(yes_expr)]] # could be a call or a symbol
  } else {
    last_call <- yes_expr
  }

  if(is.call(last_call) && deparse(last_call[[1]]) %in% c("stop", "return")){
    # if yes branch ends with a stop or return call
    data <- add_node(data, id_last_yes + 1, block_type = deparse(last_call[[1]]))
    id_last_yes <- id_last_yes + 1
    yes_stopped <- TRUE
  } else if (data$nodes$block_type[nrow(data$nodes)] %in% c("stop", "return")) {
    # if yes branch is dead end
    yes_stopped <- TRUE
  } else {
    # if yes branch is regular we must remove the last edge, as the end of
    # yes branch will go to the next step, not to the start of the no branch
    data$edges <- head(data$edges, -1)
    yes_stopped <- FALSE
  }

  if(length(block) == 4){
    # if there is an `else` statement

    # add edge from IF node to no branch
    data <- add_edge(data, from=id, to = id_last_yes + 1, edge_label = "n")

    # build data from "no" expression
    no_expr <- block[[4]]
    data <-  add_data_from_expr(data, no_expr)

    id_last_no <- get_last_id(data)
    if(is.call(no_expr) && identical(no_expr[[1]], quote(`{`))){
      last_call <- no_expr[[length(no_expr)]] # could be a call or a symbol
    } else {
      last_call <- no_expr
    }

    if(is.call(last_call) && deparse(last_call[[1]]) %in% c("stop", "return")){
      data <- add_node(data, id_last_no + 1, block_type = deparse(last_call[[1]]))
      id_end <- id_last_no + 2
      no_stopped <- TRUE
    } else {
      id_end <- id_last_no + 1
      no_stopped <- FALSE
    }

  } else {
    # there is no else, so link if to end
    id_end <- id_last_yes + 1

    # link end of if to start of if
    data <- add_edge(data, from = id, to = id_end, edge_label = "n")
  }

  if(!yes_stopped){
  # link end of yes to end
  data <- add_edge(data, from = id_last_yes, to = id_end)
  }

  # # add the end node
  # data <- add_node(data, id_end, "end")
  #
  # # add edge from the end node to the next block
  # data <- add_edge(data, from = id_end, to = id_end + 1)

  data
}


add_data_from_for_block <- function(data, block, id){
  # increment id
  id <-get_last_id(data) + 1

  # add node for `for` statement
  code_str = sprintf(
    "for (%s in %s)",
    deparse2(block[[2]]),
    deparse2(block[[3]]))

  data <- add_node(
    data,
    id, "for",
    code = as.list(block[2:3]),
    code_str = code_str)

  # add edge from `for` statement
  data <- add_edge(data, from = id, to = id + 1)

  # build data from for's "body"
  for_expr <- block[[4]] # the 4th item contains the code
  data <-  add_data_from_expr(data, for_expr)

  # add the end node
  id_last_for <- get_last_id(data)
  id_end <- id_last_for + 1
  data <- add_node(data, id_end, "start")

  # add loop edge
  data <- add_edge(data, from = id, to = id_end, edge_label = "next", arrow = "<-")

  # link end to next block
  data <- add_edge(data, from= id_end, to = id_end+1)


  data
}




add_data_from_while_block <- function(data, block){
  # increment id
  id <-get_last_id(data) + 1

  # add node for `while`
  data <- add_node(
    data,
    id,
    block_type = "while",
    code = as.list(block[[2]]),
    code_str = sprintf("while (%s)", deparse2(block[[2]])))

  # add edge from while node to block
  data <- add_edge(data, from = id, to = id + 1)

  # build data from while's "body"
  while_expr = block[[3]]
  while_data <-  add_data_from_expr(data, while_expr)

  # add the end node
  id_last_while <- get_last_id(data)
  id_end <- id_last_while + 1
  data <- add_node(data, id_end, "start")

  # add loop edge
  data <- add_edge(data, from = id, to = id_end, edge_label = "next", arrow = "<-")

  # link end to next block
  data <- add_edge(data, from= id_end, to = id_end+1)
}

add_data_from_repeat_block <- function(data, block, id){
  # increment id
  id <-get_last_id(data) + 1

  # add repeat node
  data <- add_node(
    data,
    id,
    block_type = "repeat",
    code = as.list(block[[1]][[1]]),
    code_str = "repeat")

  # add edge from repeat node to block
  data <- add_edge(data, to = id)

  # build data from repeat's "body"
  repeat_expr <- block[[2]]
  data <-  add_data_from_expr(data, repeat_expr)

  # add the end node
  id_last_repeat <- get_last_id(data)
  id_end <- id_last_repeat + 1
  data <- add_node(data, id_end, "start")

  # add loop edge
  data <- add_edge(data, from = id, to = id_end, edge_label = "next", arrow = "<-")

  # link end to next block
  data <- add_edge(data, from= id_end, to = id_end+1)

  data
}

