test_that("flow_view_uses", {
  expect_snapshot(flow_view_uses(save_nomnoml, out = "data"))
})
