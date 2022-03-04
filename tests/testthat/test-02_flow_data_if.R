
#### IF ####

# simple if call without else and empty body
test_that("flow_data works with simple if and empty body",{
  fun <- function(x) {
    if(x) {}
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})

# simple if call without else and a symbol in body
test_that("flow_data works with simple if",{
  fun <- function(x) {
    if(x) foo
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})

# simple if else call
test_that("flow_data works with simple if else",{
  fun <- function(x) {
    if(x) foo else bar
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})

# if else call returning on the left
test_that("flow_data works returning on the yes branch",{
  fun <- function(x) {
    if(x) return(foo) else bar
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})

# if else call stopping on the right
test_that("flow_data works stopping on the no branch",{
  fun <- function(x) {
    if(x) foo else stop(bar)
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})
# if else call stopping on the left AND returning on the right
test_that("flow_data works stopping on the yes branch and returning on the right branch",{
  fun <- function(x) {
    if(x) stop(foo) else return(bar)
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})

# simple if call with a nested if else call
test_that("flow_data works with nested if calls",{
  fun <- function(x) {
    if(x) if(y) foo else bar
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)

  # note: this is currently wrong, setting test already to get coverage
  fun <- function(x,y) {
    if(x) if(y) stop() else stop()
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})
