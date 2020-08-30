plantuml_skinparam <- "
skinparam ActivityBorderColor black
skinparam ActivityBackgroundColor #ededed
skinparam SequenceGroupBorderColor black
skinparam ActivityDiamondBorderColor black
skinparam ArrowColor black
"
flow_view_plantuml <- function(fun_chr, f) {
  # header and start node
  header <- deparse(args(f))
  header <- paste(header[-length(header)], collapse = "\\n")
  header <- sub("^function", fun_chr, header)
  header <- paste0("title ", header, "\nstart\n")
  # main code
  code_str <- view_pant_ulm1(body(f), first = TRUE)

  # concat params, header and code
  code_str <- paste0(plantuml_skinparam,"\n", header, code_str)

  plant_uml_object <- plantuml::plantuml(code_str)
  plot(plant_uml_object, vector = FALSE) #, file = "test.png")
}

view_pant_ulm0 <- function(expr) {
  if(is.call(expr) && identical(expr[[1]], quote(`{`))) {
    exprs <- as.list(expr)[-1]
  } else {
    exprs <- list(expr)
  }

  res <- sapply(exprs, function(expr) {
    #### SYMBOL / LITTERAL
    if(!is.call(expr)) return(paste0(":", as.character(expr), ";"))

    #### IF
    if(identical(expr[[1]], quote(`if`))) {
      if_txt   <- sprintf(
        "#e2efda:if (if(%s)) then (y)",
        paste(deparse(expr[[2]]), collapse= "\\n"))
      yes_txt <- view_pant_ulm0(expr[[3]])
      if (length(exprs) == 4) {
        else_txt <- "else (n)"
        no_txt <-  view_pant_ulm0(expr[[4]])
        txt <- paste(if_txt, yes_txt, else_txt, no_txt, "endif", sep = "\n")
      } else {
        txt <- paste(if_txt, yes_txt, "endif", sep = "\n")
      }
      return(txt)
    }

    #### WHILE
    if(identical(expr[[1]], quote(`while`))) {
      while_txt   <- sprintf(
        "#fff2cc:while (while(%s))",
        paste(deparse(expr[[2]]), collapse= "\\n"))
      expr_txt <- view_pant_ulm0(expr[[3]])
      txt <- paste(while_txt, expr_txt, "endwhile", sep = "\n")
      return(txt)
    }

    #### FOR
    if(identical(expr[[1]], quote(`for`))) {
      for_txt   <- sprintf(
        "#ddebf7:while (for(%s in %s))",
        paste(deparse(expr[[2]]), collapse= "\\n"),
        paste(deparse(expr[[3]]), collapse= "\\n"))
      expr_txt <- view_pant_ulm0(expr[[4]])
      txt <- paste(for_txt, expr_txt, "endwhile", sep = "\n")
      return(txt)
    }

    #### REPEAT
    if(identical(expr[[1]], quote(`for`))) {
      repeat_txt   <- "#fce4d6:while (repeat)"
      expr_txt <- view_pant_ulm0(expr[[2]])
      txt <- paste(repeat_txt, expr_txt, "endwhile", sep = "\n")
      return(txt)
    }

    #### STOP
    if(identical(expr[[1]], quote(`stop`))) {
      stop_txt <- paste(deparse(expr), collapse= "\\n")
      return(paste0("#ed7d31:",stop_txt, ";\nstop"))
    }

    #### RETURN
    if(identical(expr[[1]], quote(`return`))) {
      return_txt   <- paste(deparse(expr), collapse= "\\n")
      return(paste0("#70ad47:",return_txt, ";\nstop"))
    }

    #### REGULAR CALL
    paste0(":", paste(deparse(expr), collapse = "\\n"), ";")
  })
  paste(res, collapse="\n")
}

