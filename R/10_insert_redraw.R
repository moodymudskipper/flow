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

  for (i in seq_along(blocks)) {
    # increment block number
    env$i <- env$i + 1
    # precede block with flow:::update call
    has_browser <- env$i %in% n
    if(has_browser)
      blocks[[i]] <- c(bquote(flow:::update(.(env$i))), quote(browser()), blocks[[i]])
    else
      blocks[[i]] <- c(bquote(flow:::update(.(env$i))), blocks[[i]])

    j <- 2 + has_browser

    if(blocks[[i]][j] %call_in% "if"){
      #blocks[[i]] <- c(blocks[[i]], bquote(flow:::update(.(-env$i))))
      # yes clause of the if call of the i-th item
      blocks[[c(i, j, 3)]] <- insert_update(blocks[[c(i, j, 3)]], env, n)

      # no clause of the if call of the i-th item
      if(length(blocks[[c(i, j)]]) == 4) # if there is an "else"
        blocks[[c(i, j, 4)]] <- insert_update(blocks[[c(i, j, 4)]], env, n)

      next
    }

    if(blocks[[i]][j] %call_in% "for"){
      #blocks[[i]] <- c(blocks[[i]], bquote(flow:::update(.(-env$i))))
      # loop of the for call of the i-th item
      blocks[[c(i, j, 4)]] <- insert_update(blocks[[c(i, j, 4)]], env, n)
      next
    }

    if(blocks[[i]][j] %call_in% "while"){
      #blocks[[i]] <- c(blocks[[i]], bquote(flow:::update(.(-env$i))))
      # loop of the while call of the i-th item
      blocks[[c(i, j, 3)]] <- insert_update(blocks[[c(i, j, 3)]], env, n)
      next
    }

    if(blocks[[i]][j] %call_in% "repeat"){
      #blocks[[i]] <- c(blocks[[i]], bquote(flow:::update(.(-env$i))))
      # loop of the repeat call of the i-th item
      blocks[[c(i, j, 2)]] <- insert_update(blocks[[c(i, j, 2)]], env, n)
      next
    }
  }
 as.call(c(quote(`{`), unlist(blocks)))
}


