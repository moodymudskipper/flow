
#### WRONG INPUTS ####

test_that("flow_data fails explicitly on primitives", {
  expect_error(flow_data(max), "doesn't have a body")
})

test_that("flow_data fails if incorrect input", {
  expect_error(flow_data(1), "must be a function")
})

#### SIMPLE CASES ####

## empty function

test_that("flow_data works with empty fun",{
  fun <- function(x) {}
  data <- flow_data(fun)
  expect_snapshot(flow_data(fun))
})


# function with one symbol

test_that("flow_data works with one symbol in body",{
  fun <- function(x) {x}
  expect_snapshot(flow_data(fun))
})

# function with one call
test_that("flow_data works with one call in body",{
  fun <- function(x) {x + y}
  expect_snapshot(flow_data(fun))
})

# function with 2 calls
test_that("flow_data works with 2 calls in body",{
  fun <- function(x) {
    x + y
    u + v
  }
  expect_snapshot(flow_data(fun))
})

# comment so rhub doesn't fail
# test_that("flow_data works with a traced function",{
#
#   fun1 <- fun2 <- function(x) {x}
#   flow_debugonce(fun1)
#   expect_identical(flow_data(list(fun= fun1)), flow_data(list(fun = fun2)))
#   flow_undebug(fun1)
# })

#### OTHER INPUT TYPES ####

test_that("flow_data works on calls",{
  call <- quote({
    x <- x*2
    y <- x
  })
  expect_snapshot(flow_data(call))
})

test_that("flow_data works on paths",{
  tmp <- tempfile(fileext=".R")
  write("x <- x*2\ny <- x", tmp)

  expect_snapshot(flow_data(tmp))
})

test_that("flow_data works on lists",{
  fun <- function(x) {x}
  expect_snapshot(flow_data(list(f = fun)))
})

