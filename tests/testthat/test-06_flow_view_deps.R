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
    flow_view_deps(lifecycle::signal_experimental, max_depth = 1, include_formals = FALSE, out = "data")
    flow_view_deps(lifecycle::signal_experimental, max_depth = 1, include_formals = TRUE, out = "data")
    flow_view_deps(`%in%`, out = "data")
    flow_view_deps(`%in%`, out = "data")
    })
})


#
