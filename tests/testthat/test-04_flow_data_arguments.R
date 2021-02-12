
test_that("sub_fun_id works",{
  fun <- function(x) {
    x <- x*2
    fun1 <- function(y) y
    fun2 <- function(z) z
    x
  }
  expect_snapshot(flow_data(fun, sub_fun_id = 2))
})



test_that("flow_data works with prefixed comments",{
  fun <- function(x) {
    ## comment
    x}
  expect_snapshot(flow_data(fun, prefix = "##"))
})
