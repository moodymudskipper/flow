add_data_from_if_block <- function(data, block, narrow = FALSE){

  ## define head node id, end node id, and first node id of yes branch

  # increment node id into head node id
  id_if <- get_last_id(data) + 1 # might be suboptimal efficiency wise

  # define end node id as negative of head node id
  id_end <- -id_if

  # define yes node id as incremented head node id
  id_yes <- id_if + 1


  ## build string to display in if node
  code_str <- sprintf("if (%s)", deparse2(block[[2]]))
  code_str <- gsub("||","||\n", code_str,fixed = TRUE)
  code_str <- gsub("&&","&&\n", code_str,fixed = TRUE)

  ## add IF node and edge from IF node to yes branch
  data <- add_node(
    data,
    id_if,
    "if",
    code = block[[2]],
    code_str = code_str,
    label = attr(block, "label"))

  data <- add_edge(data, from = id_if, to = id_yes, edge_label = "y")

  ## build data from "yes" expression
  yes_expr <- block[[3]]
  data <-  add_data_from_expr(data, yes_expr, narrow = narrow)

  # end of yes will not be linked to incremented
  # node id but either to stop/return/ or end of if

  ## fetch last node id of yes branch
  id_last_yes <- get_last_id(data)

  ## assess what was the last call type
  last_call_type <- get_last_call_type(yes_expr)

  ## was the last call of yes branch a `stop` or `return` ?
  if (last_call_type %in% c("stop", "return")) {  ##, "next", "break")) {
    ## add an exit node to the branch
    data <- add_node(data, -id_last_yes, block_type = last_call_type)
    ## modify last edge so it goes to this exit node
    data$edges$to[nrow(data$edges)] <- -id_last_yes
    ## flag the yes branch as stopped
    yes_stopped <- TRUE
  } else {
    ## is the yes branch a dead end through a nested if call ?
    if (last_call_type == "if" && with(data$edges,(to + from)[length(to)] == 0)) {
      # note : last condition means that we finished on a dead end
      # if yes branch is dead end
      ## remove last edge as we're in a dead end
      data$edges <- head(data$edges, -1)
      ## flag the yes branch as stopped
      yes_stopped <- TRUE
    } else {
      ## modify last edge so it goes to this end node
      data$edges$to[nrow(data$edges)] <- id_end
      ## flag the yes branch as NOT stopped
      yes_stopped <- FALSE
    }
  }

  ## do we have a no branch ?
  if (length(block) == 4) {
    ## define first node id of no branch
    id_no <- id_last_yes + 1

    ## add edge from IF node to no branch
    data <- add_edge(data, from = id_if, to = id_no, edge_label = "n")

    ## build data from "no" expression
    no_expr <- block[[4]]
    data <-  add_data_from_expr(data, no_expr, narrow = narrow)

    # end of no will not be linked to incremented
    # node id but either to stop/return/ or end of if

    ## fetch last node id of yes branch
    id_last_no <- get_last_id(data)

    ## assess what was the last call type
    last_call_type <- get_last_call_type(no_expr)

    ## was the last call of yes branch a `stop` or `return` ?
    if (last_call_type %in% c("stop", "return")) {
      ## add an exit node to the branch
      data <- add_node(data, -id_last_no, block_type = last_call_type)
      ## modify last edge so it goes to this exit node
      data$edges$to[nrow(data$edges)] <- -id_last_no
      ## flag the no branch as stopped
      no_stopped <- TRUE
    } else {
      ## is the no branch a dead end through a nested if call ?
      if (last_call_type == "if" && with(data$edges,(to + from)[length(to)] == 0)) {
        ## remove last edge as we're in a dead end
        data$edges <- head(data$edges, -1)
        ## flag the no branch as stopped
        no_stopped <- TRUE
      } else {
        ## modify last edge so it goes to this end node
        data$edges$to[nrow(data$edges)] <- id_end
        ## flag the no branch as NOT stopped
        no_stopped <- FALSE
      }
    }

    if (narrow) {
      if (yes_stopped && !no_stopped) {
        data <- add_edge(data, from = -id_last_yes, to = id_end, arrow = "-/-")
      }

      if (no_stopped && !yes_stopped) {
        data <- add_edge(data, from = -id_last_no, to = id_end, arrow = "-/-")
      }
    }
  } else {
    # add edge from IF node to end node
    data <- add_edge(data, from = id_if, to = id_end, edge_label = "n")
    no_stopped <- FALSE

    if (yes_stopped && narrow) {
      data <- add_edge(data, from = -id_last_yes, to = id_end, arrow = "-/-")
    }
  }

  is_dead_end <- yes_stopped && no_stopped

  if (!is_dead_end) {
    # materialize end_node
    data <- add_node(data, id_end, "end")
    # add edge from the end node to the next block
    id_next <- get_last_id(data) + 1
    data <- add_edge(data, from = id_end, to = id_next)
  }

  data
}