view_pant_ulm1 <- function(expr, first = FALSE) {
  if(is.call(expr) && identical(expr[[1]], quote(`{`))) {
    calls <- as.list(expr)[-1]
  } else {
    calls <- list(expr)
  }

  # support empty calls (`{}`)
  if (!length(calls)) {
    blocks <- list(substitute()) # substitute() returns an empty call
    return(blocks)
  }
  # logical indices of control flow calls
  cfc_lgl <- calls %call_in% c("if", "for", "while", "repeat")

  # logical indices of comment calls `#`()
  special_comment_lgl <- calls %call_in% c("#")

  # there are 2 ways to start a block : be a cf not preceded by com, or be a com
  # there are 2 ways to finish a block : be a cf (and finish on next one), or start another block and finish right there

  # cf not preceded by com
  cfc_unpreceded_lgl <- cfc_lgl & !c(FALSE, head(special_comment_lgl, -1))
  # new_block (first or after cfc)
  new_block_lgl <- c(TRUE, head(cfc_lgl, -1))
  block_ids <- cumsum(special_comment_lgl | cfc_unpreceded_lgl | new_block_lgl)

  blocks <- split(calls, block_ids)

  n_blocks <- length(blocks)
  if(first && length(blocks[[n_blocks]]) > 1) {
    #browser()
    # at first iteration we separate the last call so it can be used as a return call
    l_last_block <- length(blocks[[n_blocks]])
    blocks[[n_blocks+1]] <- blocks[[n_blocks]][l_last_block]
    blocks[[n_blocks]] <- blocks[[n_blocks]][-l_last_block]
    n_blocks <- n_blocks + 1
  }

  res <- sapply(blocks, function(expr) {

    #### starts with SYMBOL / LITTERAL
    if(!is.call(expr[[1]]) || length(expr) > 1) {
      deparsed <- sapply(expr, function(x) paste(deparse(x), collapse = "\\n"))
      return(paste0(":", paste(deparsed, collapse = "\\n"), ";"))
    }

    expr <- expr[[1]]

    #### IF
    if(identical(expr[[1]], quote(`if`))) {
      # browser()
      if_txt   <- sprintf(
        "#e2efda:if (if(%s)) then (y)",
        paste(deparse(expr[[2]]), collapse= "\\n"))
      yes_txt <- view_pant_ulm1(expr[[3]])
      if (length(expr) == 4) {
        else_txt <- "else (n)"
        no_txt <-  view_pant_ulm1(expr[[4]])
        txt <- paste(if_txt, yes_txt, else_txt, no_txt, "endif", sep = "\n")
      } else {
        txt <- paste(if_txt, yes_txt, "endif", sep = "\n")
      }
      return(txt)
    }

    #### WHILE
    if(identical(expr[[1]], quote(`while`))) {
      while_txt   <- sprintf(
        "#fff2cc:while (while(%s))",
        paste(deparse(expr[[2]]), collapse= "\\n"))
      expr_txt <- view_pant_ulm1(expr[[3]])
      txt <- paste(while_txt, expr_txt, "endwhile", sep = "\n")
      return(txt)
    }

    #### FOR
    if(identical(expr[[1]], quote(`for`))) {
      for_txt   <- sprintf(
        "#ddebf7:while (for(%s in %s))",
        paste(deparse(expr[[2]]), collapse= "\\n"),
        paste(deparse(expr[[3]]), collapse= "\\n"))
      expr_txt <- view_pant_ulm1(expr[[4]])
      txt <- paste(for_txt, expr_txt, "endwhile", sep = "\n")
      return(txt)
    }

    #### REPEAT
    if(identical(expr[[1]], quote(`for`))) {
      repeat_txt   <- "#fce4d6:while (repeat)"
      expr_txt <- view_pant_ulm1(expr[[2]])
      txt <- paste(repeat_txt, expr_txt, "endwhile", sep = "\n")
      return(txt)
    }

    #### STOP
    if(identical(expr[[1]], quote(`stop`))) {
      stop_txt <- paste(deparse(expr), collapse= "\\n")
      return(paste0("#ed7d31:",stop_txt, ";\nstop"))
    }

    #### RETURN
    if(identical(expr[[1]], quote(`return`))) {
      return_txt   <- paste(deparse(expr), collapse= "\\n")
      return(paste0("#70ad47:",return_txt, ";\nstop"))
    }

    #### REGULAR CALL
    paste0(":", paste(deparse(expr), collapse = "\\n"), ";")
  })

  if(first) {
    if(startsWith(res[n_blocks], ":"))
      res[n_blocks] <- paste0("#70ad47", res[n_blocks])
    else if(startsWith(res[n_blocks], "#e2efda:if"))
      res[n_blocks] <- sub("^#e2efda", "#70ad47", res[n_blocks])
  }

  paste(res, collapse="\n")
}

# view_pant_ulm(median.default)
