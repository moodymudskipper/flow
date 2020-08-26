
test_that("sub_fun_id works",{
  fun <- function(x) {
    x <- x*2
    fun1 <- function(y) y
    fun2 <- function(z) z
    x
  }
  expect_message(flow_data(fun))
  data <- flow_data(fun, sub_fun_id = 2)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "standard", "return"),
      code_str = c("fun(z)", "z", ""),
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



test_that("flow_data works with prefixed comments",{
  fun <- function(x) {
    ## comment
    x}
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  data <- flow_data(fun, prefix = "##")
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "standard", "return"),
      code_str = c("fun(x)", "x", ""),
      label = c("", "comment", ""),
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



test_that("package works with range arg",{
  fun <- function(x){
    ## section 1
    x <- x*2
    ## section 2
    x <- x*2
    ## section 3
    x <- x*2
    ## section 4
    x <- x*2
  }
  data <- flow_data(fun, prefix = "##", range = 1:3)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equivalent(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, 3, 5),
      block_type = c("header", "standard", "standard", "standard", "header"),
      code_str = c("fun(x)", "x <- x * 2", "x <- x * 2", "x <- x * 2", "..."),
      label = c("", "section 1", "section 2", "section 3", ""),
      stringsAsFactors = FALSE))
  expect_equivalent(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 3),
      to = c(1, 2, 3, 5),
      edge_label = c("", "", "", ""),
      arrow = c("->", "->", "->", "--:>"),
      stringsAsFactors = FALSE))

  data <- flow_data(fun, prefix = "##", range = 2:3)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equivalent(
    data$nodes[1:4],
    data.frame(
      id = c(0, 2, 3, 5),
      block_type = c("header", "standard", "standard", "header"),
      code_str = c(". . .", "x <- x * 2", "x <- x * 2", "..."),
      label = c("", "section 2", "section 3", ""),
      stringsAsFactors = FALSE))
  expect_equivalent(
    data$edges,
    data.frame(
      from = c(0, 2, 3),
      to = c(2, 3, 5),
      edge_label = c("", "", ""),
      arrow = c("--:>", "->", "--:>"),
      stringsAsFactors = FALSE))
