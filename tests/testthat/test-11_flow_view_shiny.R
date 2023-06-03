test_that("flow_view_shiny", {
  expect_snapshot({
    flow_view_shiny(esquisse::esquisser, out = "data")
  })
})
