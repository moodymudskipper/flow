test_that("flow_view_vars", {
  expect_snapshot({
    flow_view_vars(ave, out = "code")
    flow_view_vars(ave, out = "data")
  })
})
