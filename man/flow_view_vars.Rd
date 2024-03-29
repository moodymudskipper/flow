% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/10_flow_view_vars.R
\name{flow_view_vars}
\alias{flow_view_vars}
\title{Draw the dependencies of variables in a function}
\usage{
flow_view_vars(
  x,
  expand = TRUE,
  refactor = c("refactored", "original"),
  out = NULL
)
}
\arguments{
\item{x}{The function, script or expression to draw}

\item{expand}{A boolean, if \code{FALSE} a variable name is only shown once, else
(the default) it's repeated and suffixed with a number of \code{*}}

\item{refactor}{If using 'refactor' package, whether to consider original or refactored code}

\item{out}{a path to save the diagram to.
Special values "html", "htm", "png", "pdf", "jpg" and "jpeg" can be used to
export the object to a temp file of the relevant format and open it,
if a regular path is used the format will be guessed from the extension.}
}
\value{
\code{flow_vars()} returns a \code{"flow_diagram"} object by default, and the output path invisibly if \code{out} is not
\code{NULL} (called for side effects).
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}

This draws the dependencies between variables. This function
is useful to detect dead code and variable clusters. By default the variable
is shown a new time when it's overwritten or modified, this can be changed by
setting \code{expand} to \code{FALSE}.
}
\details{
Colors and lines are to be understood as follows:
\itemize{
\item The function is blue
\item The arguments are green
\item The variables starting as constants are yellow
\item The dead code or pure side effect branches are orange and dashed
\item dashed lines represent how variables are undirectly impacted by control flow conditions,
for instance the expression \code{if(z == 1) x <- y} would give you a full arrow
from \code{y} to \code{x} and a dashed arrow from \code{z} to \code{x}
}

\code{expand = TRUE} gives a sense of the chronology, and keep separate the
unrelated uses of temp variables. \code{expand = FALSE} is more compact and shows
you directly what variables might impact a given variable, and what variables
it impacts.

This function will work best if the function doesn't draw from or assign to other
environments and doesn't use \code{assign()} or \code{attach()}. The output might
be polluted by variable names found in some lazily evaluated function arguments.
We ignore variable names found in calls to \code{quote()} and \code{~} as well as
nested function definitions, but complete robustness is probably impossible.

The diagram assumes that for / while / repeat loops were at least run once,
if a value is modified in a branch of an if call (or both branches) and
\code{expand} is \code{TRUE}, the modified variable(s) will point to a new one at the
end of the \code{ìf} call.
}
\examples{
flow_view_vars(ave)
}
