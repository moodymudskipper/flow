add_data_from_if_block <- function(data, block, narrow = FALSE){

  ## add data from if header and yes branch

  # increment node id into head node id
  id_if <- get_last_id(data) + 1 # might be suboptimal efficiency wise

  # define end node id as negative of head node id
  id_end <- -id_if

  # define yes node id as incremented head node id
  id_yes <- id_if + 1


  # build string to display in if node
  code_str <- robust_deparse(call("if", block[[2]]))
  code_str <- styler::style_text(code_str)
  code_str[length(code_str)] <- sub(" NULL$","", code_str[length(code_str)])
  indenter <- getOption("flow.indenter")
  if(length(code_str) == 1) code_str <- c(code_str, indenter)
  code_str <- paste(indenter, code_str, indenter, collapse = "\n")
  code_str <- sub(sprintf(
    " \\{ %s\\n%s   NULL %s\\n%s \\} %s",
    indenter, indenter, indenter, indenter, indenter),
    "", code_str)


  # add IF node and edge from IF node to yes branch
  data <- add_node(
    data,
    id_if,
    "if",
    #code = block[[2]],
    code_str = code_str,
    label = attr(block, "label"))

  data <- add_edge(data, from = id_if, to = id_yes, edge_label = "y")

  # build data from "yes" expression
  yes_expr <- block[[3]]
  data <-  add_data_from_expr(data, yes_expr, narrow = narrow)

  # end of yes will not be linked to incremented
  # node id but either to stop/return/ or end of if

  # fetch last node id of yes branch
  id_last_yes <- get_last_id(data)

  # assess what was the last call type
  last_call_type <- get_last_call_type(yes_expr)

  ## was the last call of yes branch a `stop` or `return` ?
  if (last_call_type %in% c("stop", "return")) {  ##, "next", "break")) {
    ## add exit node and update last edge
    data <- add_node(data, -id_last_yes, block_type = last_call_type)
    data$edges$to[nrow(data$edges)] <- -id_last_yes
    yes_stopped <- TRUE
  } else {
    ## is the yes branch a dead end through a nested if call ?
    if (last_call_type == "if" && with(data$edges,(to + from)[length(to)] == 0)) {
      # note : last condition means that we finished on a dead end
      # if yes branch is dead end
      ## remove last edge
      data$edges <- head(data$edges, -1)
      yes_stopped <- TRUE
    } else {
      ## update last edge
      data$edges$to[nrow(data$edges)] <- id_end
      ## flag the yes branch as NOT stopped
      yes_stopped <- FALSE
    }
  }

  ## do we have a no branch ?
  if (length(block) == 4) {
    ## add data from no branch

    # define first node id of no branch
    id_no <- id_last_yes + 1

    # add edge from IF node to no branch
    data <- add_edge(data, from = id_if, to = id_no, edge_label = "n")

    # build data from "no" expression
    no_expr <- block[[4]]
    data <-  add_data_from_expr(data, no_expr, narrow = narrow)

    # end of no will not be linked to incremented
    # node id but either to stop/return/ or end of if

    # fetch last node id of yes branch
    id_last_no <- get_last_id(data)

    # assess what was the last call type
    last_call_type <- get_last_call_type(no_expr)

    ## was the last call of no branch a `stop` or `return` ?
    if (last_call_type %in% c("stop", "return")) {
      ## add exit node and update last edge
      data <- add_node(data, -id_last_no, block_type = last_call_type)
      data$edges$to[nrow(data$edges)] <- -id_last_no
      no_stopped <- TRUE
    } else {
      ## is the no branch a dead end through a nested if call ?
      if (last_call_type == "if" && with(data$edges,(to + from)[length(to)] == 0)) {
        ## remove last edge
        data$edges <- head(data$edges, -1)
        no_stopped <- TRUE
      } else {
        ## update last edge
        data$edges$to[nrow(data$edges)] <- id_end
        no_stopped <- FALSE
      }
    }

    ## is narrow TRUE ?
    if (narrow) {
      ## was the yes branch stopped ?
      if (yes_stopped && !no_stopped) {
        ## add an invisible edge from exit node to end node
        data <- add_edge(data, from = -id_last_yes, to = id_end, arrow = "-/-")
      }

      ## was the no branch stopped ?
      if (no_stopped && !yes_stopped) {
        ## add an invisible edge from exit node to end node
        data <- add_edge(data, from = -id_last_no, to = id_end, arrow = "-/-")
      }
    }
  } else {
    ## add edge from head node to end node
    data <- add_edge(data, from = id_if, to = id_end, edge_label = "n")
    no_stopped <- FALSE

    ## was the yes branch stopped and narrow is TRUE?
    if (yes_stopped && narrow) {
      ## add an invisible edge from exit node to end node
      data <- add_edge(data, from = -id_last_yes, to = id_end, arrow = "-/-")
    }
  }

  ## were both branch unstopped ?
  if (!yes_stopped || !no_stopped) {
    ## add end node and edge to next node
    # materialize end_node
    data <- add_node(data, id_end, "end")
    # add edge from the end node to the next block
    id_next <- get_last_id(data) + 1
    data <- add_edge(data, from = id_end, to = id_next)
  }

  ## return updated data
  data
}
