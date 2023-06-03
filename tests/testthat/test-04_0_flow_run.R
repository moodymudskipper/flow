test_that("flow_run", {
  expect_snapshot(
    flow_run(ave(1:10), out = "data")
  )
})
