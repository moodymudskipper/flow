test_that("flow_compare_runs", {
  expect_snapshot({
    flow_compare_runs(rle(NULL), rle(c(1, 2, 2, 3)), out = "data")
  })
})
