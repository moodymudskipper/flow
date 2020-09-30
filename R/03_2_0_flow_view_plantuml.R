flow_view_plantuml <- function(x_chr, x, prefix, sub_fun_id, swap, out, svg) {

  if(is.function(x) && is.null(body(x)))
    stop("`", x_chr,
         "` doesn't have a body (try `body(", x_chr,
         ")`). {flow}'s functions don't work on such inputs.")

  # relevant only for functions
  # put comments in `#`() calls so we can manipulate them as code,
  # the function `build_blocks()`, called itself in `add_data_from_expr()`,
  # will deal with them further down the line
  x <- add_comment_calls(x, prefix)

  # deal with sub functions (function definitions found in the code)
  sub_funs <- find_funs(x)
  if (!is.null(sub_fun_id)) {
    # if we gave a sub_fun_id, make this subfunction our new x
    x_chr <- "fun"
    x <- eval(sub_funs[[sub_fun_id]])
  } else {
    if (length(sub_funs)) {
      # else print them for so user can choose a sub_fun_id if relevant
      message("We found function definitions in this code, ",
              "use the argument sub_fun_id to inspect them")
      print(sub_funs)
    }
  }

  # header and start node
  if(is.function(x)) {
    header <- deparse_plantuml(args(x))
    # remove the {}
    #header <- paste(header[-length(header)], collapse = "\\n")
    header <- substr(header, 1, nchar(header) - 11)
    # replace the function(arg) by my_function(arg)
    header <- sub("^function", x_chr, header)
    # make it a proper plantuml title
    header <- paste0("title ", header, "\nstart\n")
  } else {
    header <- "start\n"
  }

  # main code
  body_ <- body(x)
  if (swap) body_ <- swap_calls(body_)
  code_str <- build_plantuml_code(body_, first = TRUE)
  # concat params, header and code
  code_str <- paste0(plantuml_skinparam,"\n", header, code_str)

  gfn <- getFromNamespace
  plantuml <- gfn("plantuml", "plantuml")
  plant_uml_object <- plantuml(code_str)

  if(is.null(out)) {
    plot(plant_uml_object, vector = svg)
    return(NULL)
  }

  is_tmp <- out %in% c("html", "htm", "png", "pdf", "jpg", "jpeg")
  if (is_tmp) {
    out <- tempfile("flow_", fileext = paste0(".", out))
  }
  plot(plant_uml_object, vector = svg, file = out)

  if (is_tmp) {
    message(sprintf("The diagram was saved to '%s'", gsub("\\\\","/", out)))
    browseURL(out)
  }
  NULL
}
