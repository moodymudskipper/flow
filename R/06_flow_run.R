#' @export
#' @rdname flow_view
flow_run <-
  function(x, prefix = NULL, swap = TRUE, code = TRUE, ..., browse = FALSE, trim = FALSE) {
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
    # we initiate it with the promises of the call
    e_fun <- fun
    e_call <- call
    body(e_fun) <- quote(environment())
    e_call[[1]] <- e_fun
    e <- eval.parent(e_call)

    # build the diagram data from the function
    flow_data_call <- as.call(list(
      quote(flow_data),
      fun_sym,
      range = NULL,
      prefix = substitute(prefix),
      sub_fun_id = NULL,
      swap = substitute(swap)))
    data <- eval.parent(flow_data_call)
    data$edges$arrow <- gsub("->", "--:>", data$edges$arrow, fixed = TRUE)
    data$edges$arrow <- gsub("<-", "<:--", data$edges$arrow, fixed = TRUE)
    data$edges$arrow[data$edges$from == 0] <- "->"
    data_last <- data

    # we create a function for each block and run it
    finished <- FALSE
    id <- id_last <- 1

    update_diagram <- function() {
      # display updated diagram
      nomnoml_code  <- build_nomnoml_code(data, code = code, ...)
      widget_params <- list(code = nomnoml_code, svg = FALSE)
      widg <- htmlwidgets::createWidget(
        name = "nomnoml", widget_params, package = "nomnoml")
      print(widg)
    }

    flow_browser <- function(id,e) {
      repeat {
        line <- readline(paste0("flow_browser[", id,"]> "))
        if (line == "") break
        res <- try(withVisible(eval(parse(text = line), e)))
        if (!inherits(res, "try-error") && res$visible)
          print(res$value)
      }
    }

    # we display the diagram on exit, this way it will be displayed even if the
    # code fails
    on.exit({
      update_diagram()
    })

    repeat {

      # if we fall on an "end" node (they have negative indices), go to the next one
      if (id < 0) {
        ind <- with(data$edges, from == id & edge_label == "")
        id <- data$edges$to[ind]
        data$edges$arrow[ind] <- "->"
      }

      if (trim) {
        flow_data_call$range <- c(id_last, Inf)
        id_last <- id
        data_last <- data
        data <- eval.parent(flow_data_call)
        data$edges$rowid <- 1:nrow(data$edges)
        data$edges$arrow <- NULL
        data$edges <- merge(data$edges, data_last$edges, all.x = TRUE)
        data$edges$arrow[is.na(data$edges$arrow)] <- "->"
        data$edges <- data$edges[order(data$edges$rowid),]
        data$edges$rowid <- NULL
      }




      node <- as.list(data$nodes[data$nodes$id == id,])
      # since we evaluate the code outside of the function, we should remove the
      # return calls, so return(expr) becomes expr, the block_type info will
      # take it from there

      if (isTRUE(browse) || id %in% browse) {
        update_diagram()
        cat("Next block: ",node$block_type, "\n", node$code_str, "\n")
        flow_browser(id, e)
      }

      ###################
      # Standard blocks #
      ###################
      if (node$block_type == "standard") {

        res <- eval(expr  = as.call(c(quote(`{`), node$code[[1]])),
                    envir = e)
        ind <- data$edges$from == id
        id <- data$edges$to[ind]
      }

      #############
      # if blocks #
      #############
      if (node$block_type == "if") {

        # compute code from new block, e will be modified for next step
        res <- eval(expr  = as.call(c(quote(`{`), node$code[[1]])),
                    envir = e)
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

        # compute code from new block, e will be modified for next step
        res <- eval(expr  = as.call(c(quote(`{`), node$code[[1]])),
                    envir = e)

        id_neg <- -id
        while (length(id)) {
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
      if (data$nodes[data$nodes$id == id, "block_type"] == "return") {
        return(res)
      }

      data$edges$arrow[ind] <- "->"
    }
  }
