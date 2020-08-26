#' @export
#' @rdname flow_view
flow_run <-
  function(x, prefix = NULL, swap = TRUE, code = TRUE, ...,
           out = NULL, svg = FALSE, browse = FALSE, show_passes = FALSE) {
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
    #data_env[[layer_id]]$refresh <- FALSE
    data_env[[layer_id]]$last_node <- 0

    update_diagram <- function() {
      #browser()
      # display updated diagram

      data <- data_env[[layer_id]]

      if(show_passes) {
        data$edges$edge_label <- ifelse(
          data$edges$passes > 0,
          trimws(sprintf("%s (%s)", data$edges$edge_label, data$edges$passes)),
          data$edges$edge_label)
      }

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

    # we define update_diagram here so it possesses
    # all the parameter values in its enclosure
    data_env[[layer_id]]$update_diagram <- update_diagram

    # the diagram is drawn in the end, error or not
    on.exit({
      update_diagram()
      rm(list = layer_id, envir = data_env)
    })

    if(is_flow_traced(fun))
      body_ <- body(attr(fun, "original"))
    else
      body_ <- body(fun)
    if (swap) body_ <- swap_calls(body_)
    body(fun) <- insert_update(body_, n = browse)
    call[[1]] <- fun
    res <- eval.parent(call)

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
    res
  }
