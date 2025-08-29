#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom lifecycle deprecated
## usethis namespace: end
NULL

#' options for the 'flow' package
#'
#' * `flow.indenter`: To circumvent a limitation from nomnoml we use by default
#' the Braille character `"\u2800"` in places where consecutive standard
#' spaces would be ignored. On some systems it doesn't print nicely though,
#' `"\u00b7"` is another option that looks nice.
#' * `flow.svg`: Whether to use svg graphics in html or viewer output.
#' * `flow.webshot2`: Whether to use 'webshot2', set to `FALSE` to use 'webshot'
#' as was the default until version `0.2.0`.
#'
#' @aliases flow.indenter flow.svg flow.webshot2
#' @name flow-options
NULL
