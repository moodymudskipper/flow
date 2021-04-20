flow_view_plantuml <- function(
  x_chr, x, prefix, truncate, nested_fun, swap, out, svg = FALSE) {

  if(!is.null(out) && !sub("^.*?\\.(.*?)", "\\1", out) %in% c("png", "jpg", "jpeg"))
    stop("the 'plantuml' engine is only compatible with 'png', 'jpg', 'jpeg' output")

  ## is x a bodiless function ?
  if(is.function(x) && is.null(body(x))) {
    ## fail explicitly
    stop("`", x_chr,
         "` doesn't have a body (try `body(", x_chr,
         ")`). {flow}'s functions don't work on such inputs.")
  }

  # relevant only for functions
  # put comments in `#`() calls so we can manipulate them as code,
  # the function `build_blocks()`, called itself in `add_data_from_expr()`,
  # will deal with them further down the line
  # if(!is.null(prefix))
  #   x <- add_comment_calls(x, prefix)

  ## find sub functions (function defs found in the code)
  sub_funs <- find_funs(x)

  ## was the nested_fun argument given ?
  if (!is.null(nested_fun)) {
    ## replace fun name and set the new `x`
    x_chr <- "fun"
    x <- eval(sub_funs[[nested_fun]])
  } else {
    ## do we have sub function definitions ?
    if (length(sub_funs)) {
      ## print them
      message("We found function definitions in this code, ",
              "use the argument nested_fun to inspect them")
      print(sub_funs)
    }
  }

  ## is `x` a function ?
  if(is.function(x)) {
    ## build function header code
    header <- deparse_plantuml(args(x), truncate)
    # remove the {}
    #header <- paste(header[-length(header)], collapse = "\\n")
    header <- substr(header, 1, nchar(header) - 13)
    # replace the function(arg) by my_function(arg)
    header <- sub("^function", x_chr, header)
    # make it a proper plantuml title
    header <- paste0("title ", header, "\nstart\n")

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
      ## set `x` as parsed code from file and set header code
      x <- as.call(c(quote(`{`), parse(file = x)))
      header <- "start\n"
    } else {
      ## is `x` a call ?
      if(!is.call(x)) {
        ## fail: unsupported type
        stop("x must be a function, a call or a path to an R script")
      } else {
        ## set header code
        header <- "start\n"
      }
    }
  }

  ## is swap arg TRUE ?
  if (swap) {
    ## swap if calls in the fetched body
    x <- swap_calls(x)
  }

  ## build rest of plantuml code and plantuml object
  code_str <- build_plantuml_code(x, first = TRUE, truncate = truncate)
  # concat params, header and code
  code_str <- paste0(plantuml_skinparam,"\n", header, code_str)

  plantuml <- gfn("plantuml", "plantuml")
  plant_uml_object <- plantuml(code_str)



  ## is `out` NULL ?
  if(is.null(out)) {
    ## plot the object and return NULL
    do.call(plot, c(list(plant_uml_object, vector = svg)))
    return(invisible(NULL))

  }

  ## flag if out is a temp file shorthand
  is_tmp <- out %in% c("html", "htm", "png", "pdf", "jpg", "jpeg")

  ## is it ?
  if (is_tmp) {
    ## set out to a temp file with the right extension
    out <- tempfile("flow_", fileext = paste0(".", out))
  }

  ## plot the object
  do.call(plot, c(list(plant_uml_object, file = out, vector = svg)))

  ## was the out argument a temp file shorthand ?
  if (is_tmp) {
    ## print location of output and open it
    message(sprintf("The diagram was saved to '%s'", gsub("\\\\","/", out)))
    browseURL(out)
  }
  ## return the path to the output invisibly
  invisible(out)
}
