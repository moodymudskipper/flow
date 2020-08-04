#' @export
#' @rdname flow_view
flow_run <-
  function(x, range = NULL, prefix = NULL, sub_fun_id = NULL, swap = TRUE, code = TRUE, ..., browse = FALSE) {
    # capture call and function
    call <- substitute(x)
    if (!is.call(call)) stop("x must be a call")
    fun_sym <- call[[1]]
    fun <- eval.parent(fun_sym)

    # if function is a S3 standard generic, debug appropriate method
    if (isS3stdGeneric(fun)) {
      fun_sym <- str2lang(getS3methodSym(deparse(fun_sym), eval.parent(call[[2]])))
      fun <- eval(fun_sym)
    }

    # e is the env where we evaluate our block and browsing functions
    # it's right under the calling environment and has copies of necessary
    # variables so we don't clutter the fun's environments
    e <- new.env(parent = parent.frame())
    e$.flow_blocks_temp_env <- new.env()
    e$.flow_blocks_temp_env$vars <- list()
    e$.flow_blocks_temp_env$env <- e$.flow_blocks_temp_env$res <- NULL
    # to appease cmd check :
    .flow_blocks_temp_env <- .flow_browser_temp_env <- NULL

    # build the diagram data from the function
    flow_data_call <- as.call(list(
      quote(flow_data),
      fun_sym,
      range = substitute(range),
      prefix = substitute(prefix),
      sub_fun_id = substitute(sub_fun_id),
      swap = substitute(swap)))
    data <- eval.parent(flow_data_call)
    # initially, id is 1, no node is entered nor completed, and all arrows are dashed
    data$nodes$entered   <- FALSE
    data$nodes$completed <- FALSE
    data$edges$arrow <- gsub("->", "--:>", data$edges$arrow, fixed = TRUE)
    data$edges$arrow <- gsub("<-", "<:--", data$edges$arrow, fixed = TRUE)
    data$edges$arrow[data$edges$from == 0] <- "->"

    # we create a function for each block and run it
    finished <- FALSE
    id <- 1

    # we display the diagram on exit, this way it will be displayed even if the
    # code fails
    on.exit({
      code <- build_nomnoml_code(data, code = code, ...)
      x <- list(code = code, svg = FALSE)
      widg <- htmlwidgets::createWidget(
        name = "nomnoml", x,
        package = "nomnoml")
      print(widg)
    })

    if (browse) {
      # .flow_browser_temp_env is used for temp variables in flow_browser
      e$.flow_browser_temp_env <- new.env()
      e$.flow_browser_temp_env$code <- code

      flow_browser <- function() {
        # display updated diagram
        .flow_browser_temp_env$nomnoml_code <<-
          build_nomnoml_code(.flow_browser_temp_env$data, code = .flow_browser_temp_env$code, ...)
        .flow_browser_temp_env$widget_params <<-
          list(code = .flow_browser_temp_env$nomnoml_code, svg = FALSE)
        .flow_browser_temp_env$widg <<-
          htmlwidgets::createWidget(
          name = "nomnoml", .flow_browser_temp_env$widget_params,
          package = "nomnoml")
        print(.flow_browser_temp_env$widg)

        # retrieve all vars so they can override promises when relevant
        list2env(.flow_blocks_temp_env$vars, environment())

        # browse by reading expressions and evaluating locally, print if relevant
        repeat {
          .flow_browser_temp_env$line <<- readline(
            paste0("flow_browser[", .flow_browser_temp_env$id,"]> "))
          if (.flow_browser_temp_env$line == "") break
          .flow_browser_temp_env$res <<-
            try(withVisible(eval(parse(text = .flow_browser_temp_env$line))))
          if (!inherits(.flow_browser_temp_env$res, "try-error") &&
              .flow_browser_temp_env$res$visible)
            print(.flow_browser_temp_env$res$value)
        }

        # update our temp environment with all, except for promises
        .flow_browser_temp_env$vars <<- ls(all.names = TRUE)
        .flow_browser_temp_env$env  <<- environment()
        .flow_browser_temp_env$vars <<- Filter(
          function(x) !is_promise2(as.name(x), .flow_browser_temp_env$env),
          .flow_browser_temp_env$vars)
        .flow_browser_temp_env$vars <<- setdiff(.flow_browser_temp_env$vars, "...")
        # list2env(mget(.flow_browser_temp_env$vars, .flow_browser_temp_env$env),
        #          .flow_blocks_temp_env$vars)
        invisible()
      }

      # we copy formals and build a call so that promises are preserved
      formals(flow_browser) <- formals(fun)
      environment(flow_browser) <- e
      browser_call <- call
      browser_call[[1]] <- quote(flow_browser)
    }


    while (!finished) {

      # if we fall on an "end" node (they have negative indices), go to the next one
      if (id < 0) {
        ind <- with(data$edges, from == id & edge_label == "")
        id <- data$edges$to[ind]
        data$edges$arrow[ind] <- "->"
      }

      if (browse) {

        e$.flow_browser_temp_env$data <- data
        e$.flow_browser_temp_env$id <- id
        eval(browser_call)
      }

      # flag node and extract row of node data from data$nodes into `node`
      data$nodes$entered[data$nodes$id == id] <- TRUE
      node <- as.list(data$nodes[data$nodes$id == id,])

      ###################
      # Standard blocks #
      ###################
      if (node$block_type == "standard") {
        block_fun <- fun
        body(block_fun) <- bquote({
          # put all vars in environment
          list2env(.flow_blocks_temp_env$vars, environment())

          # run code
          .flow_blocks_temp_env$env <<- environment()
          .flow_blocks_temp_env$res  <<- .(as.call(c(quote(`{`), node$code[[1]])))
          .flow_blocks_temp_env$vars <<- ls(all.names = TRUE)
          .flow_blocks_temp_env$vars <<- setdiff(.flow_blocks_temp_env$vars,  "...")
          .flow_blocks_temp_env$vars <<- Filter(
            function(x)  !is_promise2(as.name(x), .flow_blocks_temp_env$env),
            .flow_blocks_temp_env$vars)
          .flow_blocks_temp_env$vars <<- mget(.flow_blocks_temp_env$vars)
          .flow_blocks_temp_env$res
        })
        environment(block_fun) <- e
        temp_call <- call
        temp_call[[1]] <- quote(block_fun)
        res <- eval(temp_call)
        data$nodes$completed[data$nodes$id == id] <- TRUE
        ind <- data$edges$from == id
        id <- data$edges$to[ind]
      }

      #############
      # if blocks #
      #############
      if (node$block_type == "if") {
        block_fun <- fun
        body(block_fun) <- bquote({
          # put all vars in environment
          list2env(.flow_blocks_temp_env$vars, environment())
          # run code
          .flow_blocks_temp_env$res <<- .(node$code[[1]])
          # put created vars back in environment
          .flow_blocks_temp_env$vars <<- ls(all.names = TRUE)
          .flow_blocks_temp_env$vars <<- setdiff(.flow_blocks_temp_env$vars, "...")
          .flow_blocks_temp_env$env <<- environment()
          .flow_blocks_temp_env$vars <<- Filter(
            function(x)  !is_promise2(as.name(x), .flow_blocks_temp_env$env), .flow_blocks_temp_env$vars)
          .flow_blocks_temp_env$vars <<- mget(.flow_blocks_temp_env$vars)
          .flow_blocks_temp_env$res
        })
        environment(block_fun) <- e
        temp_call <- call
        temp_call[[1]] <- quote(block_fun)
        res <- eval(temp_call)
        data$nodes$completed[data$nodes$id == id] <- TRUE
        if (res) {
          ind <- with(data$edges, from == id & edge_label == "y")
          id <- data$edges$to[ind]
        } else {
          ind <- with(data$edges, from == id & edge_label == "n")
          id <- data$edges$to[ind]
        }
      }

      ###########################
      # for/while/repeat blocks #
      ###########################
      # for those we cannot trivially show the path that was taken as it may
      # be different depending on the iteration, so we just undash all arrows
      # and run the full loop
      if (node$block_type %in% c("repeat", "for","while")) {
        block_fun <- fun
        body(block_fun) <- bquote({
          # put all vars in environment
          list2env(.flow_blocks_temp_env$vars, environment())
          # run code
          .flow_blocks_temp_env$res <<- .(as.call(c(quote(`{`), node$code[[1]])))
          .flow_blocks_temp_env$vars <<- ls(all.names = TRUE)
          .flow_blocks_temp_env$vars <<- setdiff(.flow_blocks_temp_env$vars, "...")
          .flow_blocks_temp_env$env <<- environment()
          .flow_blocks_temp_env$vars <<- Filter(
            function(x)  !is_promise2(as.name(x), .flow_blocks_temp_env$env),
            .flow_blocks_temp_env$vars)
          .flow_blocks_temp_env$vars <<- mget(.flow_blocks_temp_env$vars)
          .flow_blocks_temp_env$res
        })
        environment(block_fun) <- e
        temp_call <- call
        temp_call[[1]] <- quote(block_fun)
        res <- eval(temp_call)


        id_neg <- -id
        while (length(id)) {
          data$nodes$completed[data$nodes$id %in% id] <- TRUE
          ind <- data$edges$from %in% id & data$edges$from != id_neg
          id <- data$edges$to[ind]

          data$edges$arrow[ind] <- gsub("--:>", "->", data$edges$arrow[ind], fixed = TRUE)
          data$edges$arrow[ind] <- gsub("<:--", "<-", data$edges$arrow[ind], fixed = TRUE)
        }
        id <- id_neg
        next

      }

      #################
      # return blocks #
      #################
      if (node$block_type == "return") {
        return(res)
      }

      data$edges$arrow[ind] <- "->"
    }
    data
  }
