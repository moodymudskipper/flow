
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
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  data <- flow_data(fun)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "standard", "return"),
      code_str = c("fun(x)", "", ""),
      label = c("", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1),
      to = c(1, 2),
      edge_label = c("", ""),
      arrow = c("->", "->"),
      stringsAsFactors = FALSE))
})


# function with one symbol

test_that("flow_data works with one symbol in body",{
  fun <- function(x) {x}
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  data <- flow_data(fun)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "standard", "return"),
      code_str = c("fun(x)", "x", ""),
      label = c("", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1),
      to = c(1, 2),
      edge_label = c("", ""),
      arrow = c("->", "->"),
      stringsAsFactors = FALSE))
})

# function with one call
test_that("flow_data works with one call in body",{
  fun <- function(x) {x + y}
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  data <- flow_data(fun)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "standard", "return"),
      code_str = c("fun(x)", "x + y", ""),
      label = c("", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1),
      to = c(1, 2),
      edge_label = c("", ""),
      arrow = c("->", "->"),
      stringsAsFactors = FALSE))
})

# function with 2 calls
test_that("flow_data works with 2 calls in body",{
  fun <- function(x) {
    x + y
    u + v
  }
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  data <- flow_data(fun)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "standard", "return"),
      code_str = c("fun(x)", "x + y\nu + v", ""),
      label = c("", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1),
      to = c(1, 2),
      edge_label = c("", ""),
      arrow = c("->", "->"),
      stringsAsFactors = FALSE))
})

#### OTHER INPUT TYPES ####

test_that("package works on calls",{
  call <- quote({
    x <- x*2
    y <- x
  })
  data <- flow_data(call)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(1, 2),
      block_type = c("standard", "return"),
      code_str = c("x <- x * 2\ny <- x", ""),
      label = c("", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = 1,
      to = 2,
      edge_label = "",
      arrow = "->",
      stringsAsFactors = FALSE))
})

test_that("package works on paths",{
  tmp <- tempfile(fileext=".R")
  write("x <- x*2\ny <- x", tmp)
  data <- flow_data(tmp)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(1, 2),
      block_type = c("standard", "return"),
      code_str = c("x <- x * 2\ny <- x", ""),
      label = c("", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = 1,
      to = 2,
      edge_label = "",
      arrow = "->",
      stringsAsFactors = FALSE))
})

