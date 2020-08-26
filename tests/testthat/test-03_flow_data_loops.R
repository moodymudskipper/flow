#### FOR ####
# empty for loop
test_that("flow_data works with an empty  for loop",{
  fun <- function(x) {
    for(x in foo) {}
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "for", "standard", "start", "return"),
      code_str = c("fun(x)", "for (x in foo)", "", "", ""),
      label = c("", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, -1),
      to = c(1, 2, -1, -1, 3),
      edge_label = c("", "", "", "next", ""),
      arrow = c("->", "->", "->", "<-", "->"),
      stringsAsFactors = FALSE))
})

# simple for loop
test_that("flow_data works with simple for loop",{
  fun <- function(x) {
    for(x in foo) x
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "for", "standard", "start", "return"),
      code_str = c("fun(x)", "for (x in foo)", "x", "", ""),
      label = c("", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, -1),
      to = c(1, 2, -1, -1, 3),
      edge_label = c("", "", "", "next", ""),
      arrow = c("->", "->", "->", "<-", "->"),
      stringsAsFactors = FALSE))
})


# simple while loop
test_that("flow_data works with simple while loop",{
  fun <- function(x) {
    while(foo) x
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "while", "standard", "start", "return"),
      code_str = c("fun(x)", "while (foo)", "x", "", ""),
      label = c("", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, -1),
      to = c(1, 2, -1, -1, 3),
      edge_label = c("", "", "", "next", ""),
      arrow = c("->", "->", "->", "<-", "->"),
      stringsAsFactors = FALSE))
})

# simple repeat loop
test_that("flow_data works with simple for loop",{
  fun <- function(x) {
    repeat x
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "repeat", "standard", "start", "return"),
      code_str = c("fun(x)", "repeat", "x", "", ""),
      label = c("", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, -1),
      to = c(1, 2, -1, -1, 3),
      edge_label = c("", "", "", "next", ""),
      arrow = c("->", "->", "->", "<-", "->"),
      stringsAsFactors = FALSE))
})

# if else call with for loops on each side
test_that("flow_data works with simple for loop",{
  fun <- function(x) {
    if(foo)
      for(x in bar) baz
    else
      for(x in qux) quux
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, 3, -2, 4, 5, -4, -1, 6),
      block_type = c("header", "if", "for", "standard", "start", "for", "standard", "start",
                     "end", "return"),
      code_str = c("fun(x)", "if (foo)", "for (x in bar)", "baz", "", "for (x in qux)",
                   "quux", "", "", ""),
      label = c("", "", "", "", "", "", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 3, 2, -2, 1, 4, 5, 4, -4, -1),
      to = c(1, 2, 3, -2, -2, -1, 4, 5, -4, -4, -1, 6),
      edge_label = c("", "y", "", "", "next", "", "n", "", "", "next", "", ""),
      arrow = c("->", "->", "->", "->", "<-", "->", "->", "->", "->", "<-",
                "->", "->"),
      stringsAsFactors = FALSE))
})
