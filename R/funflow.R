# note, only top level control-flow calls will be caught



# create a rounded block (header)

# create a rectangle block

# add calls to block until control-flow op is encountered

# when it's encountered a diamond is created

# we keep adding blocks

# depending
# on construct

#

funflow <- function(f){
  b <- body(f)
  nodes <- data.frame(
    id=1L,
    label = as.character(substitute(f)),
    construct = "header",
    stringsAsFactors = FALSE)
  edges <- data.frame(
    from = integer(0),
    to = integer(0))
  dfs <- build_dfs(b,1)
  nodes <- rbind(nodes, dfs$nodes)
  edges <- rbind(edges, dfs$edges)
  # nodes$id <- nodes$id + 1
  # edges[c("from","to")] <- edges[c("from","to")] + 1
  build_digraph(nodes, edges)
}

build_dfs <-  function(b, id){
  #browser()
  if(b[[1]] == quote(`{`))
    b <- as.list(b[-1])
  else
    b <- list(b)
  cfc_lgl <- sapply(b, first_is_cfc)
  block_ids <- cumsum(cfc_lgl) * cfc_lgl
  block_ids <- data.table::rleid(cfc_lgl)
  blocks <- split(b, block_ids) # tapply(b, block_ids, deparse2)
  for (i in block_ids[cfc_lgl]){
    attr(blocks[[i]], "construct") <- as.character(blocks[[c(i,1,1)]])
  }

  nodes <- data.frame(id=integer(0), label = character(0), construct =character(0),
                      stringsAsFactors = FALSE)
  edges <- data.frame(from =character(0), to = character(0))
  for (i in seq_along(blocks)){
    id <- max(nodes$id,id) +1
    block <- blocks[[i]]
    construct <- attr(block, "construct")
    if (is.null(construct)){

      node_i <- data.frame(
        id = id,
        label = deparse2(block),
        construct = "none",
        stringsAsFactors = FALSE
      )
      edge_i <- data.frame(
        from = id-1,
        to = id
      )
      nodes <- rbind(nodes, node_i)
      edges <- rbind(edges, edge_i)
    } else if (construct == "if"){

      node_if <- data.frame(
        id = id,
        label = sprintf("if (%s)", deparse2(block[[c(1,2)]])),
        construct = "if",
        stringsAsFactors = FALSE
      )
      edge_if_previous <- data.frame(
        from = id-1,
        to = id
      )
      nodes <- rbind(nodes, node_if)
      edges <- rbind(edges, edge_if_previous)

      # build dfs from "yes" expression
      yes_dfs <-  build_dfs(block[[c(1 ,3)]], id)
      nodes <- rbind(nodes, yes_dfs$nodes)
      edges <- rbind(edges, yes_dfs$edges)

      id_last_yes <- tail(nodes$id,1)
      if(length(block[[1]]) == 4){
        # build dfs from "no" expression
        no_dfs <-  build_dfs(block[[c(1 ,4)]], id_last_yes)
        # first edge needs to be corrected
        no_dfs$edges$from[1] <- id
        nodes <- rbind(nodes, no_dfs$nodes)
        edges <- rbind(edges, no_dfs$edges)

        # link end of yes to what follows
        edge_yes_next <- data.frame(
          from = id_last_yes,
          to = max(nodes$id) + 1)

        edges <- rbind(edges, edge_yes_next)
      } else {
        # link if to what follows
        edge_if_next <- data.frame(
          from = id,
          to = id_last_yes + 1)

        edges <- rbind(edges, edge_if_next)
      }

    } else if (construct == "for"){
      node_for <- data.frame(
        id = id,
        label = sprintf("for (%s in %s)",
                        deparse2(block[[c(1,2)]]),
                        deparse2(block[[c(1,3)]])),
        construct = "for",
        stringsAsFactors = FALSE
      )
      edge_for_previous <- data.frame(
        from = id-1,
        to = id
      )
      nodes <- rbind(nodes, node_for)
      edges <- rbind(edges, edge_for_previous)

      # build dfs from for's "body"
      for_dfs <-  build_dfs(block[[c(1 ,4)]], id)
      nodes <- rbind(nodes, for_dfs$nodes)
      edges <- rbind(edges, for_dfs$edges)

      id_last_for <- tail(nodes$id,1)
      edge_last_for_back <- data.frame(
        from = id_last_for,
        to = id
      )
      edges <- rbind(edges, edge_last_for_back)
    } else if (construct == "while"){
      node_while <- data.frame(
        id = id,
        label = sprintf("while (%s)",
                        deparse2(block[[c(1,2)]])),
        construct = "while",
        stringsAsFactors = FALSE
      )
      edge_while_previous <- data.frame(
        from = id-1,
        to = id
      )
      nodes <- rbind(nodes, node_while)
      edges <- rbind(edges, edge_while_previous)

      # build dfs from while's "body"
      node_while_dfs <-  build_dfs(block[[c(1 ,3)]], id)
      nodes <- rbind(nodes, node_while_dfs$nodes)
      edges <- rbind(edges, node_while_dfs$edges)

      id_last_while <- tail(nodes$id,1)
      edge_last_while_back <- data.frame(
        from = id_last_while,
        to = id
      )
      edges <- rbind(edges, edge_last_while_back)
    } else if (construct == "repeat"){
      node_repeat <- data.frame(
        id = id,
        label = "repeat",
        construct = "repeat",
        stringsAsFactors = FALSE
      )
      edge_repeat_previous <- data.frame(
        from = id-1,
        to = id
      )
      nodes <- rbind(nodes, node_repeat)
      edges <- rbind(edges, edge_repeat_previous)

      # build dfs from repeat's "body"
      node_repeat_dfs <-  build_dfs(block[[c(1 ,2)]], id)
      nodes <- rbind(nodes, node_repeat_dfs$nodes)
      edges <- rbind(edges, node_repeat_dfs$edges)

      id_last_repeat <- tail(nodes$id,1)
      edge_last_repeat_back <- data.frame(
        from = id_last_repeat,
        to = id
      )
      edges <- rbind(edges, edge_last_repeat_back)
    }
  }
  list(nodes = nodes, edges = edges)
}

construct <- function(x) {
  attr(blocks[[i]], "construct")
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





control_flow_ops <- c("if", "for", "while", "repeat")

first_is_cfc <- function(x){
  is.call(x) && as.character(x[[1]]) %in% control_flow_ops
}

