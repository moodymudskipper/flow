test_that("flow_view_deps works", {
  expect_snapshot({
    flow_view_deps(here::i_am, out = "data")
    flow_view_deps(list("here::i_am" = here::i_am), out = "data")
    flow_view_deps(here::i_am, max_depth = 3, out = "data")
    flow_view_deps(here::i_am, trim = "format_reason", out = "data")
    flow_view_deps(here::i_am, promote = "rprojroot::has_file", out = "data")
    flow_view_deps(here::i_am, demote = "format_reason", out = "data")
    flow_view_deps(here::i_am, hide = "format_dr_here", out = "data")
    flow_view_deps(here::i_am, show_imports = "packages", out = "data")
    flow_view_deps(here::i_am, show_imports = "none", out = "data")
    flow_view_deps(here::i_am, lines = FALSE, out = "data")
    flow_view_deps(here::i_am, promote= c(pattern = "rprojroot::.*") , out = "data")
    flow_view_deps(`%in%`, out = "data")
    flow_view_deps(`%in%`, out = "data")
    })
})


#

test_that("flow_view_deps include_formals works", {
  # use a function we own so the snapshot doesn't depend on other packages' code
  assign(
    "fun_with_formals",
    function(x, n = utils::head(x)) x,
    envir = globalenv()
  )
  on.exit(rm("fun_with_formals", envir = globalenv()))
  expect_snapshot({
    flow_view_deps(fun_with_formals, include_formals = FALSE, out = "data")
    flow_view_deps(fun_with_formals, include_formals = TRUE, out = "data")
  })
})
