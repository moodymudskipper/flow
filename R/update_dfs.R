
update_dfs_with_standard_block <- function(dfs, block, id){
  code_str <- paste(unlist(sapply(as.list(block), deparse)), collapse=";")
  new_dfs <- list(
    nodes = new_node(
      id,
      block_type = "none",
      code = block,
      code_str = code_str),
    edges = new_edge(
      to = id)
    )
  rbind_dfs(dfs, new_dfs)
}

update_dfs_with_commented_block <- function(dfs, block, id){
  code_str <- paste(unlist(sapply(block[-1], deparse)), collapse=";")
  new_dfs <- list(
    nodes = new_node(
      id,
      block_type = "commented",
      code = block,
      code_str = code_str),
    edges = new_edge(
      to = id))
  rbind_dfs(dfs, new_dfs)
}

update_dfs_with_if_block <- function(dfs, block, id){

  node_if <- new_node(
    id, "if", code = block[[c(1,2)]],
    code_str = sprintf("if (%s)", deparse2(block[[c(1,2)]])))
  edge_if_previous <- new_edge(to = id)
  dfs <- rbind_dfs(dfs, list(nodes = node_if, edges = edge_if_previous))

  # build dfs from "yes" expression
  yes_dfs <-  build_data(block[[c(1 ,3)]], id)
  yes_dfs$edges$edge_label[1] <- "y"

  dfs <- rbind_dfs(dfs, yes_dfs)

  id_last_yes <- tail(dfs$nodes$id, 1)

  if(length(block[[1]]) == 4){
    # build dfs from "no" expression
    no_dfs <-  build_data(block[[c(1 ,4)]], id_last_yes)

    # first edge needs to be corrected so it comes from if node
    no_dfs$edges$from[1] <- id
    no_dfs$edges$edge_label[1] <- "n"
    dfs <- rbind_dfs(dfs, no_dfs)

    id_last_no <- tail(dfs$nodes$id, 1)
    id_end <- id_last_no + 1

    # link end of last no to end
    edge_no_end <- new_edge(from = id_last_no, to = id_end)

    dfs$edges <- rbind(dfs$edges, edge_no_end)
  } else {
    # there is no else, so link if to end
    id_end <- id_last_yes + 1
    # link end of if to end
    edge_if_end <- new_edge(from = id, to = id_end, edge_label = "n")

    dfs$edges <- rbind(dfs$edges, edge_if_end)
  }

  # link end of yes to end
  edge_yes_end <- new_edge(from = id_last_yes, to = id_end)

  # add the end node
  end_node <- new_node(id_end, "end")

  dfs <- rbind_dfs(dfs, list(nodes = end_node, edges = edge_yes_end))
  dfs
}

update_dfs_with_for_block <- function(dfs, block, id){
  #browser()
  node_for <- new_node(
    id, "for",
    code = as.list(block[[1]][2:3]),
    code_str = sprintf(
      "for (%s in %s)",
      deparse2(block[[1]][[2]]),
      deparse2(block[[1]][[3]])))

  edge_for_previous <- new_edge(id)


  new_dfs <- list(nodes = node_for, edges = edge_for_previous)
  dfs <- rbind_dfs(dfs, new_dfs)

  # build dfs from for's "body"
  for_dfs <-  build_data(block[[c(1 ,4)]], id)
  dfs <- rbind_dfs(dfs, for_dfs)

  id_end <- tail(dfs$nodes$id,1) + 1
  # add the end node
  end_node <- new_node(id_end, "end")

  # link end of for to end
  edge_for_end <- new_edge(id_end)

  dfs <- rbind_dfs(dfs, list(nodes= end_node, edges = edge_for_end))

  # add loop
  edge_for_back <- new_edge(from = id, to = id_end ,edge_label = "next", arrow = "<-")

  dfs$edges <- rbind(dfs$edges, edge_for_back)

  dfs
}

update_dfs_with_while_block <- function(dfs, block, id){
  #browser()
  node_while <- new_node(id, "while",
                       code = as.list(block[[1]][[2]]),
                       code_str = sprintf("while (%s)", deparse2(block[[1]][[2]])))
  edge_for_previous <- new_edge(id)


  new_dfs <- list(nodes = node_while, edges = edge_for_previous)
  dfs <- rbind_dfs(dfs, new_dfs)

  # build dfs from while's "body"
  for_dfs <-  build_data(block[[c(1 ,3)]], id)
  dfs <- rbind_dfs(dfs, for_dfs)

  id_end <- tail(dfs$nodes$id,1) + 1
  # add the end node
  end_node <- new_node(id_end, "end")

  # link end of for to end
  edge_for_end <- new_edge(id_end)

  dfs <- rbind_dfs(dfs, list(nodes= end_node, edges = edge_for_end))

  # add loop
  edge_for_back <- new_edge(from = id, to = id_end ,edge_label = "next", arrow = "<-")

  dfs$edges <- rbind(dfs$edges, edge_for_back)

  dfs
}



update_dfs_with_repeat_block <- function(dfs, block, id){
  node_repeat <- new_node(id, "repeat",
                         code = as.list(block[[1]][[1]]),
                         code_str = "repeat")
  edge_for_previous <- new_edge(id)


  new_dfs <- list(nodes = node_repeat, edges = edge_for_previous)
  dfs <- rbind_dfs(dfs, new_dfs)

  # build dfs from while's "body"
  for_dfs <-  build_data(block[[c(1 ,2)]], id)
  dfs <- rbind_dfs(dfs, for_dfs)

  id_end <- tail(dfs$nodes$id,1) + 1
  # add the end node
  end_node <- new_node(id_end, "end")

  # link end of for to end
  edge_for_end <- new_edge(id_end)

  dfs <- rbind_dfs(dfs, list(nodes= end_node, edges = edge_for_end))

  # add loop
  edge_for_back <- new_edge(from = id, to = id_end ,edge_label = "next", arrow = "<-")

  dfs$edges <- rbind(dfs$edges, edge_for_back)

  dfs
}
