build_digraph <- function(nodes, edges){

  digraph_str <- "digraph graph1 {"
  # iterate through nodes
  for(i in seq_len(nrow(nodes))){
    id        <- nodes$id[[i]]
    construct <- nodes$construct[[i]]
    #label     <- gsub('\\\\', '\\',nodes$label[[i]])
    label     <- gsub('"', '\\\\\"',nodes$label[[i]])
    #label     <- gsub("'", "´",nodes$label[[i]])
    digraph_str <- paste0(
      digraph_str,"\n",
      switch(construct,
             header   = sprintf("%s[label = \"%s\", shape = oval]", id, label),
             none     = sprintf("%s[label = \"%s\", shape = rectangle]", id, label),
             'if'     = sprintf("%s[label = \"%s\", shape = diamond]", id, label),
             'for'    = sprintf("%s[label = \"%s\", shape = diamond]", id, label),
             'while'  = sprintf("%s[label = \"%s\", shape = diamond]", id, label),
             'repeat' = sprintf("%s[label = \"%s\", shape = diamond]", id, label))
    )
  }

  # add edges
  digraph_str <- paste0(
    digraph_str,"\n",
    paste(sprintf("%s -> %s", edges$from, edges$to), collapse="\n"),
    "\n}"
  )
  # cat(digraph_str)
  # print(digraph_str)
  DiagrammeR::grViz(digraph_str)
}
