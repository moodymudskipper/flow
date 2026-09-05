flow_data <-
  function(x, prefix = NULL, narrow = FALSE, nested_fun = NULL, swap = TRUE, truncate = NULL) {

    ## fetch fun name from quoted input
    f_sym <- substitute(x)

    is_valid_named_list <-
      is.list(x) && length(x) == 1 && allNames(x) != ""

    ## is `x` a named list ?
    if(is_valid_named_list) {
      ## replace fun name and set the new `x`
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

    ## was the nested_fun argument NA (print nothing)
    if(length(nested_fun) != 1 || !is.na(nested_fun)) {

      ## was the nested_fun argument given ?
      if (!is.null(nested_fun)) {

        if(length(nested_fun) != 1 || !typeof(nested_fun) %in% c("character", "integer", "double")) {
          stop("`nested_fun` must be a string or a number.", call. = FALSE)
        }

        if (is.character(nested_fun)) {
          if (!nested_fun %in% names(sub_funs)) {
            stop("No nested function definition for `", nested_fun, "` was found.", call. = FALSE)
          }
          ## replace fun name
          f_sym <- as.symbol(nested_fun)
        } else {
          if (nested_fun > length(sub_funs) ) {
            stop(
              "Found ", length(sub_funs), " nested functions. Index `",
              nested_fun, "` is out of bounds.", call. = FALSE)
          }
          ## replace fun name
          f_sym <- quote(fun)
        }

        ## set the new `x`
        x <- eval(sub_funs[[nested_fun]])
      } else {
        ## do we have sub function definitions ?
        if (length(sub_funs)) {
          ## print them
          # so user can choose a nested_fun if relevant
          message("We found function definitions in this code, ",
                  "use the argument nested_fun to inspect them")
          print(sub_funs)
        }
      }
    }

    ## is `x` a function ?
    if (is.function(x)) {
      ## build function header node and edge
      title <- deparse(args(x), width.cutoff = 60L)
      title <- styler::style_text(title)
      title <- paste(title, collapse = "\n  ")
      title <- sub(" \\{\\n    NULL\\n  \\}$", "", title)
      title <- trimws(sub("^function", deparse(f_sym), title))
      data <- add_node(
        data,
        id = 0L,
        "header",
        #code = f_sym,
        code_str = title)
      data <- add_edge(data, from = 0L, to = 1L)

      ## is the function traced ?
      if(is_flow_traced(x)) {
        ## set `x` as  body of original function
        x <- body(attributes(x)$original)
      } else {
        ## set `x` as  body of function
        x <- body(x)
      }

    } else {
      ## is x a string (presumably a path) ?
      if (is.character(x) && length(x) == 1) {
        ## set `x` as parsed code from file
        x <- as.call(c(quote(`{`), parse(file = x)))
      } else {
        ## is `x` a call ?
        if(!is.call(x)) {
          ## fail: unsupported type
          stop("x must be a function, a call or a path to an R script")
        }
      }
    }

    ## is swap arg TRUE ?
    if (swap) {
      ## swap if calls in the fetched body
      x <- swap_calls(x)
    }
    ## build data from x
    data <- add_data_from_expr(data, x, narrow = narrow)

    # add the final node
    id <- get_last_id(data) + 1
    data <- add_node(data, id, "return")

    # extract nested control flow
    is_cf_call <- function(x) {
      is.call(x) && list(x[[1]]) %in% c(quote(`if`), quote(`repeat`), quote(`for`), quote(`while`))
    }
    localize_control_flow <- function(call, i = integer()) {
      if (!is.call(call)) return(0)
      if (is_cf_call(call[[1]])) return(i)
      if (identical(call[[1]], quote(`{`)) && any(sapply(as.list(call[-1]), is_cf_call))) {
        return(i)
      }
      inds <- Map(localize_control_flow, call = call, i = seq_along(call))
      keep <- Filter(function(x) !identical(x[[length(x)]], 0), inds)
      if (!length(keep)) return(0)
      lapply(keep, function(x) c(i, unlist(x)))
    }

    block_inds <- which(data$nodes$block_type == "standard")
    for (i in block_inds) {
      block <- str2lang(paste0("{", data$nodes$code_str[[i]], "}"))
      cf_inds <- localize_control_flow(block)
      if (identical(cf_inds, 0)) next
      for (j in seq_along(cf_inds)) {
        sub_data <- flow_data(list(f=as.function(list(block[[cf_inds[[j]]]]))))
        sub_data$edges <- sub_data$edges[-1,]
        sub_data$nodes <- sub_data$nodes[-1,]
        sub_code <- do.call(build_nomnoml_code, c(list(sub_data,code = TRUE, header = FALSE)))

        block[[cf_inds[[j]]]] <- "`\U{2194}\U{FE0F}`"
        # create new block and new edge
        from <- data$nodes$id[[i]]
        to <- paste0(from, strrep("*", j))

        data$nodes <- rbind(
          data$nodes,
          data.frame(id = to, block_type = "nested", code_str = sub_code, label = "")
          )
        data$edges <- rbind(
          data$edges,
          data.frame(from = from, to = to, edge_label = "", arrow = "--")
        )
      }
      code_str <- sapply(as.list(block)[-1], robust_deparse)
      code_str <- styler::style_text(code_str)
      code_str <- paste(code_str, collapse = "\n")
      data$nodes$code_str[[i]] <- code_str
    }
    data$nodes$code_str <- gsub('"`\U{2194}\U{FE0F}`"', "{\U{2194}\U{FE0F}}", data$nodes$code_str)

    # we remove the remaining `#`() calls, not super clean but does the job

    ## remove misplaced special comments
    data$nodes$code_str <- gsub("`#`\\(.*?\\);", "", data$nodes$code_str)

    dbl_space <- paste0(getOption("flow.indenter"), " ")
    data$nodes$code_str <- gsub("  ", dbl_space, data$nodes$code_str)

    if(!is.null(truncate)) {
      data$nodes$code_str <- sapply(
        strsplit(data$nodes$code_str, "\n"),
        function(x) paste(
          ifelse(nchar(x) > truncate, paste0(substr(x, 1, truncate-3),"..."), x),
          collapse = "\n"))
      data$nodes$label <- sapply(
        strsplit(data$nodes$label, "\n"),
        function(x) paste(
          ifelse(nchar(x) > truncate, paste0(substr(x, 1, truncate-3),"..."), x),
          collapse = "\n"))
    }

    ## return data
    data
  }
