test_that("flow_run", {
  skip_on_ci()
  expect_snapshot(
    flow_run(ave(1:10), out = "data")
  )
})
