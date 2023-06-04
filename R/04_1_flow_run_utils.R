insert_update <- function(expr, env = as.environment(list(i=0)), n){
  # clean block from braces
  if (is.call(expr) && expr[[1]] == quote(`{`))
    calls <- as.list(expr[-1])
  else
    calls <- list(expr)

  # support empty calls (`{}`)
  if (!length(calls)) {
    blocks <- list(substitute()) # substitute() returns an empty call
    return(blocks)
  }
  # logical indices of control flow calls
  cfc_lgl <- calls %call_in% c("if", "for", "while", "repeat")

  # logical indices of control flow calls
  special_comment_lgl <- calls %call_in% c("#")

  # there are 2 ways to start a block : be a cf not preceded by com, or be a com
  # there are 2 ways to finish a block : be a cf (and finish on next one), or start another block and finish right there

  # cf not preceded by com
  cfc_unpreceded_lgl <- cfc_lgl & !c(FALSE, head(special_comment_lgl, -1))
  # new_block (first or after cfc)
  new_block_lgl <- c(TRUE, head(cfc_lgl, -1))
  block_ids <- cumsum(special_comment_lgl | cfc_unpreceded_lgl | new_block_lgl)

  blocks <- split(calls, block_ids)

  # we can't type `flow:::update` without triggering a note so we work around it
  flow_update <- call(":::", as.symbol("flow"), as.symbol("update"))

  for (i in seq_along(blocks)) {
    # increment block number
    env$i <- env$i + 1
    # precede block with flow:::update call
    has_browser <- env$i %in% n
    if(has_browser)
      blocks[[i]] <-
      c(quote(browser()), bquote(.(flow_update)(.(env$i))), blocks[[i]])
    else
      blocks[[i]] <- c(bquote(.(flow_update)(.(env$i))), blocks[[i]])

    j <- 2 + has_browser

    if(blocks[[i]][j] %call_in% "if"){
      # yes clause of the if call of the i-th item
      blocks[[c(i, j, 3)]] <- insert_update(blocks[[c(i, j, 3)]], env, n)

      # no clause of the if call of the i-th item
      if(length(blocks[[c(i, j)]]) == 4) # if there is an "else"
        blocks[[c(i, j, 4)]] <- insert_update(blocks[[c(i, j, 4)]], env, n)

      next
    }

    if(blocks[[i]][j] %call_in% "for"){
      # loop of the for call of the i-th item
      blocks[[c(i, j, 4)]] <- insert_update(blocks[[c(i, j, 4)]], env, n)
      next
    }

    if(blocks[[i]][j] %call_in% "while"){
      # loop of the while call of the i-th item
      blocks[[c(i, j, 3)]] <- insert_update(blocks[[c(i, j, 3)]], env, n)
      next
    }

    if(blocks[[i]][j] %call_in% "repeat"){
      # loop of the repeat call of the i-th item
      blocks[[c(i, j, 2)]] <- insert_update(blocks[[c(i, j, 2)]], env, n)
      next
    }
  }
 as.call(c(quote(`{`), unlist(blocks)))
}

