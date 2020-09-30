subset_data_by_range <- function(data, range) {
  ## compute the range and starting/ending rows
  range <- range(range)
  range[2] <- min(max(data$nodes$id), range[2])
  # matches give the row numbers, not the the node ids
  matches <- which(data$nodes$id %in% range)
  start <- min(matches)
  end   <- max(matches)
  data0 <- data
  ## is our lower bound 1 or less ?
  if (min(range) <= 1) {
    ## start at 1 and keep relevant edges and nodes
    data$nodes <- data$nodes[1:end,]
    data$edges <- data$edges[
      data$edges$from %in% data$nodes$id &
        data$edges$to %in% data$nodes$id,]
  } else {
    ## add a header node containing displaying ". . ."
    data$nodes <- rbind(
      data.frame(id = 0, block_type = "header", code_str = ". . .",
                 label = "", code = "", stringsAsFactors =  FALSE),
      data$nodes[start:end,])
    ##  keep relevant edges and nodes
    data$edges <- data$edges[
      data$edges$from %in% data$nodes$id &
        data$edges$to %in% data$nodes$id,]
    entry_points <- unique(
      data$edges$from[!data$edges$from %in% data$edges$to])
    data$edges <- rbind(
      data.frame(from = 0, to = entry_points, edge_label = "", arrow = "--:>",
                 stringsAsFactors = FALSE),
      data$edges)
  }

  ## fetch last node in the data
  max_id <- max(data0$nodes$id)

  ## is the last node out of the range ?
  if (max(range) < max_id) {
    ## add a footer node containing displaying "..."
    data$nodes <- rbind(
      data$nodes,
      data.frame(id = max_id, block_type = "header", code_str = "...",
                 label = "", code = ""))
    exit_points <- data$edges$to[!data$edges$to %in% data$edges$from]
    exit_points <- data$nodes$id[data$nodes$id %in% exit_points &
                                   !data$nodes$block_type %in% c("stop", "return")]
    data$edges <- rbind(
      data$edges,
      data.frame(from = exit_points, to = max_id, edge_label = "", arrow = "--:>"))
  }
  ## return subsetted data
  data
}
