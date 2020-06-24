#' @export
#' @rdname flow_view
flow_run <-
  function(x, range = NULL, prefix = NULL, sub_fun_id = NULL, transpose_if = TRUE, code = TRUE, ...) {
    call <- substitute(x)
    if(!is.call(call)) stop("x must be a call")
    fun_sym <- call[[1]]

    fun <- eval.parent(fun_sym)
    if(isS3stdGeneric(fun)) {
      fun_sym <- str2lang(getS3methodSym(deparse(fun_sym), eval.parent(call[[2]])))
      fun <- eval(fun_sym)
    }

    data <- eval.parent(as.call(list(
      quote(flow_data),fun_sym, substitute(range),
      substitute(prefix), substitute(sub_fun_id), substitute(transpose_if))))
    # we store vars created/updated in each block in local_vars
    `*temp_vars*` <- new.env()
    assign("*temp_vars*", `*temp_vars*`, envir = .GlobalEnv)
    # we create a function for each block and run it
    finished <- FALSE
    id <- 1
    data$nodes$entered   <- FALSE
    data$nodes$completed <- FALSE
    data$edges$arrow <- gsub("->", "--:>", data$edges$arrow, fixed= TRUE)
    on.exit({
      code <- build_nomnoml_code(data, code = code, ...)
      x <- list(code = code, svg = FALSE)
      widg <- htmlwidgets::createWidget(
        name = "nomnoml", x,
        package = "nomnoml")
      print(widg)
    })


    while(!finished) { # for (i in seq(nrow(data$nodes)))
      # if we fall on an "end" node, go to the next one
      if(id < 0) {
        ind <- with(data$edges, from == id & edge_label == "")
        id <- data$edges$to[ind]
        data$edges$arrow[ind] <- "->"
      }
      data$nodes$entered[data$nodes$id == id] <- TRUE
      node <- as.list(data$nodes[data$nodes$id == id,])
      if(node$block_type == "standard") {
        `*temp_fun*` <- fun
        body(`*temp_fun*`) <- bquote({
          #browser()
          # put all vars in environment
          list2env(mget(ls(all.names = TRUE,  `*temp_vars*`), `*temp_vars*`),
                   environment())
          # run code
          `*res*` <- .(as.call(c(quote(`{`), node$code[[1]])))
          `*vars*` <- ls(all.names = TRUE, environment())
          `*vars*` <- setdiff(`*vars*`, c("*res*", "..."))
          `*env*` <- environment()
          `*vars*` <- Filter(function(x)  !pryr:::is_promise2(as.name(x), `*env*`), `*vars*`)
          # put created vars back in environment
          list2env(mget(`*vars*`, `*env*`), `*temp_vars*`)
          `*res*`
        })
        temp_call <- call
        temp_call[[1]] <- quote(`*temp_fun*`)
        assign("*temp_fun*" , `*temp_fun*` , envir = .GlobalEnv)
        res <- eval.parent(temp_call)
        data$nodes$completed[data$nodes$id == id] <- TRUE
        ind <- data$edges$from == id
        id <- data$edges$to[ind]
      }
      if(node$block_type == "if") {
        `*temp_fun*` <- fun
        body(`*temp_fun*`) <- bquote({
          #browser()
          # put all vars in environment
          list2env(mget(ls(all.names = TRUE,  `*temp_vars*`), `*temp_vars*`),
                   environment())
          # run code
          `*res*` <- .(node$code[[1]])
          # put created vars back in environment
          `*vars*` <- ls(all.names = TRUE, environment())
          `*vars*` <- setdiff(`*vars*`, c("*res*", "..."))
          `*env*` <- environment()
          `*vars*` <- Filter(function(x)  !pryr:::is_promise2(as.name(x), `*env*`), `*vars*`)
          list2env(mget(`*vars*`), `*temp_vars*`)
          # clean env
          `*res*`
        })
        temp_call <- call
        temp_call[[1]] <- quote(`*temp_fun*`)
        assign("*temp_vars*", `*temp_vars*`, envir = .GlobalEnv)
        assign("*temp_fun*", `*temp_fun*`, envir = .GlobalEnv)
        res <- eval.parent(temp_call)
        data$nodes$completed[data$nodes$id == id] <- TRUE
        if(res) {
          ind <- with(data$edges, from == id & edge_label == "y")
          id <- data$edges$to[ind]
        } else {
          ind <- with(data$edges, from == id & edge_label == "n")
          id <- data$edges$to[ind]
        }
      }
      if(node$block_type == "return") {
        return(res)
      }
      data$edges$arrow[ind] <- "->"
    }
    data
  }

#NSE will pose problem so we should evaluate each block as a call to a function
# with the original arguments + the local variables created by preceding blocks

#flow_run(median.default(1:3))

