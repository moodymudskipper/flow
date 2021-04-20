

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
  expect_snapshot(flow_data(fun, nested_fun = 2))
})

test_that("flow_data works with prefixed comments",{
  fun <- function(x) {
    ## comment
    x}
  expect_snapshot(flow_data(fun, prefix = "##"))
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
  expect_snapshot(flow_data(fun))

  # note: this is currently wrong, setting test already to get coverage
  fun <- function(x,y) {
    if(x) stop() else bar
  }
  expect_snapshot(flow_data(fun))

  fun <- function(x,y) {
    if(x) foo else stop()
  }
  expect_snapshot(flow_data(fun))
})