#' Experimental replacement for flow_run
#'
#' @inheritParams flow_run
#' @export
flow_run2 <-
  function(x, prefix = NULL, swap = TRUE, code = TRUE, ...,
           out = NULL, svg = FALSE, browse = FALSE) {
    # capture call and function
    call <- substitute(x)
    if (!is.call(call)) stop("x must be a call")
    fun_sym <- call[[1]]
    fun <- eval.parent(fun_sym)

    if(is.null(body(fun))) stop("`", as.character(fun_sym),
                                "` doesn't have a body (try `body(", as.character(fun_sym),
                                ")`). {flow}'s functions don't work on such inputs.")

    # if function is a S3 standard generic, debug appropriate method
    if (isS3stdGeneric(fun)) {
      fun_sym <- str2lang(getS3methodSym(deparse(fun_sym), eval.parent(call[[2]])))
      fun <- eval(fun_sym)
    }

    # build the diagram data from the function
    flow_data_call <- as.call(list(
      quote(flow::flow_data),
      fun_sym,
      range = NULL,
      prefix = substitute(prefix),
      sub_fun_id = NULL,
      swap = substitute(swap)))
    data <- eval.parent(flow_data_call)

    # dash the edges
    data$edges$arrow <- gsub("->", "--:>", data$edges$arrow, fixed = TRUE)
    data$edges$arrow <- gsub("<-", "<:--", data$edges$arrow, fixed = TRUE)
    data$edges$arrow[data$edges$from == 0] <- "->"

    # initiates number of passes
    data$edges$passes <- 0
    data$nodes$passes <- 0

    # move data to the global variable data_env, so we can access and modify
    # values inside of our flow:::update function
    # the id of our debugging layer is the time, so we know it's unique and
    # can be sorted
    layer_id <- as.character(Sys.time())
    data_env[[layer_id]] <- list()
    data_env[[layer_id]]$nodes <- data$nodes
    data_env[[layer_id]]$edges <- data$edges
    #data_env[[layer_id]]$browse_at <- browse
    data_env[[layer_id]]$refresh <- FALSE
    data_env[[layer_id]]$last_node <- 0

    update_diagram <- function() {
      #browser()
      # display updated diagram

      data <- data_env[[layer_id]]

      nomnoml_code  <- build_nomnoml_code(data, code = code, ...)
      widget_params <- list(code = nomnoml_code, svg = svg)
      widget <- htmlwidgets::createWidget(
        name = "nomnoml", widget_params, package = "nomnoml")
      if (is.null(out)) return(print(widget))

      is_tmp <- out %in% c("html", "htm", "png", "pdf", "jpg", "jpeg")
      if (is_tmp) {
        out <- tempfile("flow_", fileext = paste0(".", out))
      }
      ext <- sub(".*?\\.([[:alnum:]]+)$", "\\1", out)
      if (tolower(ext) %in% c("html", "htm"))
        htmlwidgets::saveWidget(widget, out)
      else {
        html <- tempfile("flow_", fileext = ".html")
        htmlwidgets::saveWidget(widget, html)
        webshot::webshot(html, out, selector = "canvas")
      }

      if (is_tmp) {
        message(sprintf("The diagram was saved to '%s'", gsub("\\\\","/", out)))
        browseURL(out)
      }
      out
    }

    # we put update_diagram in our global environment this way so it posses
    # all the parameter values in its enclosure
    data_env[[layer_id]]$update_diagram <- update_diagram

    # the diagram is drawn in the end, error or not

    # message("defining on.exit: ", layer_id)
    on.exit({
      # message("exiting: ", layer_id)
      update_diagram()
      rm(list = layer_id, envir = data_env)
      })

    if (swap) body(fun) <- swap_calls(body(fun))
    body(fun) <- insert_update(body(fun), n = browse)
    #body(fun) <- as.call(c(quote(`{`), quote(browser()), as.list(body(fun)[-1])))
    call[[1]] <- fun
    res <- eval.parent(call)


    # if(!isFALSE(browser)) {
    #   update_diagram()
    # }

    # finish the flow to the end after last flow:::update call
    repeat {
      next_edge_lgl <- data_env[[layer_id]]$edges$from == data_env[[layer_id]]$last_node
      if(!any(next_edge_lgl)) break else {
        # there could be several candidate, standard blocks are dismissed as
        # they would have been dealt with by previous update calls
        if(sum(next_edge_lgl) > 1) {
          candidate_nodes <- data_env[[layer_id]]$edges$to[next_edge_lgl]
          chosen_candidate_lgl <-
            with(data_env[[layer_id]]$nodes,
            block_type[id %in% candidate_nodes] != "standard")
          chosen_candidate <- candidate_nodes[chosen_candidate_lgl]
          next_edge_lgl <-
            with(data_env[[layer_id]],
                 edges$from == last_node & edges$to == chosen_candidate)
        }

        # undash
        data_env[[layer_id]]$edges$arrow[next_edge_lgl] <- "->"

        # increment edge passes
        data_env[[layer_id]]$edges$passes[next_edge_lgl] <-
          data_env[[layer_id]]$edges$passes[next_edge_lgl] + 1

        # update last node
        data_env[[layer_id]]$last_node <- data_env[[layer_id]]$edges$to[next_edge_lgl]
      }
    }

    # and we should when we stop debugging we should be able to draw only in the end (check if is debugged before flow:::updateing)
    res
  }

update <- function(n, child = FALSE) {
  # the last layer_id is the current one
  layer_id <- tail(ls(data_env), 1)

  if(data_env[[layer_id]]$refresh) {
    on.exit(data_env[[layer_id]]$update_diagram())
  }

  # we copy variables for convenience
  nodes     <- data_env[[layer_id]]$nodes
  edges     <- data_env[[layer_id]]$edges
  #browse_at <- data_env[[layer_id]]$browse_at
  last_node <- data_env[[layer_id]]$last_node



  # we start browsing after an update call directly called from the debugged
  # function if we reach the the n == brows_at block, and if it hasn't been
  # passed yet

  # start_browsing <-
  #   !child &&
  #   browse_at == n &&
  #   nodes$passes[nodes$id == n] == 0
  #
  # if(start_browsing) {
  #   # data_env[[layer_id]]$refresh <- TRUE
  #   on.exit({
  #     message("exiting update")
  #     eval.parent(quote(browser()))
  #     })
  # }

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
        subset(nodes, id == last_node)$block_type %in% c("for", "while", "repeat")

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
      return(flow:::update(n, TRUE))
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

    # flow:::update to same n now that last_node was updated
    return(flow:::update(n, TRUE))

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
  invisible(NULL)
}


# data_env is an environment that will contain data lists
# each of this data lists serves for a layer of debugging, so it means we'll have
# most of the time zero or one, but is flexible for nested debugging
data_env <- new.env()


#rm(list=ls(data_env), envir = data_env)

#' redraw
#' @param always not implemented yet, set to TRUE to always redraw automatically during current run
#'
#' @export
redraw <- function(always = FALSE) {
  layer_id <- tail(ls(data_env), 1)
  data_env[[layer_id]]$refresh <- always
  data_env[[layer_id]]$update_diagram()
  invisible(NULL)
}

