test_that("flow_run", {
  skip_on_ci()
  # use a function we own so the snapshot doesn't depend on the R version
  assign(
    "fun_to_run",
    function(x, ...) {
      if (missing(...)) {
        x[] <- mean(x)
      } else {
        g <- interaction(...)
        split(x, g) <- lapply(split(x, g), mean)
      }
      x
    },
    envir = globalenv()
  )
  on.exit(rm("fun_to_run", envir = globalenv()))
  expect_snapshot(
    flow_run(fun_to_run(1:10), out = "data")
  )
})
