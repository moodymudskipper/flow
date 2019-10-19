
view_flow <- function(f, prefix = NULL, ...){
  nodes <- new_node(1L, "header", code = substitute(f), code_str =
                      deparse(substitute(f)))
  edges <- new_edge(integer(0),integer(0),character(0),character(0)) # empty edge df
  # put comments in `#`() calls
  f <- add_comment_calls(f, prefix)
  # build data from the function body
  data <- build_data(body(f),1)
  # join to header
  data <- rbind_data(list(nodes = nodes, edges = edges), data)
  # temp, for display
  data$nodes$code <- sapply(data$nodes$code, function(x) {
    paste(unlist(sapply(x, deparse)), collapse="\n")
  })
  code <- build_nomnoml_code(data, ...)
  nomnoml::nomnoml(code)
}

build_blocks <- function(expr){
  # clean block from braces
  if(is.call(expr) && expr[[1]] == quote(`{`))
    calls <- as.list(expr[-1])
  else
    calls <- list(expr)
  # get logical indices of special calls
  cfc_lgl <- calls %call_in% c("if", "for", "while", "repeat")
  special_comment_lgl <- calls %call_in% c("#")
  # compute block indices
  block_ids <- interaction(
    cumsum(cfc_lgl) * cfc_lgl,
    cumsum(special_comment_lgl) * ! cfc_lgl)
  block_ids <- rleid(as.numeric(block_ids))
  # build blocks
  blocks <- split(calls, block_ids) # tapply(b, block_ids, deparse2)
  for (i in block_ids[cfc_lgl]) {
    attr(blocks[[i]], "block_type") <- as.character(blocks[[c(i,1,1)]])
  }
  for (i in block_ids[special_comment_lgl]) {
    attr(blocks[[i]], "block_type") <- "commented"
  }
  blocks
}

new_data <- function(){
  data <- list(
    nodes = data.frame(
      id=integer(0),
      block_type =character(0),
      stringsAsFactors = FALSE),
    edges = data.frame(
      from =integer(0),
      to = integer(0),
      edge_label = character(0))
  )
  data$nodes$code <- list()
  data
}

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

block_type <- function(x) {
  attr(blocks[[i]], "block_type")
}



# controlflow ops with the addition of `#()` used to spot special comments
control_flow_ops <- c("if", "for", "while", "repeat", "#")

is_cfc_call <- function(x){
  is.call(x) && as.character(x[[1]]) %in% control_flow_ops
}

`%call_in%` <- function(calls, constructs){
  sapply(as.list(calls), function(x)
    is.call(x) && as.character(x[[1]]) %in% constructs)
}

# add_comment_calls <- function(fun, prefix = "##"){
#   if(is.null(prefix)) return(fun)
#   fun <- deparse(fun, control = "useSource")
#   pattern <- sprintf("\\s*(%s.*)", prefix)
#   fun <- gsub(pattern,"`#`('\\1')", fun)
#   fun <- paste(fun, collapse = "\n")
#   eval(str2lang(fun))
# }



