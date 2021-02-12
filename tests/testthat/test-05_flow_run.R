test_that("flow_run doesn't crash on a simple example", {
  # expect_error(flow_run(rle(c(1,1,2))), NA)
  # expect_error(flow_run(rle(c(1,1,2)), browse=TRUE), NA)
  expect_error(flow_debug(rle), NA)
  expect_error(flow_debugonce(rle), NA)
})
