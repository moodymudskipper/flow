#' View function as flow chart
#'
#' `flow_view()` shows the code of a function as a flow diagram, `flow_run()`
#' runs a call and draws the logical path taken by the code.
#'
#' @param x A call, a function, or a path to a script
#' @param prefix prefix to use for special comments in our code used as block headers,
#'   must start with `"#"`
#' @param nested_fun if not NULL, the index or name of the function definition found in
#'   x that we wish to inspect
#' @param swap whether to change `var <- if(cond) expr` into
#'   `if(cond) var <- expr` so the diagram displays better
#' @param narrow `TRUE` makes sure the diagram stays centered on one column
#'   (they'll be longer but won't shift to the right)
#' @inheritParams build_nomnoml_code
#' @param browse whether to debug step by step (block by block),
#'   can also be a vector of block ids, in this case `browser()` calls will be
#'   inserted at the start of these blocks
#' @param show_passes label the edges with the number of passes
#' @param out a path to save the diagram to.
#'   Special values "html", "htm", "png", "pdf", "jpg" and "jpeg" can be used to
#'   export the objec to a temp file of the relevant format and open it,
#'   if a regular path is used the format will be guessed from the extension.
#' @param svg only for default or html output, whether to use svg rendering, rendering
#'   is more robust without it, but it makes text selectable on output which is
#'    sometimes useful
#' @param engine Either `"nomnoml"` (default) or `"plantuml"` (experimental), if
#'   the latter, arguments `prefix`, `narrow`, and `code`
#' @param engine_opts A named list, see details section.
#'
#' In the most general case `engine_opts` is a list containing optional sub-lists named
#' `"nomnoml"`, `"plantuml"`, and `"htmlwidgets"`.
#'
#'  - The items of the `nomnoml`
#'   sub-list will be forwarded to `nomnoml:::build_nomnoml_code()`, unexported but
#'   documented in `?build_nomnoml_code`, in order to alter
#'   *nomnoml* diagrams. For instance `fontSize`, `direction = "right"` to have a left to right
#'   diagram, `ranker = "longest-path"` to see have exit points at the bottom...
#'   - The items of the `plantuml` sub-list will be forwarded to `plantuml:::plot.plantuml()`,
#'   , in order to alter  *plantuml* diagrams.
#'   see `?plantuml:::plot.plantuml` and `?plantuml::plantuml_run`
#'   - The items of the `htmlwidgets` sub-list will be forwarded to
#'   `htmlwidgets::createWidget()` or `htmlwidgets::saveWidget()`, which are used by
#'   the *nomnoml* engine.
#'
#' If this structure is not found, the items of `engine_opts` will be forwarded
#' to `nomnoml:::build_nomnoml_code()` if the engine is `"nomnoml"`, and
#' `plantuml:::plot.plantuml` if the engine is `"plantuml"`
#'
#'
#' @export
flow_view <- function(
  x, prefix = NULL, nested_fun = NULL, swap = TRUE, narrow = FALSE, code = TRUE,
  out = NULL, svg = FALSE,
  engine = c("nomnoml", "plantuml"),
  engine_opts = getOption("flow.engine_opts")) {

  engine_opts <- as.list(engine_opts)
  htmlwidgets_opts <- engine_opts[["html_widgets"]]
  if(any(names(engine_opts) %in% c("nomnoml", "plantuml", "htmlwidgets"))) {
    if(!all(names(engine_opts) %in% c("nomnoml", "plantuml", "htmlwidgets")))
      stop("engine_opts should be a list containing only lists named ",
           "'nomnoml', 'plantuml' or 'htmlwidgets', or a list of parameters to",
           "forward to the relevant engine function (either `nomnoml::nomnoml` ",
           "or plantuml:::plot.plantuml.")
    engine_opts <- engine_opts["engine"]
  }

  engine = match.arg(engine)

    ## fetch fun name from quoted input

    f_chr <- deparse(substitute(x))
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
      # if(!requireNamespace("plantuml"))
      #   stop("The package plantuml needs to be installed to use this feature. ",
      #        'To install it run `remotes::install_github("rkrug/plantuml")`, ',
      #        "You might also need to install java ('https://www.java.com'), ",
      #        "ghostcript ('https://www.ghostcript.com'), ",
      #        "and graphViz ('https://graphviz.org/')")

      # we should aim at diminishing this list as much as possible
      # narrow, should not be relevant
      # code = FALSE is easy
      # prefix and code = NA are hard

      ## are any unsupported argument not missing ?
      if(!missing(prefix) ||
         !missing(narrow) || !missing(code)) {
        ## warn that they will be ignored
        warning("The following arguments are ignored if `engine` is set to ",
                "\"plantuml\" : `prefix`, `narrow`, `code`")
      }

      ## run flow_view_plantuml
      flow_view_plantuml(
        x_chr = f_chr,
        x = x,
        prefix = prefix,
        nested_fun = nested_fun,
        swap = swap,
        out = out,
        svg = svg,
        engine_opts = engine_opts)
      return(invisible(NULL))
    }

    ## run flow_view_nomnoml
    flow_view_nomnoml(
      f_chr = f_chr,
      x  = x,
      prefix  = prefix,
      nested_fun = nested_fun,
      swap = swap,
      narrow = narrow,
      code = code,
      out = out,
      svg = svg,
      engine = engine,
      engine_opts = engine_opts,
      htmlwidgets_opts = htmlwidgets_opts)
}


