#' @export
#' @rdname flow_view
flow_run <-
  function(x,
           prefix = NULL,
           code = TRUE,
           narrow = FALSE,
           truncate = NULL,
           swap = TRUE,
           out = NULL,
           browse = FALSE) {

    svg <- is.null(out) || endsWith(out, ".html") || endsWith(out, ".html")

    ## set `call` to quoted input
    call <- substitute(x)

    ## is it a call ?
    if (!is.call(call)) {
      ## fail explicitly
      stop("x must be a call")
    }

    ## fetch function symbol and evaluate it into `fun`
    fun_sym <- call[[1]]
    fun <- eval.parent(fun_sym)

    ## does `fun` have a body ?
    if(is.null(body(fun))) {
      ## fail explicitly
      stop("`", as.character(fun_sym),
                                "` doesn't have a body (try `body(", as.character(fun_sym),
                                ")`). {flow}'s functions don't work on such inputs.")
    }

    ## is fun a S3 standard generic ?
    if (isS3stdGeneric(fun)) {
      ## set fun to the relevant method
      fun_sym <- str2lang(getS3methodSym(deparse(fun_sym), eval.parent(call[[2]])))
      fun <- eval(fun_sym)
    }

    ## build the diagram data from the function
    data <- flow_data(
      setNames(list(fun), deparse(fun_sym)),
      prefix = prefix,
      narrow = narrow,
      truncate = truncate,
      nested_fun = NA,
      swap = swap)

    ## dash the edges
    data$edges$arrow <- gsub("->", "--:>", data$edges$arrow, fixed = TRUE)
    data$edges$arrow <- gsub("<-", "<:--", data$edges$arrow, fixed = TRUE)
    data$edges$arrow[data$edges$from == 0] <- "->"

    ## create new element in the global data_env envir with all relevant data

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


    ## define closure `update_diagram`
    # we define update_diagram here so it possesses
    # all the parameter values in its enclosure
    update_diagram <- function() {
      # display updated diagram

      data <- data_env[[layer_id]]

      ## show passes
      data$edges$edge_label <- ifelse(
        data$edges$passes > 0,
        trimws(sprintf("%s (%s)", data$edges$edge_label, data$edges$passes)),
        data$edges$edge_label)

      nomnoml_code  <-
        do.call(build_nomnoml_code, c(list(data, code = code)))
      widget_params <- list(code = nomnoml_code, svg = svg)
      widget <- do.call(
        htmlwidgets::createWidget,
        c(list(name = "nomnoml", widget_params ,package = "nomnoml")))
      if (is.null(out)) return(print(widget))
      # nomnoml is called only through htmlwidgets::createWidget
      # to pass tests on old ubuntu releases we need to call at least a function once,
      # hence the following call
      nomnoml::nomnoml_validate()

      is_tmp <- out %in% c("html", "htm", "png", "pdf", "jpg", "jpeg")
      if (is_tmp) {
        out <- tempfile("flow_", fileext = paste0(".", out))
      }
      ext <- sub(".*?\\.([[:alnum:]]+)$", "\\1", out)

      if (tolower(ext) %in% c("html", "htm")) {
        do.call(htmlwidgets::saveWidget, c(list(widget, out)))
      } else {
        html <- tempfile("flow_", fileext = ".html")
        do.call(htmlwidgets::saveWidget, c(list(widget, html)))
        webshot::webshot(html, out, selector = "canvas")
      }

      if (is_tmp) {
        message(sprintf("The diagram was saved to '%s'", gsub("\\\\","/", out)))
        browseURL(out)
      }
      out
    }

    ## add it to the layer
    data_env[[layer_id]]$update_diagram <- update_diagram

    ## make sure that on exit, diagram is updated and layer removed
    on.exit({
      update_diagram()
      rm(list = layer_id, envir = data_env)
    })

    ## is the function traced by flow_debug ?
    if(is_flow_traced(fun)) {
      ## set body_ as the original body
      body_ <- body(attr(fun, "original"))
    } else {
      ## set body_ as the body
      body_ <- body(fun)
    }

    ## is `swap` TRUE ?
    if (swap) {
      ## swap `if` calls
      body_ <- swap_calls(body_)
    }

    ## insert `update()` calls in the body
    body(fun) <- insert_update(body_, n = browse)

    ## run the given call using modified function
    call[[1]] <- fun
    res <- eval.parent(call)

    # finish the flow to the end after last flow:::update call
    ## undash all walked edges following last update() call
    repeat {
      ## flag the edges starting from last node
      next_edge_lgl <- data_env[[layer_id]]$edges$from == data_env[[layer_id]]$last_node

       ## is there any ?
      if(!any(next_edge_lgl)) break

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
    res
  }
