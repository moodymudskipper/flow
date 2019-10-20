view_flow <- function(f, prefix = NULL, ...){
  f_sym <- substitute(f)

  # put comments in `#`() calls
  f <- add_comment_calls(f, prefix)
  # build data from the function body
  data <- new_data()
  data <- add_node(
    data,
    id = 1L,
    "header",
    code = f_sym,
    code_str = deparse(f_sym))
  data <- add_edge(data, from=1L, to = 2L)
  data <- add_data_from_expr(data, body(f))

  # add the final node
  id = get_last_id(data) + 1
  data <- add_node(data, id, "end")

  code <- build_nomnoml_code(data, ...)
  nomnoml::nomnoml(code)
}
# cat(paste(strsplit(code,"\n")[[1]][1:400],collapse = "\n"))