update <- function(n, child = FALSE) {
  # the last layer_id is the current one
  layer_id <- tail(ls(data_env), 1)

  # we copy variables for convenience
  nodes     <- data_env[[layer_id]]$nodes
  edges     <- data_env[[layer_id]]$edges
  #browse_at <- data_env[[layer_id]]$browse_at
  last_node <- data_env[[layer_id]]$last_node

  # position where last_node connects to new node
  direct_edge_row_lgl <- edges$from == last_node & edges$to == n
  direct_edge_exists <- any(direct_edge_row_lgl)
  if(!direct_edge_exists) {
    #message("no direct edge, looking for a negative edge to link to")

    # if it doesn't connect, connect last_node to a negative node (end of control
    # flow), and make this new node te connection
    edge_to_neg_node_lgl <- edges$from == last_node & edges$to < 0
    edge_to_neg_node_exists <- any(edge_to_neg_node_lgl)

    if (edge_to_neg_node_exists) {

      last_node_is_loop <-
        nodes[nodes$id == last_node, "block_type"] %in% c("for", "while", "repeat")

      if(!last_node_is_loop) {
        # undash edge
        data_env[[layer_id]]$edges$arrow[edge_to_neg_node_lgl] <- "->"

        # increment edge passes
        data_env[[layer_id]]$edges$passes[edge_to_neg_node_lgl] <-
          edges$passes[edge_to_neg_node_lgl] + 1
      }

      # update last node
      last_node <- data_env[[layer_id]]$edges$to[edge_to_neg_node_lgl]
      data_env[[layer_id]]$last_node <- last_node

      # increment node passes
      node_index_lgl <- nodes$id == last_node
      data_env[[layer_id]]$nodes$passes[node_index_lgl] <-
        nodes$passes[node_index_lgl] + 1

      # update to same n now that last_node was updated
      return(update(n, TRUE))
    }

    # if we don't have direct link nor link to neg node, it means we looped back up

    # change last node to direct parent
    last_node <- n - 1
    data_env[[layer_id]]$last_node <- last_node

    # undash the upward edge and add a pass to it as well as to loop head node
    upward_edge_lgl <- edges$from == last_node & edges$to == -last_node

    data_env[[layer_id]]$edges$arrow[upward_edge_lgl] <- "<-"
    data_env[[layer_id]]$edges$passes[upward_edge_lgl] <-
      edges$passes[upward_edge_lgl] + 1

    head_node_lgl <- nodes$id == last_node

    data_env[[layer_id]]$nodes$passes[head_node_lgl] <-
      nodes$passes[head_node_lgl] + 1

    # update to same n now that last_node was updated
    return(update(n, TRUE))

  }

  # undash
  data_env[[layer_id]]$edges[direct_edge_row_lgl, "arrow"] <- "->"
  # increment edge passes
  data_env[[layer_id]]$edges[direct_edge_row_lgl, "passes"] <-
    edges[direct_edge_row_lgl, "passes"] + 1
  # increment node passes
  data_env[[layer_id]]$nodes$passes[nodes$id == n] <-
    nodes$passes[nodes$id == n]+ 1

  data_env[[layer_id]]$last_node <- n

  # if(data_env[[layer_id]]$refresh) {
  #   on.exit(data_env[[layer_id]]$update_diagram())
  # }
  invisible(NULL)
}

# data_env is an environment that will contain data lists
# each of this data lists serves for a layer of debugging, so it means we'll have
# most of the time zero or one, but is flexible for nested debugging
data_env <- new.env()

#' Draw Diagram From Debugger
#'
#' `flow_draw()` should only be used in the debugger triggered by a call
#' to `flow_run()`, or following a call to `flow_debug()`.
#' `d` is an active binding to `flow_draw()`, it means you can just type `d`
#' (without parentheses) instead of `flow_draw()`.
#'
#' `d` was designed to look like the other shortcuts detailed in `?browser`,
#' such as `f`, `c` etc... It differs however in that it can be overridden.
#' For instance if the function uses a variable `d` or that a parent environment
#' contains a variable `d`, `flow::d` won't be found. In that case you will
#' have to use `flow_draw()`.
#'
#' If `d` or `flow_draw()` are called outside of the debugger they will return
#' `NULL` silently.
#'
#' @usage flow_draw()
#' @usage d
#' @aliases d
#' @return Returns `NULL` invisibly (called for side effects)
#' @export
flow_draw <- function() {
  # the following is necessary to pass checks
  if(!interactive())
    return(invisible())
  layer_id <- tail(ls(data_env), 1)
  if(!length(layer_id)) {
    #warning("`d` and flow::draw()` should only be called from the debugger after calling `flow::flow_run()`, returning NULL")
    return(invisible())
  }
  data_env[[layer_id]]$update_diagram()
  invisible(NULL)
}
