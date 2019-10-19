rbind_dfs <- function(x, y){
  list(
    nodes = rbind(x$nodes, y$nodes),
    edges = rbind(x$edges, y$edges)
  )
}


new_node <- function(id, block_type = "standard", code = substitute(), code_str = ""){
  node <- data.frame(id, block_type, code_str, stringsAsFactors = FALSE)
  node$code <- list(code)
  node
}

new_edge <- function(to, from = to-1L, edge_label = "", arrow = "->"){
  data.frame(from , to, edge_label, arrow, stringsAsFactors = FALSE)
}

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
