build_blocks <- function(expr){
  # clean block from braces
  if(is.call(expr) && expr[[1]] == quote(`{`))
    calls <- as.list(expr[-1])
  else
    calls <- list(expr)

  # support empty calls (`{}`)
  if(!length(calls)){
    blocks <- list(substitute())
    return(blocks)
  }
  # logical indices of control flow calls
  cfc_lgl <- calls %call_in% c("if", "for", "while", "repeat")

  # logical indices of control flow calls
  special_comment_lgl <- calls %call_in% c("#")

  # there are 2 ways to start a block : be a cf not preceded by com, or be a com
  # there are 2 ways to finish a block : be a cf (and finish on next one), or start another block and finish right there
  special_comment_lgl
  # cf not preceded by com
  cfc_unpreceded_lgl <- cfc_lgl & ! c(FALSE, head(special_comment_lgl, -1))
  # new_block (first or after cfc)
  new_block_lgl <- c(TRUE, head(cfc_lgl, -1))
  block_ids <- cumsum(special_comment_lgl | cfc_unpreceded_lgl | new_block_lgl)

  # compute block indices
  # block_ids <- interaction(
  #   cumsum(cfc_lgl) * cfc_lgl,
  #   cumsum(special_comment_lgl) * ! cfc_lgl)
  # block_ids <- rleid(as.numeric(block_ids))
  # build blocks
  blocks <- split(calls, block_ids) # tapply(b, block_ids, deparse2)

  # add empty label to all blocks
  for (i in block_ids) {
    attr(blocks[[i]], "label") <- ""
  }

  # make the comment  label when relevant
  for (i in block_ids[special_comment_lgl]) {
    label <- blocks[[c(i,1,2)]]
    # remove comment from block
    blocks[[i]] <- blocks[[i]][-1]
    #attr(blocks[[i]], "block_type") <- "commented"
    #attr(blocks[[i]], "commented") <- TRUE
    attr(blocks[[i]], "label") <- label
  }

  # subset control flows, which contain only one call
  for (i in block_ids[cfc_lgl]) {
    # backup label before subsetting
    label <- attr(blocks[[i]], "label")
    blocks[[i]] <- blocks[[i]][[1]]
    attr(blocks[[i]], "label") <- label
    attr(blocks[[i]], "block_type") <- as.character(blocks[[c(i,1)]])
  }


  blocks
}
