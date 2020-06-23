# add_data <- function(x, y){
#   list(
#     nodes = rbind(x$nodes, y$nodes),
#     edges = rbind(x$edges, y$edges)
#   )
# }

get_last_id <- function(data) {
  if(!nrow(data$nodes)) return(0)
  max(data$nodes$id) # data$nodes$id[nrow(data$nodes)]
}

add_node <- function(data, id, block_type = "standard", code = substitute(), code_str = "", label = ""){
  node <- data.frame(id, block_type, code_str, stringsAsFactors = FALSE, label = label)
  node$code <- list(code)
  data$nodes <- rbind(data$nodes, node)
  data
}

# new_node <- function(id, block_type = "standard", code = substitute(), code_str = ""){
#   node <- data.frame(id, block_type, code_str, stringsAsFactors = FALSE)
#   node$code <- list(code)
#   node
# }


add_edge <- function(data, to, from = to, edge_label = "", arrow = "->"){
  edge <- data.frame(from , to, edge_label, arrow, stringsAsFactors = FALSE)
  data$edges <- rbind(data$edges, edge)
  data
}


# new_edge <- function(to, from = to-1L, edge_label = "", arrow = "->"){
#   data.frame(from , to, edge_label, arrow, stringsAsFactors = FALSE)
# }

# remove_last_edge <- function(data){
#   data$edges <- head(data$edges, -1)
# }



rleid <- function(x){
  with(rle(x), rep(seq_along(lengths), lengths))
}

deparse2 <- function(x){
  x <- as.call(c(quote(`{`),x))
  x <- deparse(x)
  #if (x[1] == "{"){
  x <- x[-c(1, length(x))]
  x <- sub("^    ","",x)
  #}
  paste(x, collapse= "\n")
}



`%call_in%` <- function(calls, constructs){
  sapply(as.list(calls), function(x)
    is.call(x) && as.character(x[[1]]) %in% constructs)
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


get_last_call_type <- function(expr){
  if(is.call(expr) && identical(expr[[1]], quote(`{`))){
    expr <- expr[[length(expr)]] # could be a call or a symbol
  }
  if(is.call(expr))
    deparse(expr[[1]])
  else
    "standard"
}

find_funs <- function(call){
  env <- new.env()
  env$funs <- list()
  find_funs0 <- function(x, env){
    #print(x)
    if(!is.call(x)) return(invisible())
    if(identical(x[[1]], quote(`function`))){
      env$funs <- append(env$funs, x)
    }
    lapply(x, find_funs0, env)
  }
  if(is.function(call)) call <- body(call)
  find_funs0(call, env)
  env$funs
}


#
# debugged <- function(n = 0){
#   fun_sym <- eval.parent(quote(match.call()), n +1)[[1]]
#   eval.parent(
#     substitute(isdebugged(FUN), list(FUN = fun_sym)),
#     n = n + 2)
# }
#
# # controlflow ops with the addition of `#()` used to spot special comments
# control_flow_ops <- c("if", "for", "while", "repeat", "#")
#
# is_cfc_call <- function(x){
#   is.call(x) && as.character(x[[1]]) %in% control_flow_ops
# }
