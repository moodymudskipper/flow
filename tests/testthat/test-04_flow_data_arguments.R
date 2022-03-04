

test_that("nested functions are recognized",{
  fun <- function(x) {
    x <- x*2
    fun1 <- function(y) y
    fun2 <- function(z) z
    x
  }
  expect_message(flow_view(fun), "^We found")
})

test_that("nested_fun works",{
  fun <- function(x) {
    x <- x*2
    fun1 <- function(y) y
    fun2 <- function(z) z
    x
  }
  out <- flow_data(fun, nested_fun = 2)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})

test_that("flow_data works with prefixed comments",{
  fun <- function(x) {
    ## comment
    x}
  out <- flow_data(fun, prefix = "##")
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})

test_that("the `code` argument of flow_view works",{
  fun <- function(x) {
    ## comment
    x}
  expect_error(flow_view(fun, code = NA), NA)
  expect_error(flow_view(fun, code = FALSE), NA)
})


test_that("flow_data works with narrow argument",{
  fun <- function(x) {
    if(x) foo else bar
  }
  out <- flow_data(fun, prefix = "##")
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)

  # note: this is currently wrong, setting test already to get coverage
  fun <- function(x,y) {
    if(x) stop() else bar
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)

  fun <- function(x,y) {
    if(x) foo else stop()
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})
