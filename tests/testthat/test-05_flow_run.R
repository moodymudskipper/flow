test_that("flow_run doesn't crash on a simple example", {
  # expect_error(flow_run(rle(c(1,1,2))), NA)
  # expect_error(flow_run(rle(c(1,1,2)), browse=TRUE), NA)
  expect_error(flow_debug(ave), NA)
  untrace(ave)
})

test_that("flow_view works", {
  # expect_error(flow_run(rle(c(1,1,2)), browse=TRUE), NA)
  fun <- function(x) {
    if(x) foo else bar
  }
  expect_error(flow_view(fun), NA)
  #expect_error(flow_view(fun, engine = "plantuml"), NA)
})
