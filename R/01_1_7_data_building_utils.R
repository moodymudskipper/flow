# function used through flow_data and aimed at building/updating the data object

new_data <- function(){
  ## create data as a list of 2 zero row data.frames with relevant columns
  data <- list(
    nodes = data.frame(
      id = integer(0),
      block_type = character(0),
      stringsAsFactors = FALSE),
    edges = data.frame(
      from = integer(0),
      to = integer(0),
      edge_label = character(0),
      stringsAsFactors = FALSE)
  )
  #data$nodes$code <- list()
  data
}

add_node <- function(data, id, block_type = "standard",
                     #code = substitute(),
                     code_str = "", label = ""){
  ## build one row data.frame containing given node data
  node <- data.frame(id, block_type, code_str, stringsAsFactors = FALSE, label = label)
  #node$code <- list(code)

  ## bind at end of node data
  data$nodes <- rbind(data$nodes, node)

  ## return updated data
  data
}

add_edge <- function(data, to, from = to, edge_label = "", arrow = "->"){
  ## build one row data.frame containing given edge data
  edge <- data.frame(from , to, edge_label, arrow, stringsAsFactors = FALSE)

  ## bind at end of edge data
  data$edges <- rbind(data$edges, edge)

  ## return updated data
  data
}
