# `methods::functionBody` is a re-export of `base::body` under another name
test_that("reexports are resolved in flow_view", {
  code_methods <- flow_view(methods::functionBody, out = "code")
  code_base <- flow_view(base::body, out = "code")
  expect_identical(code_methods, code_base)
})

test_that("reexports are resolved in flow_view_deps", {
  expect_identical(
    flow_view_deps(methods::functionBody, out = "data"),
    flow_view_deps(base::body, out = "data")
  )
})
