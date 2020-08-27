## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
rle(c(3, 3, 3, 1, 6 , 6))

## -----------------------------------------------------------------------------
rle

## ---- fig.width=8, fig.height=8, fig.align = "center"-------------------------
library(flow)
flow_view(rle)

## ---- eval = FALSE------------------------------------------------------------
#  flow_view(rle, out = "diagrams/rle.png")

## ---- eval = FALSE------------------------------------------------------------
#  flow_view(rle, out = "html")
#  #> The diagram was saved to '*******.html'
#  #> [1] "*******.html"

## ---- fig.width=8, fig.height=8, fig.align = "center"-------------------------
rle <- function (x) 
{
  # A rle object is a list containing elements length and value. It is
  # assigned a class "rle"
  
    ## is argument of wrong type ?
    if (!is.vector(x) && !is.list(x)) 
        stop("'x' must be a vector of an atomic type")
    n <- length(x)
    if (n == 0L) {
        ## return a rle object with zero length elements
        return(structure(list(lengths = integer(), values = x), 
            class = "rle"))
    }
    ## compute index of elements that are distinct from the next
    y <- x[-1L] != x[-n]
    i <- c(which(y | is.na(y)), n)
    ## compute the final object
    structure(list(lengths = diff(c(0L, i)), values = x[i]), 
        class = "rle")
}

flow_view(rle, prefix = "##")

## ---- eval = FALSE------------------------------------------------------------
#  c(
#    ## comment
#    1)

## ---- fig.width=8, fig.height=8, fig.align = "center"-------------------------
flow_view(rle, code = FALSE)

## ---- fig.width=8, fig.height=8, fig.align = "center"-------------------------
flow_view(rle, prefix = "##", code = FALSE)

## ---- fig.width=8, fig.height=8, fig.align = "center"-------------------------
flow_view(rle, prefix = "##", code = NA)

## ---- fig.width=8, fig.height=8, fig.align = "center"-------------------------
flow_view(rle, narrow = TRUE)

## ---- fig.width=8, fig.height=8, fig.align = "center"-------------------------
flow_view(bquote)

## ---- fig.width=8, fig.height=8, fig.align = "center"-------------------------
flow_view(bquote, sub_fun_id = "unquote")

## ---- fig.width=8, fig.height=8, fig.align = "center"-------------------------
flow_view(rle, range = 1:3)

## ---- fig.width=8, fig.height=8, fig.align = "center"-------------------------
flow_view(rle, ranker = "longest-path")

