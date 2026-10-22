test_that("flow_view_package_deps works", {
  # a toy package database so the test runs offline and is stable
  db <- cbind(
    Package = c("pkgA", "pkgB", "pkgC", "pkgD"),
    Depends = c("R (>= 4.0)", NA, NA, NA),
    Imports = c("pkgB, pkgD, utils", "pkgC", NA, "stats"),
    LinkingTo = NA
  )
  expect_snapshot({
    flow_view_package_deps("pkgA", db = db, out = "data")
    flow_view_package_deps(c("pkgA", "pkgB"), db = db, out = "data")
    flow_view_package_deps("pkgA", db = db, base = TRUE, out = "data")
    flow_view_package_deps("pkgA", db = db, demote_nodep = TRUE, out = "data")
  })
  expect_s3_class(flow_view_package_deps("pkgA", db = db), "flow_diagram")
})
