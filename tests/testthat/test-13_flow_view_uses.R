test_that("flow_view_uses", {
  skip_on_ci()
  expect_snapshot(flow_view_uses(save_nomnoml, out = "data"))
})
