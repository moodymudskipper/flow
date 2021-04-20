# split code in blocks, divided by calls to control flow or special comments
# the output is a list of calls where each element has a "label" attribute and
# if relevant a block_type attribute

build_blocks <- function(expr){
  ## is expr an expression between {} ?
  if (is.call(expr) && expr[[1]] == quote(`{`)) {
    ## fetch its content into a list
    calls <- as.list(expr[-1])
    ## were the brackets empty ?
    if (!length(calls)) {
      ## return an empty call inside a list
      blocks <- list(substitute()) # substitute() returns an empty call
      return(blocks)
    }
  } else {
    ## put expr into a list
    calls <- list(expr)
  }

  ## split call into blocks
  # based on control flow and special coms

  # logical indices of control flow calls
  cfc_lgl <- calls %call_in% c("if", "for", "while", "repeat")

  # logical indices of comment calls `#`()
  special_comment_lgl <- calls %call_in% c("#")

  # there are 2 ways to start a block : be a cf not preceded by com, or be a com
  # there are 2 ways to finish a block : be a cf (and finish on next one), or start another block and finish right there

  # cf not preceded by com
  cfc_unpreceded_lgl <- cfc_lgl & !c(FALSE, head(special_comment_lgl, -1))
  # new_block (first or after cfc)
  new_block_lgl <- c(TRUE, head(cfc_lgl, -1))
  block_ids <- cumsum(special_comment_lgl | cfc_unpreceded_lgl | new_block_lgl)

  blocks <- split(calls, block_ids)

  ## for all blocks
  for (i in block_ids) {
    ## initiate a label attribute with value ""
    attr(blocks[[i]], "label") <- ""
  }

  ## for blocks headed by special comments (incl control flow)
  for (i in block_ids[special_comment_lgl]) {
    ## fetch label from `#`() call and remove call
    label <- blocks[[c(i,1,2)]]
    # remove comment from block
    blocks[[i]] <- blocks[[i]][-1]
    attr(blocks[[i]], "label") <- label
  }

  # subset control flows, which contain only one call
  ## for control flow blocks
  for (i in block_ids[cfc_lgl]) {
    ## make the new block of the unique element of the block
    # backup label before subsetting
    label <- attr(blocks[[i]], "label")
    blocks[[i]] <- blocks[[i]][[1]]
    attr(blocks[[i]], "label") <- label
    attr(blocks[[i]], "block_type") <- as.character(blocks[[c(i,1)]])
  }

  ## return blocks
  blocks
}
