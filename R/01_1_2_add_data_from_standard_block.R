
add_data_from_standard_block <- function(data, block){
  ## increment node id
  id <- get_last_id(data) + 1

  ## is the block empty ?
  if (missing(block)) {
    ## add empty node
    data <- add_node(
      data,
      id,
      block_type = "standard",
      #code = substitute(),
      code_str = "")
  } else {
    ## build string to be displayed from block code
    code_str <- sapply(as.list(block), robust_deparse)
    code_str <- styler::style_text(code_str)
    code_str <- paste(code_str, collapse = "\n")
    ## add current node
    data <- add_node(
      data,
      id,
      block_type = "standard",
      #code = block,
      code_str = code_str,
      label = attr(block, "label"))
  }
  ## add edge from current node to next (yet undefined) node
  data <- add_edge(data, from = id, to = id + 1)

  ## return updated data
  data
}
