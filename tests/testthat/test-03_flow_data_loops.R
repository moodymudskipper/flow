#### FOR ####
# empty for loop
test_that("flow_data works with an empty for loop",{
  fun <- function(x) {
    for(x in foo) {}
  }
  expect_snapshot(flow_data(fun))
})

# simple for loop
test_that("flow_data works with simple for loop",{
  fun <- function(x) {
    for(x in foo) x
  }
  expect_snapshot(flow_data(fun))
})


# simple while loop
test_that("flow_data works with simple while loop",{
  fun <- function(x) {
    while(foo) x
  }
  expect_snapshot(flow_data(fun))
})

# simple repeat loop
test_that("flow_data works with simple repeat loop",{
  fun <- function(x) {
    repeat x
  }
  expect_snapshot(flow_data(fun))
})

# if else call with for loops on each side
test_that("flow_data works if else call with for loops on each side",{
  fun <- function(x) {
    if(foo)
      for(x in bar) baz
    else
      for(x in qux) quux
  }
  expect_snapshot(flow_data(fun))
})
