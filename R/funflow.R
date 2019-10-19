
view_flow <- function(f, prefix = NULL, ...){
  nodes <- new_node(1L, "header", code = substitute(f), code_str =
                      deparse(substitute(f)))
  edges <- new_edge(integer(0),integer(0),character(0),character(0)) # empty edge df
  # put comments in `#`() calls
  f <- add_comment_calls(f, prefix)
  # build data from the function body
  data <- build_data(body(f),1)
  # join to header
  data <- rbind_dfs(list(nodes = nodes, edges = edges), data)
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

# new_nodes <- function() {
#   data.frame(
#     id=integer(0),
#     label = character(0),
#     block_type =character(0),
#     stringsAsFactors = FALSE)
# }
#
# new_edges <- function(){
#   data.frame(
#     from =character(0),
#     to = character(0))
# }

new_dfs <- function(){
  dfs <- list(
    nodes = data.frame(
      id=integer(0),
      block_type =character(0),
      stringsAsFactors = FALSE),
    edges = data.frame(
      from =integer(0),
      to = integer(0),
      edge_label = character(0))
  )
  dfs$nodes$code <- list()
  dfs
}

build_data <-  function(fun_body, id){
  #browser()
  blocks <- build_blocks(fun_body)

  # nodes <- new_nodes()
  # edges <- new_edges()
  dfs <- new_dfs()

  for (i in seq_along(blocks)){
    # dfs might have been just initiated, in which case we use id arg
    # else use max id from node df
    id <- max(dfs$nodes$id,id) +1
    block <- blocks[[i]]
    block_type <- attr(block, "block_type")
    if (is.null(block_type)){
      dfs <- update_dfs_with_standard_block(dfs, block, id)
    } else if (block_type == "commented"){
      dfs <- update_dfs_with_commented_block(dfs, block, id)
    } else if (block_type == "if"){
      dfs <- update_dfs_with_if_block(dfs, block, id)
    } else if (block_type == "for"){
      dfs <- update_dfs_with_for_block(dfs, block, id)
    } else if (block_type == "while"){
      dfs <- update_dfs_with_while_block(dfs, block, id)
    } else if (block_type == "repeat"){
      dfs <- update_dfs_with_repeat_block(dfs, block, id)
    }
  }
  dfs
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



