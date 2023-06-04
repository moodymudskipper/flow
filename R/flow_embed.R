# nocov start

#' Embed chart in roxygen doc
#'
#' Include a call `` `r_flow::flow_embed(...)` `` in your doc and a diagram will be
#' included.
#'
#' * As with images in general the image might not be visible when viewing
#' temp doc with the devtools workflow.
#' * Don't forget to add {flow} to Suggests in your DESCRIPTION file.
#' * We don't monitor files created under 'man/figures', so if you remove a
#'   diagram from the doc make sure to also remove it from the folder.
#' * We also don't overwrite created files, so we don't slow down the documentation
#'   process, so if you want to print a different diagram for the same name remove
#'   the file first.
#'
#' @param call A call to a flow function, prefixed with `flow::`
#' @param name A name for the png file that will be created under 'man/figures',
#'   without extension.
#' @param width width, relative if < 1, pixels otherwise
#' @param alt alt text
#'
#' @return Called for side effects, should only be used in roxygen doc
#' @export
flow_embed <- function(call, name, width = 1, alt = name) {
  if (missing(name)) stop("please provide a name for the embedded diagram")
  name <- paste0(name, ".png")
  path <- file.path("man/figures", name)
  call <- substitute(call)
  if (!file.exists(path)) {
    call$out <- path
    eval.parent(call)
  }
  sprintf(
    '\\if{html}{\\figure{%s}{options: width="%s\\%%" alt="%s"}}',
    name,
    width*100,
    alt
  )
}

# nocov end
