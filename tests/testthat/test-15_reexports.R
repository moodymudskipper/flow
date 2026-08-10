# Made with Cursor
test_that("reexports are resolved in flow_view", {
  code_tibble <- flow_view(tibble::lst, out = "code")
  code_dplyr  <- flow_view(dplyr::lst,  out = "code")
  expect_identical(code_dplyr, code_tibble)
})

test_that("reexports are resolved in flow_view_deps", {
  expect_snapshot({
    flow_view_deps(dplyr::lst, out = "data")
  })
})


