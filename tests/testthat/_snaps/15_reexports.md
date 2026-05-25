# reexports are resolved in flow_view_deps

    Code
      flow_view_deps(dplyr::lst, out = "data")
    Output
         child_header
      1       lst (2)
      2 lst_quos (14)
                                                               external_ref
      1                                                         rlang::quos
      2 rlang::eval_tidy, rlang::names2, rlang::rep_along, rlang::rep_named
        child_style parent_header parent_style
      1      expfun            NA           NA
      2    unexpfun       lst (2)       expfun
                                                                                                                     code
      1                                                                                    [<expfun> lst (2)|rlang::quos]
      2 [<expfun> lst (2)] -> [<unexpfun> lst_quos (14)|rlang::eval_tidy|rlang::names2|rlang::rep_along|rlang::rep_named]

