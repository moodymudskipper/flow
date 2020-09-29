#' @export
#' @rdname flow_view
flow_data <-
  function(x, range = NULL, prefix = NULL, sub_fun_id = NULL, swap = TRUE,
           narrow = FALSE) {

    ## capture quoted input
    f_sym <- substitute(x)


    is_valid_named_list <-
      is.list(x) && length(x) == 1 && allNames(x) != ""

    ## is `x` a named list ?
    if(is_valid_named_list) {
      ## build function symbol and make `x[[1]]` the new `x`
      f_sym <- as.name(names(x))
      x <- x[[1]]
    }

    ## is `x` a bodiless function ?
    if(is.function(x) && is.null(body(x))) {
      ## fail explicitly
      stop("`", as.character(f_sym),
      "` doesn't have a body (try `body(", as.character(f_sym),
      ")`). {flow}'s functions don't work on such inputs.")
    }

    ## build empty data
    data <- new_data()

    ## is `x` a function and was `prefix` given ?
    if(is.function(x) && !is.null(prefix)) {
      ## store comments in `#`() calls
      # so we can manipulate them as code,
      # the function `build_blocks()`, called itself in `add_data_from_expr()`,
      # will deal with them further down the line
      x <- add_comment_calls(x, prefix)
    }

    ## find sub functions (function defs found in the code)
    sub_funs <- find_funs(x)

    ## was the sub_fun_id argument given ?
    if (!is.null(sub_fun_id)) {
      ## make the relevant sub function our new input
      f_sym <- quote(fun)
      x <- eval(sub_funs[[sub_fun_id]])
    } else {
      ## do we have sub function definitions ?
      if (length(sub_funs)) {
        ## print them
        # so user can choose a sub_fun_id if relevant
        message("We found function definitions in this code, ",
                "use the argument sub_fun_id to inspect them")
        print(sub_funs)
      }
    }

    ## is `x` a function ?
    if (is.function(x)) {
      ## build function header node and edge
      title <- head(deparse(args(x), width.cutoff = 500), -1)
      title <- paste(title, collapse = "\n  ")
      title <- trimws(sub("^function ", deparse(f_sym), title))
      data <- add_node(
        data,
        id = 0L,
        "header",
        code = f_sym,
        code_str = title)
      data <- add_edge(data, from = 0L, to = 1L)

      ## is the function traced ?
      if(is_flow_traced(x)) {
        ## make `x` the  body of original function
        x <- body(attributes(x)$original)
      } else {
        ## make `x` the  body of function
        x <- body(x)
      }

    } else {
      ## is x a string (presumably a path) ?
      if (is.character(x) && length(x) == 1) {
        ## parse the relevant file into a call
        x <- as.call(c(quote(`{`), parse(file = x)))
      } else {
        ## fail as x is of an unsupported type
        stop("x must be a function, a call or a path to an R script")
      }
    }

    ## is swap arg TRUE ?
    if (swap) {
      ## swap if calls in the fetched body
      x <- swap_calls(x)
    }
    ## build data from x
    data <- add_data_from_expr(data, x, narrow = narrow)

    ## add the final node
    id <- get_last_id(data) + 1
    data <- add_node(data, id, "return")

    ## was a `range` arg given ?
    if (!is.null(range)) {
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

    }

    # we remove the remaining `#`() calls, not super clean but does the job

    ## remove misplaced special comments
    data$nodes$code <- lapply(data$nodes$code, function(x){
      if(is.list(x) && length(x) && is.call(x[[1]])) {
        txt <- deparse(x[[1]], width.cutoff = 500)
        txt <- gsub("`#`\\(.*?\\)", "", txt)
        str2lang(paste(txt, collapse = "\n"))
      } else x
    })
    data$nodes$code_str <- gsub("`#`\\(.*?\\);", "", data$nodes$code_str)

    ## return data
    data
  }
