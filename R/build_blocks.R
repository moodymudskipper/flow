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
  # get logical indices of special calls
  cfc_lgl <- calls %call_in% c("if", "for", "while", "repeat")

  special_comment_lgl <- calls %call_in% c("#")
  # compute block indices
  block_ids <- interaction(
    cumsum(cfc_lgl) * cfc_lgl,
    cumsum(special_comment_lgl) * ! cfc_lgl)
  block_ids <- rleid(as.numeric(block_ids))
  # build blocks
  blocks <- split(calls, block_ids) # tapply(b, block_ids, deparse2)
  for (i in block_ids[cfc_lgl]) {
    attr(blocks[[i]], "block_type") <- as.character(blocks[[c(i,1,1)]])
  }

  for (i in block_ids[special_comment_lgl]) {
    label <- blocks[[c(i,1,2)]]
    blocks[[i]] <- blocks[[i]][-1]
    attr(blocks[[i]], "block_type") <- "commented"
    attr(blocks[[i]], "label") <- label

  }
  blocks
}
