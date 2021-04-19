build_plantuml_code <- function(expr, first = FALSE, truncate) {
  ## is `expr` a `{` expression
  if(is.call(expr) && identical(expr[[1]], quote(`{`))) {
    ## are the {} empty ?
    if(length(expr) == 1) {
      return("")
    }
    ## build a list of calls
    calls <- as.list(expr)[-1]
  } else {
    ## put the call in a list
    calls <- list(expr)
  }

  ## split calls into blocks

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

  ## is it the first call (not a recursion) and the last block contains several calls
  if(first && length(blocks[[n_blocks]]) > 1) {
    ## separate the last call from the last block so it can be highlighted later
    l_last_block <- length(blocks[[n_blocks]])
    blocks[[n_blocks+1]] <- blocks[[n_blocks]][l_last_block]
    blocks[[n_blocks]] <- blocks[[n_blocks]][-l_last_block]
    n_blocks <- n_blocks + 1
  }

  ## turn blocks to code
  res <- sapply(blocks, block_to_plantuml, truncate)

  ## is it the first call ?
  if(first) {
    ## is the last block uncolored
    if(startsWith(res[[n_blocks]], ":")) {
      ## color it green
      res[[n_blocks]] <- paste0("#70ad47", res[[n_blocks]])
    } else {
      ## is it an if call ?
      if(startsWith(res[[n_blocks]], "#e2efda:if")) {
        ## change its color
        res[[n_blocks]] <- sub("^#e2efda", "#70ad47", res[[n_blocks]])
      }
    }
    ## is the code of the last block not "stop"
    if(res[[n_blocks]] != "stop") {
      ## add "stop"
      res[[n_blocks]] <- paste0(res[[n_blocks]], "\nstop")
    }
  }

  ## return the plantuml code as a string
  paste(res, collapse="\n")
}


block_to_plantuml <- function(expr, truncate) {

  ## is it a list containing several items ?
  if(length(expr) > 1) {
    ## deparse all expressions and build plantuml code
    deparsed <- sapply(expr, deparse_plantuml, truncate)
    deparsed <- paste0(":",deparsed, ";")
    deparsed <- paste(deparsed, collapse = "\n")
    return(deparsed)
  }

  ## set expr to the first and unique element of the block
  expr <- expr[[1]]

  ## does it contain only a symbol or literal (not a call) ?
  if(!is.call(expr)) {
    ## deparse all expressions and build plantuml code
    deparsed <- deparse_plantuml(expr, truncate)
    return(paste0(":", deparsed, ";"))
  }

  ## is it an `if` call ?
  if(identical(expr[[1]], quote(`if`))) {
    ## build code for 'if () then ()'
    if_txt   <- sprintf(
      "#e2efda:if (if(%s)) then (y)",
      deparse_plantuml(expr[[2]], truncate))
    yes_txt <- build_plantuml_code(expr[[3]], truncate = truncate)

    ## is there an `else` clause ?
    if (length(expr) == 4) {
      ## build code for else and "endif"
      elseif_txt <- build_elseif_txt(expr[[4]], truncate)
      txt <- paste(if_txt, yes_txt, elseif_txt, "endif", sep = "\n")
    } else {
      ## build code for "endif"
      txt <- paste(if_txt, yes_txt, "endif", sep = "\n")
    }
    ## return code
    return(txt)
  }

  ## is it a `while` call ?
  if(identical(expr[[1]], quote(`while`))) {
    ## build code for "while"
    while_txt   <- sprintf(
      "#fff2cc:while (while(%s))",
      deparse_plantuml(expr[[2]], truncate))
    expr_txt <- build_plantuml_code(expr[[3]], truncate = truncate)
    txt <- paste(while_txt, expr_txt, "endwhile", sep = "\n")
    return(txt)
  }

  ## is it a `for` call ?
  if(identical(expr[[1]], quote(`for`))) {
    ## build code for "for"
    for_txt   <- sprintf(
      "#ddebf7:while (for(%s in %s))",
      deparse_plantuml(expr[[2]], truncate),
      deparse_plantuml(expr[[3]], truncate))
    expr_txt <- build_plantuml_code(expr[[4]], truncate = truncate)
    txt <- paste(for_txt, expr_txt, "endwhile", sep = "\n")
    return(txt)
  }

  ## is it a `repeat` call ?
  if(identical(expr[[1]], quote(`for`))) {
    ## build code for "repeat"
    repeat_txt   <- "#fce4d6:while (repeat)"
    expr_txt <- build_plantuml_code(expr[[2]], truncate = truncate)
    txt <- paste(repeat_txt, expr_txt, "endwhile", sep = "\n")
    return(txt)
  }

  ## is it a `stop` call ?
  if(identical(expr[[1]], quote(`stop`))) {
    ## build code for "stop"
    stop_txt <- deparse_plantuml(expr, truncate)
    return(paste0("#ed7d31:",stop_txt, ";\nstop"))
  }

  ## is it a `return` call ?
  if(identical(expr[[1]], quote(`return`))) {
    ## build code for "return"
    return_txt   <- deparse_plantuml(expr, truncate)
    return(paste0("#70ad47:",return_txt, ";\nstop"))
  }

  ## is it a single regular call ?
  paste0(":", deparse_plantuml(expr, truncate), ";")
}
