#' @export
#' @rdname flow_view
flow_data <-
  function(x, range = NULL, prefix = NULL, sub_fun_id = NULL, swap = FALSE,
           narrow = FALSE) {
    f_sym <- substitute(x)

    # build data from the function body
    data <- new_data()

    # put comments in `#`() calls so we can manipulate them as code
    # relevant only for functions
    x <- add_comment_calls(x, prefix)

    sub_funs <- find_funs(x)
    if (!is.null(sub_fun_id)) {
      f_sym <- quote(fun)
      x <- eval(sub_funs[[sub_fun_id]])
    } else {
      if (length(sub_funs)) {
        message("We found function definitions in this code, ",
                "use the argument sub_fun_id to inspect them")
        print(sub_funs)
      }
    }
    if (is.function(x)) {
      title <- head(deparse(args(x)), -1)
      title <- paste(title, collapse = "\n  ")
      title <- trimws(sub("^function ", deparse(f_sym), title))
      data <- add_node(
        data,
        id = 0L,
        "header",
        code = f_sym,
        code_str = title)
      data <- add_edge(data, from = 0L, to = 1L)
      if (swap) body(x) <- swap_calls(body(x))
      data <- add_data_from_expr(data, body(x), narrow = narrow)
    } else if (is.call(x)) {
      if (swap)  x <- swap_calls(x)
      data <- add_data_from_expr(data, x, narrow = narrow)
    } else if (is.character(x) && length(x) == 1) {
      x <- as.call(c(quote(`{`), parse(x)))
      if (swap) x <- swap_calls(x)
      data <- add_data_from_expr(data, x, narrow = narrow)
    } else {
      stop("x must be a function or a call")
    }

    # add the final node
    id = get_last_id(data) + 1
    data <- add_node(data, id, "return")
    if (!is.null(prefix)) {
      prefix <- paste0("^\\s*", prefix,"\\s*")
      data$nodes$label <- sub(prefix, "", data$nodes$label)
    }
    if (!is.null(range)) {
      if (length(range) != 2)
        stop("`range` should be of length 2")
      range <- sort(range)
      range[2] <- min(max(data$nodes$id), range[2])
      matches <- which(data$nodes$id %in% range)
      start <- min(matches)
      end   <- max(matches)
      data0 <- data
      if (min(range) <= 1) {
        data$nodes <- data$nodes[1:end,]
        data$edges <- data$edges[
          data$edges$from %in% data$nodes$id &
            data$edges$to %in% data$nodes$id,]
      } else {
        data$nodes <- rbind(
          data.frame(id = 0, block_type = "header", code_str = ". . .",
                     label = "", code = "", stringsAsFactors =  FALSE),
          data$nodes[start:end,])
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

      max_id <- max(data0$nodes$id)
      if (max(range) < max_id) {
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
    data
  }
