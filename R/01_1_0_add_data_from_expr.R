# build the data from a quoted expression
# not directly recursive, but called by other add_data_from_* function
# for each block type

add_data_from_expr <-  function(data, expr, narrow = FALSE){
  blocks <- build_blocks(expr)
  for (block in blocks) {
    if (missing(block)) # deal with empty expr (`{}`)
      block_type <- NULL
    else
      block_type <- attr(block, "block_type")

    if (is.null(block_type)) {
      data <- add_data_from_standard_block(data, block)
    } else if (block_type == "if") {
      data <- add_data_from_if_block(data, block, narrow = narrow)
    } else if (block_type == "for") {
      data <- add_data_from_for_block(data, block, narrow = narrow)
    } else if (block_type == "while") {
      data <- add_data_from_while_block(data, block, narrow = narrow)
    } else if (block_type == "repeat") {
      data <- add_data_from_repeat_block(data, block, narrow = narrow)
    }
  }
  data
}
