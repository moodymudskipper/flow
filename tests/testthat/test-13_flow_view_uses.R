test_that("flow_view_uses", {
  expect_snapshot(flow_view_uses(purrr:::accum_index, out = "data"))
})
