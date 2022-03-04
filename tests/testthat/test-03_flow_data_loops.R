#### FOR ####
# empty for loop
test_that("flow_data works with an empty for loop",{
  fun <- function(x) {
    for(x in foo) {}
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})

# simple for loop
test_that("flow_data works with simple for loop",{
  fun <- function(x) {
    for(x in foo) x
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})


# simple while loop
test_that("flow_data works with simple while loop",{
  fun <- function(x) {
    while(foo) x
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})

# simple repeat loop
test_that("flow_data works with simple repeat loop",{
  fun <- function(x) {
    repeat x
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})

# if else call with for loops on each side
test_that("flow_data works if else call with for loops on each side",{
  fun <- function(x) {
    if(foo)
      for(x in bar) baz
    else
      for(x in qux) quux
  }
  out <- flow_data(fun)
  out$nodes$code_str <- gsub("\u2800", " ", out$nodes$code_str)
  expect_snapshot(out)
})
