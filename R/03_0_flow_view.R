#' View function as flow chart
#'
#' * `flow_view()` shows the code of a function as a flow diagram
#' * `flow_run()` runs a call and draws the logical path taken by the code.
#' * `flow_compare_runs()` shows on the same diagrams 2 calls to the same functions,
#'   code blocks that are only touched by the `ref` call are colored green, code blocks
#'   that are only touched by the `x` call are colored orange.
#'
#' On some systems the output might sometimes display the box character when using
#' the nomnoml engine, this is due to the system not recognizing the Braille
#' character `\u2800`. This character is used to circumvent a shortcoming of the
#' nomnoml library:
#' lines can't start with a standard space and multiple subsequent spaces might be collapsed.
#' To choose another character, set the option `flow.indenter`, for instance :
#' `options(flow.indenter = "\u00b7")`. Setting the `options(flow.svg = FALSE)`
#' might also help.
#'
#' @param x a call, a function, or a path to a script
#' @param prefix prefix to use for special comments in our code used as block headers,
#'   must start with `"#"`, several prefixes can be provided
#' @param code Whether to display the code in code blocks or only the header,
#' to be more compact, if `NA`, the code will be displayed only if no header
#' is defined by special comments
#' @param truncate maximum number of characters to be printed per line
#' @param nested_fun if not `NULL`, the index or name of the function definition found in
#'   x that we wish to inspect
#' @param swap whether to change `var <- if(cond) expr` into
#'   `if(cond) var <- expr` so the diagram displays better
#' @param narrow `TRUE` makes sure the diagram stays centered on one column
#'   (they'll be longer but won't shift to the right)
#' @param browse whether to debug step by step (block by block),
#'   can also be a vector of block ids, in this case `browser()` calls will be
#'   inserted at the start of these blocks
#' @param out a path to save the diagram to.
#'   Special values "html", "htm", "png", "pdf", "jpg" and "jpeg" can be used to
#'   export the object to a temp file of the relevant format and open it,
#'   if a regular path is used the format will be guessed from the extension.
#' @param engine either `"nomnoml"` (default) or `"plantuml"` (experimental, brittle
#'   mostly for reasons out of our control), if the latter, arguments `prefix`,
#'   `narrow`, and `code` are ignored
#' @return depending on `out` :
#'  * `NULL` (default) : `flow_view()` and `flow_compare_runs()` return a `"flow_diagram"`
#'   object, containing the diagram, the diagram's code and the data used to build
#'   the code. `flow_run()` returns the output of the call.
#'  * An output path or a file extension : the path where the file is saved
#'  * `"data"`:  a list of 2 data frames "nodes" and "edges"
#'  * `"code"`: A character vector of class "flow_code"
#'
#' @export
#' @examples
#' flow_view(rle)
#' flow_run(rle(c(1, 2, 2, 3)))
#' flow_compare_runs(rle(NULL), rle(c(1, 2, 2, 3)))
flow_view <- function(
    x,
    prefix = NULL,
    code = TRUE,
    narrow = FALSE,
    truncate = NULL,
    nested_fun = NULL,
    swap = TRUE,
    out = NULL,
    engine = c("nomnoml", "plantuml")) {

  engine <- match.arg(engine)

  ## fetch fun name from quoted input

  f_chr <- deparse1(substitute(x))
  is_valid_named_list <-
    is.list(x) && length(x) == 1 && !is.null(names(x))

  ## is `x` a named list ?
  if(is_valid_named_list) {
    ## replace fun name and set the new `x`
    f_chr <- names(x)
    x <- x[[1]]
  }

  ## is the engine "plantuml" ?
  if(engine == "plantuml") {
    if(!length(find.package("plantuml", quiet = TRUE)))
      stop("The package plantuml needs to be installed to use this feature. ",
           'To install it run `remotes::install_github("rkrug/plantuml")`, ',
           "You might also need to install java ('https://www.java.com'), ",
           "ghostcript ('https://www.ghostcript.com'), ",
           "and graphViz ('https://graphviz.org/')")

    ## are any unsupported argument not missing ?
    if(!is.null(prefix) ||
       narrow || !code) {
      ## warn that they will be ignored
      warning("The following arguments are ignored if `engine` is set to ",
              "\"plantuml\" : `prefix`, `narrow`, `code`")
    }

    ## run flow_view_plantuml
    return(flow_view_plantuml(
      x_chr = f_chr,
      x = x,
      prefix = prefix,
      truncate = truncate,
      nested_fun = nested_fun,
      swap = swap,
      out = out))
  }

  ## run flow_view_nomnoml
  flow_view_nomnoml(
    f_chr = f_chr,
    x  = x,
    prefix  = prefix,
    truncate = truncate,
    nested_fun = nested_fun,
    swap = swap,
    narrow = narrow,
    code = code,
    out = out,
    engine = engine)
}


