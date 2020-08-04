add_comment_calls <- function(fun, prefix = "##"){
  if (is.null(prefix)) return(fun)
  src <- deparse(fun, width.cutoff = 500, control = "useSource")
  pattern <- paste0("^\\s*(", prefix, ".*?)$")
  src <- gsub(pattern, "`#`(\"\\1\")", src)
  src <- paste(src, collapse = "\n")
  src <- str2lang(src)
  eval(src)
}

