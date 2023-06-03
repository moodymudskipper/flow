test_that("flow_view_source_calls", {
  tmp <- tempdir()
  writeLines("source('B.R')\nsource('C.R')", file.path(tmp, "A.R"))
  writeLines("source('D.R')", file.path(tmp, "B.R"))
  writeLines("print('hello')", file.path(tmp, "C.R"))
  writeLines("print('hello')", file.path(tmp, "D.R"))
  expect_snapshot({
    flow_view_source_calls(tmp, out = "data")
  })
  file.remove(
    file.path(tmp, "A.R"),
    file.path(tmp, "B.R"),
    file.path(tmp, "C.R"),
    file.path(tmp, "D.R")
  )
})
