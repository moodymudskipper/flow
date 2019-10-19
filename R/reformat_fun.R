
###################################################

regularize_comments <- function(fun) {
  env <- environment(fun)
  fun <- deparse(fun)
  #fun <- gsub("(\\s*`#`\\(\")(.*?)\\\"\\)$","\\2", fun)
  fun <- gsub("(\\s*)`#`\\(\"(\\s*)(.*?)\\\"\\)$","\\1\\3", fun)
  fun <- gsub("\\\\n","\n",fun)
  eval(parse(text=paste(fun, collapse = "\n"))[[1]],envir = env)
}

unnest_comments <- function(call) {
  if(!is.call(call)) {
    return(call)
  }

  call0 <- lapply(call, function(x) {
    call_str <- paste(deparse(x), collapse ="\n")
    if(startsWith(call_str, "`#`(")){
      #is.call(x) && x[[1]] == quote(`#`) && length(x) == 3){
      # browser()
      x <- list(extract_comment(x),
                clean_call(x))
    }
    x
  })
  call <- as.call(unlist(call0))
  call[] <- lapply(call, unnest_comments)
  call
}


# helper for unnest_comments
extract_comment <- function(call){
  if(!is.call(call)) {
    return(NULL)
  }
  if(identical(call[[1]], quote(`#`))){
    return(call[1:2])
  }
  unlist(lapply(call, extract_comment))[[1]]
}

# helper for unnest_comments
clean_call <- function(call){
  if(!is.call(call)) {
    return(call)
  }
  if(identical(call[[1]], quote(`#`))){
    return(call[[3]])
  }
  call[] <- lapply(call, clean_call)
  call
}



is_syntactic <- function(x){
  tryCatch({str2lang(x); TRUE},
           error = function(e) FALSE)
}

nest_comments <- function(fun, prefix){
  src <- deparse(fun, control = "useSource")
  # positions of comments
  pattern       <- paste0("^\\s*", prefix)
  commented_lgl <- grepl(pattern, src)
  # positions of 1st comments of comment blocks
  first_comments_lgl <- diff(c(FALSE, commented_lgl)) == 1
  # ids of comment blocks along the lines
  comment_ids <- cumsum(first_comments_lgl) * commented_lgl
  # positions of 1st lines after comment blocks
  first_lines_lgl <- diff(!c(FALSE, commented_lgl)) == 1
  first_lines_ids <- cumsum(first_lines_lgl) * first_lines_lgl

  # we iterate through these ids, taking max from lines so if code ends with a
  # comment it will be ignored
  for(i in seq(max(first_lines_ids))){
    comments <- src[comment_ids == i]
    line_num <- which(first_lines_ids == i)
    line <- src[line_num]
    # we move forward character by character until we get a syntactic replacement
    # the code replacement starts with "`#`(" and we try all positions of 2nd
    # parenthese until something works, then deal with next code block

    j <- 0
    repeat {
      break_ <- FALSE
      j <- j+1
      line <- src[line_num]
      if(j == 1) code <- paste0("`#`('", paste(comments,collapse="\n"),"', ") else code[j] <- ""
      for(n_chr in seq(nchar(src[line_num]))){
        code[j] <- paste0(code[j], substr(line, n_chr, n_chr))
        if (n_chr < nchar(line))
          code_last_line <- paste0(code[j],")", substr(line, n_chr+1, nchar(line)))
        else
          code_last_line <- paste0(code[j],")")
        #print(code_last_line)
        src_copy <- src
        src_copy[(line_num-j+1):line_num] <- c(head(code,-1), code_last_line)
        if (is_syntactic(paste(src_copy,collapse="\n"))){
          src <- src_copy
          break_ <- TRUE
          break}
      }
      if(break_ || j == 7) break
      line_num <- line_num + 1
    }
  }
  eval(str2lang(paste(src, collapse = "\n")),envir = environment(fun))
}



repair_call <- function(call){
  if(!is.call(call)) {
    return(call)
  }
  # if
  if(call[[1]] == quote(`if`)) {
    if(!is.call(call[[3]]) || call[[3]][[1]] != quote(`{`))
      call[[3]] <- as.call(list(quote(`{`), call[[3]]))
    if(length(call) == 4 && (!is.call(call[[4]]) || call[[4]][[1]] != quote(`{`)))
      call[[4]] <- as.call(list(quote(`{`), call[[4]]))
    call[-1] <- lapply(as.list(call[-1]), repair_call)
    return(call)}
  # for
  if(call[[1]] == quote(`for`)) {
    if(!is.call(call[[4]]) || call[[4]][[1]] != quote(`{`))
      call[[4]] <- as.call(list(quote(`{`), call[[4]]))
    call[-1] <- lapply(as.list(call[-1]), repair_call)
    return(call)}
  # repeat
  if(call[[1]] == quote(`repeat`)) {
    if(!is.call(call[[2]]) || call[[2]][[1]] != quote(`{`))
      call[[2]] <- as.call(list(quote(`{`), call[[2]]))
    call[-1] <- lapply(as.list(call[-1]), repair_call)
    return(call)}
  # while
  if(call[[1]] == quote(`while`)) {
    if(!is.call(call[[3]]) || call[[3]][[1]] != quote(`{`)){
      call[[3]] <- as.call(list(quote(`{`), call[[3]]))
    }
    call[-1] <- lapply(as.list(call[-1]), repair_call)
    return(call)}
  call[] <- lapply(call, repair_call)
  call
}

add_comment_calls <- function(fun, prefix = "##"){
  if(is.null(prefix)) return(fun)
  fun <- nest_comments(fun, prefix)
  body(fun) <- repair_call(body(fun))
  body(fun) <- unnest_comments(body(fun))
  fun
}



