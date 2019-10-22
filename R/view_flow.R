#' View function as flow chart
#'
#' @param f
#'
#' @param prefix prefix to use for special comments, must start with `"#"` (not implemented yet)
#' @param ... additional parameters passed to `build_nomnoml_code()`
#'
#' @export
view_flow <- function(f, prefix = NULL, code = TRUE, png = NULL, width = NULL,
                      height = NULL, output = c("view", "nomnoml", "data"),...){
  output <- match.arg(output)
  f_sym <- substitute(f)

  # put comments in `#`() calls
  f <- add_comment_calls(f, prefix)
  # build data from the function body
  data <- new_data()
  data <- add_node(
    data,
    id = 0L,
    "header",
    code = f_sym,
    code_str = deparse(f_sym))
  data <- add_edge(data, from=0L, to = 1L)
  data <- add_data_from_expr(data, body(f))

  # add the final node
  id = get_last_id(data) + 1
  data <- add_node(data, id, "return")
  if(!is.null(prefix)){
    prefix <- paste0("^\\s*", prefix,"\\s*")
    data$nodes$label <- sub(prefix, "", data$nodes$label)
  }
  if (output == "data") return(data)
  code <- build_nomnoml_code(data, code = code, ...)
  if (output == "nomnoml") return(code)
  nomnoml::nomnoml(code, png = png, width = width, height = height)
}
# cat(paste(strsplit(code,"\n")[[1]][1:400],collapse = "\n"))
