
#### IF ####

# simple if call without else and empty body
test_that("flow_data works with simple if and empty body",{
  fun <- function(x) {
    if(x) {}
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "if", "standard", "end", "return"),
      code_str = c("fun(x)", "if (x)", "", "", ""),
      label = c("", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, -1),
      to = c(1, 2, -1, -1, 3),
      edge_label = c("", "y", "", "n", ""),
      arrow = c("->", "->", "->", "->", "->"),
      stringsAsFactors = FALSE))
})

# simple if call without else and a symbol in body
test_that("flow_data works with simple if",{
  fun <- function(x) {
    if(x) foo
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "if", "standard", "end", "return"),
      code_str = c("fun(x)", "if (x)", "foo", "", ""),
      label = c("", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, -1),
      to = c(1, 2, -1, -1, 3),
      edge_label = c("", "y", "", "n", ""),
      arrow = c("->", "->", "->", "->", "->"),
      stringsAsFactors = FALSE))
})

# simple if else call
test_that("flow_data works with simple if else",{
  fun <- function(x) {
    if(x) foo else bar
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, 3, -1, 4),
      block_type = c("header", "if", "standard", "standard", "end", "return"),
      code_str = c("fun(x)", "if (x)", "foo", "bar", "", ""),
      label = c("", "", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, 3, -1),
      to = c(1, 2, -1, 3, -1, 4),
      edge_label = c("", "y", "", "n", "", ""),
      arrow = c("->", "->", "->", "->", "->", "->"),
      stringsAsFactors = FALSE))
})
# simple if else call without else and a symbol in body
# simple if else call without else and a call in body
# simple if else call without else and 2 calls in body

# if else call returning on the left
test_that("flow_data works returning on the yes branch",{
  fun <- function(x) {
    if(x) return(foo) else bar
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -2, 3, -1, 4),
      block_type = c("header", "if", "standard", "return", "standard", "end", "return"),
      code_str = c("fun(x)", "if (x)", "return(foo)", "", "bar", "", ""),
      label = c("", "", "", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, 3, -1),
      to = c(1, 2, -2, 3, -1, 4),
      edge_label = c("", "y", "", "n", "", ""),
      arrow = c("->", "->", "->", "->", "->", "->"),
      stringsAsFactors = FALSE))
})


# if else call stopping on the right
test_that("flow_data works stopping on the no branch",{
  fun <- function(x) {
    if(x) foo else stop(bar)
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, 3, -3, -1, 4),
      block_type = c("header", "if", "standard", "standard", "stop", "end", "return"),
      code_str = c("fun(x)", "if (x)", "foo", "stop(bar)", "", "", ""),
      label = c("", "", "", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, 3, -1),
      to = c(1, 2, -1, 3, -3, 4),
      edge_label = c("", "y", "", "n", "", ""),
      arrow = c("->", "->", "->", "->", "->", "->"),
      stringsAsFactors = FALSE))
})
# if else call stopping on the left AND returning on the right
test_that("flow_data works stopping on the yes branch and returning on the right branch",{
  fun <- function(x) {
    if(x) stop(foo) else return(bar)
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -2, 3, -3, 4),
      block_type = c("header", "if", "standard", "stop", "standard", "return", "return"),
      code_str = c("fun(x)", "if (x)", "stop(foo)", "", "return(bar)", "", ""),
      label = c("", "", "", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, 3),
      to = c(1, 2, -2, 3, -3),
      edge_label = c("", "y", "", "n", ""),
      arrow = c("->", "->", "->", "->", "->"),
      stringsAsFactors = FALSE))
})

# simple if call with a nested if else call
test_that("flow_data works with nested if calls",{
  fun <- function(x) {
    if(x) if(y) foo else bar
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, 3, 4, -2, -1, 5),
      block_type = c("header", "if", "if", "standard", "standard", "end", "end", "return"
      ),
      code_str = c("fun(x)", "if (x)", "if (y)", "foo", "bar", "", "", ""),
      label = c("", "", "", "", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 3, 2, 4, -2, 1, -1),
      to = c(1, 2, 3, -2, 4, -2, -1, -1, 5),
      edge_label = c("", "y", "y", "", "n", "", "", "n", ""),
      arrow = c("->", "->", "->", "->", "->", "->", "->", "->", "->"),
      stringsAsFactors = FALSE))
})
