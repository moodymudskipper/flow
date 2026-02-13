test_that("flow_view_uses", {
  skip_on_ci()
  uses <- flow_view_uses(save_nomnoml, out = "data")
  uses_sorted <- uses[order(uses$fun),]
  expect_snapshot(uses_sorted)
})
