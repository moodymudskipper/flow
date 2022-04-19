# flow_view_deps works

    Code
      flow_view_deps(here::i_am, out = "data")
    Output
                          child_header             external_ref child_style
      1                      i_am (14)      rprojroot::has_file      expfun
      2                    dr_here (1)                     NULL      expfun
      3             format_dr_here (5)                     NULL    unexpfun
      4              format_reason (9) rprojroot::get_root_desc    unexpfun
      5 format_root_criteria_items (3)                     NULL    unexpfun
      6                       here (1)                     NULL      expfun
      7             mockable_getwd (6)                     NULL    unexpfun
      8                set_fix_fun (5)                     NULL    unexpfun
      9              set_root_crit (1)                     NULL    unexpfun
             parent_header parent_style
      1                 NA           NA
      2          i_am (14)       expfun
      3        dr_here (1)       expfun
      4 format_dr_here (5)     unexpfun
      5  format_reason (9)     unexpfun
      6 format_dr_here (5)     unexpfun
      7          i_am (14)       expfun
      8          i_am (14)       expfun
      9          i_am (14)       expfun
                                                                                              code
      1                                                   [<expfun> i_am (14)|rprojroot::has_file]
      2                                             [<expfun> i_am (14)] -> [<expfun> dr_here (1)]
      3                                  [<expfun> dr_here (1)] -> [<unexpfun> format_dr_here (5)]
      4 [<unexpfun> format_dr_here (5)] -> [<unexpfun> format_reason (9)|rprojroot::get_root_desc]
      5              [<unexpfun> format_reason (9)] -> [<unexpfun> format_root_criteria_items (3)]
      6                                     [<unexpfun> format_dr_here (5)] -> [<expfun> here (1)]
      7                                    [<expfun> i_am (14)] -> [<unexpfun> mockable_getwd (6)]
      8                                       [<expfun> i_am (14)] -> [<unexpfun> set_fix_fun (5)]
      9                                     [<expfun> i_am (14)] -> [<unexpfun> set_root_crit (1)]
    Code
      flow_view_deps(here::i_am, max_depth = 3, out = "data")
    Output
              child_header        external_ref child_style parent_header parent_style
      1          i_am (14) rprojroot::has_file      expfun            NA           NA
      2        dr_here (1)                NULL      expfun     i_am (14)       expfun
      3 format_dr_here (5)                NULL     trimmed   dr_here (1)       expfun
      4 mockable_getwd (6)                NULL    unexpfun     i_am (14)       expfun
      5    set_fix_fun (5)                NULL    unexpfun     i_am (14)       expfun
      6  set_root_crit (1)                NULL    unexpfun     i_am (14)       expfun
                                                            code
      1                 [<expfun> i_am (14)|rprojroot::has_file]
      2           [<expfun> i_am (14)] -> [<expfun> dr_here (1)]
      3 [<expfun> dr_here (1)] -> [<trimmed> format_dr_here (5)]
      4  [<expfun> i_am (14)] -> [<unexpfun> mockable_getwd (6)]
      5     [<expfun> i_am (14)] -> [<unexpfun> set_fix_fun (5)]
      6   [<expfun> i_am (14)] -> [<unexpfun> set_root_crit (1)]
    Code
      flow_view_deps(here::i_am, trim = "format_reason", out = "data")
    Output
              child_header             external_ref child_style      parent_header
      1          i_am (14)      rprojroot::has_file      expfun                 NA
      2        dr_here (1)                     NULL      expfun          i_am (14)
      3 format_dr_here (5)                     NULL    unexpfun        dr_here (1)
      4  format_reason (9) rprojroot::get_root_desc     trimmed format_dr_here (5)
      5           here (1)                     NULL      expfun format_dr_here (5)
      6 mockable_getwd (6)                     NULL    unexpfun          i_am (14)
      7    set_fix_fun (5)                     NULL    unexpfun          i_am (14)
      8  set_root_crit (1)                     NULL    unexpfun          i_am (14)
        parent_style
      1           NA
      2       expfun
      3       expfun
      4     unexpfun
      5     unexpfun
      6       expfun
      7       expfun
      8       expfun
                                                                                             code
      1                                                  [<expfun> i_am (14)|rprojroot::has_file]
      2                                            [<expfun> i_am (14)] -> [<expfun> dr_here (1)]
      3                                 [<expfun> dr_here (1)] -> [<unexpfun> format_dr_here (5)]
      4 [<unexpfun> format_dr_here (5)] -> [<trimmed> format_reason (9)|rprojroot::get_root_desc]
      5                                    [<unexpfun> format_dr_here (5)] -> [<expfun> here (1)]
      6                                   [<expfun> i_am (14)] -> [<unexpfun> mockable_getwd (6)]
      7                                      [<expfun> i_am (14)] -> [<unexpfun> set_fix_fun (5)]
      8                                    [<expfun> i_am (14)] -> [<unexpfun> set_root_crit (1)]
    Code
      flow_view_deps(here::i_am, promote = "rprojroot::has_file", out = "data")
    Output
                           child_header
      1                       i_am (14)
      2                     dr_here (1)
      3              format_dr_here (5)
      4               format_reason (9)
      5  format_root_criteria_items (3)
      6                        here (1)
      7              mockable_getwd (6)
      8                 set_fix_fun (5)
      9               set_root_crit (1)
      10       rprojroot::has_file (26)
                                                                                                                          external_ref
      1                                                                                                                           NULL
      2                                                                                                                           NULL
      3                                                                                                                           NULL
      4                                                                                                       rprojroot::get_root_desc
      5                                                                                                                           NULL
      6                                                                                                                           NULL
      7                                                                                                                           NULL
      8                                                                                                                           NULL
      9                                                                                                                           NULL
      10 rprojroot:::check_relative, rprojroot:::format_lines, rprojroot:::match_contents, rprojroot:::path, rprojroot::root_criterion
         child_style      parent_header parent_style
      1       expfun                 NA           NA
      2       expfun          i_am (14)       expfun
      3     unexpfun        dr_here (1)       expfun
      4     unexpfun format_dr_here (5)     unexpfun
      5     unexpfun  format_reason (9)     unexpfun
      6       expfun format_dr_here (5)     unexpfun
      7     unexpfun          i_am (14)       expfun
      8     unexpfun          i_am (14)       expfun
      9     unexpfun          i_am (14)       expfun
      10      expfun          i_am (14)       expfun
                                                                                                                                                                                          code
      1                                                                                                                                                                   [<expfun> i_am (14)]
      2                                                                                                                                         [<expfun> i_am (14)] -> [<expfun> dr_here (1)]
      3                                                                                                                              [<expfun> dr_here (1)] -> [<unexpfun> format_dr_here (5)]
      4                                                                                             [<unexpfun> format_dr_here (5)] -> [<unexpfun> format_reason (9)|rprojroot::get_root_desc]
      5                                                                                                          [<unexpfun> format_reason (9)] -> [<unexpfun> format_root_criteria_items (3)]
      6                                                                                                                                 [<unexpfun> format_dr_here (5)] -> [<expfun> here (1)]
      7                                                                                                                                [<expfun> i_am (14)] -> [<unexpfun> mockable_getwd (6)]
      8                                                                                                                                   [<expfun> i_am (14)] -> [<unexpfun> set_fix_fun (5)]
      9                                                                                                                                 [<expfun> i_am (14)] -> [<unexpfun> set_root_crit (1)]
      10 [<expfun> i_am (14)] -> [<expfun> rprojroot::has_file (26)|rprojroot:::check_relative|rprojroot:::format_lines|rprojroot:::match_contents|rprojroot:::path|rprojroot::root_criterion]
    Code
      flow_view_deps(here::i_am, demote = "format_reason", out = "data")
    Output
              child_header         external_ref child_style      parent_header
      1          i_am (14)  rprojroot::has_file      expfun                 NA
      2        dr_here (1)                 NULL      expfun          i_am (14)
      3 format_dr_here (5) here:::format_reason    unexpfun        dr_here (1)
      4           here (1)                 NULL      expfun format_dr_here (5)
      5 mockable_getwd (6)                 NULL    unexpfun          i_am (14)
      6    set_fix_fun (5)                 NULL    unexpfun          i_am (14)
      7  set_root_crit (1)                 NULL    unexpfun          i_am (14)
        parent_style
      1           NA
      2       expfun
      3       expfun
      4     unexpfun
      5       expfun
      6       expfun
      7       expfun
                                                                                  code
      1                                       [<expfun> i_am (14)|rprojroot::has_file]
      2                                 [<expfun> i_am (14)] -> [<expfun> dr_here (1)]
      3 [<expfun> dr_here (1)] -> [<unexpfun> format_dr_here (5)|here:::format_reason]
      4                         [<unexpfun> format_dr_here (5)] -> [<expfun> here (1)]
      5                        [<expfun> i_am (14)] -> [<unexpfun> mockable_getwd (6)]
      6                           [<expfun> i_am (14)] -> [<unexpfun> set_fix_fun (5)]
      7                         [<expfun> i_am (14)] -> [<unexpfun> set_root_crit (1)]
    Code
      flow_view_deps(here::i_am, hide = "format_dr_here", out = "data")
    Output
              child_header        external_ref child_style parent_header parent_style
      1          i_am (14) rprojroot::has_file      expfun            NA           NA
      2        dr_here (1)                NULL      expfun     i_am (14)       expfun
      3 mockable_getwd (6)                NULL    unexpfun     i_am (14)       expfun
      4    set_fix_fun (5)                NULL    unexpfun     i_am (14)       expfun
      5  set_root_crit (1)                NULL    unexpfun     i_am (14)       expfun
                                                           code
      1                [<expfun> i_am (14)|rprojroot::has_file]
      2          [<expfun> i_am (14)] -> [<expfun> dr_here (1)]
      3 [<expfun> i_am (14)] -> [<unexpfun> mockable_getwd (6)]
      4    [<expfun> i_am (14)] -> [<unexpfun> set_fix_fun (5)]
      5  [<expfun> i_am (14)] -> [<unexpfun> set_root_crit (1)]
    Code
      flow_view_deps(here::i_am, show_imports = "packages", out = "data")
    Output
                          child_header external_ref child_style      parent_header
      1                      i_am (14)  {rprojroot}      expfun                 NA
      2                    dr_here (1)         NULL      expfun          i_am (14)
      3             format_dr_here (5)         NULL    unexpfun        dr_here (1)
      4              format_reason (9)  {rprojroot}    unexpfun format_dr_here (5)
      5 format_root_criteria_items (3)         NULL    unexpfun  format_reason (9)
      6                       here (1)         NULL      expfun format_dr_here (5)
      7             mockable_getwd (6)         NULL    unexpfun          i_am (14)
      8                set_fix_fun (5)         NULL    unexpfun          i_am (14)
      9              set_root_crit (1)         NULL    unexpfun          i_am (14)
        parent_style
      1           NA
      2       expfun
      3       expfun
      4     unexpfun
      5     unexpfun
      6     unexpfun
      7       expfun
      8       expfun
      9       expfun
                                                                                 code
      1                                              [<expfun> i_am (14)|{rprojroot}]
      2                                [<expfun> i_am (14)] -> [<expfun> dr_here (1)]
      3                     [<expfun> dr_here (1)] -> [<unexpfun> format_dr_here (5)]
      4 [<unexpfun> format_dr_here (5)] -> [<unexpfun> format_reason (9)|{rprojroot}]
      5 [<unexpfun> format_reason (9)] -> [<unexpfun> format_root_criteria_items (3)]
      6                        [<unexpfun> format_dr_here (5)] -> [<expfun> here (1)]
      7                       [<expfun> i_am (14)] -> [<unexpfun> mockable_getwd (6)]
      8                          [<expfun> i_am (14)] -> [<unexpfun> set_fix_fun (5)]
      9                        [<expfun> i_am (14)] -> [<unexpfun> set_root_crit (1)]
    Code
      flow_view_deps(here::i_am, show_imports = "none", out = "data")
    Output
                          child_header external_ref child_style      parent_header
      1                      i_am (14)         NULL      expfun                 NA
      2                    dr_here (1)         NULL      expfun          i_am (14)
      3             format_dr_here (5)         NULL    unexpfun        dr_here (1)
      4              format_reason (9)         NULL    unexpfun format_dr_here (5)
      5 format_root_criteria_items (3)         NULL    unexpfun  format_reason (9)
      6                       here (1)         NULL      expfun format_dr_here (5)
      7             mockable_getwd (6)         NULL    unexpfun          i_am (14)
      8                set_fix_fun (5)         NULL    unexpfun          i_am (14)
      9              set_root_crit (1)         NULL    unexpfun          i_am (14)
        parent_style
      1           NA
      2       expfun
      3       expfun
      4     unexpfun
      5     unexpfun
      6     unexpfun
      7       expfun
      8       expfun
      9       expfun
                                                                                 code
      1                                                          [<expfun> i_am (14)]
      2                                [<expfun> i_am (14)] -> [<expfun> dr_here (1)]
      3                     [<expfun> dr_here (1)] -> [<unexpfun> format_dr_here (5)]
      4             [<unexpfun> format_dr_here (5)] -> [<unexpfun> format_reason (9)]
      5 [<unexpfun> format_reason (9)] -> [<unexpfun> format_root_criteria_items (3)]
      6                        [<unexpfun> format_dr_here (5)] -> [<expfun> here (1)]
      7                       [<expfun> i_am (14)] -> [<unexpfun> mockable_getwd (6)]
      8                          [<expfun> i_am (14)] -> [<unexpfun> set_fix_fun (5)]
      9                        [<expfun> i_am (14)] -> [<unexpfun> set_root_crit (1)]
    Code
      flow_view_deps(here::i_am, lines = FALSE, out = "data")
    Output
                      child_header             external_ref child_style
      1                       i_am      rprojroot::has_file      expfun
      2                    dr_here                     NULL      expfun
      3             format_dr_here                     NULL    unexpfun
      4              format_reason rprojroot::get_root_desc    unexpfun
      5 format_root_criteria_items                     NULL    unexpfun
      6                       here                     NULL      expfun
      7             mockable_getwd                     NULL    unexpfun
      8                set_fix_fun                     NULL    unexpfun
      9              set_root_crit                     NULL    unexpfun
         parent_header parent_style
      1             NA           NA
      2           i_am       expfun
      3        dr_here       expfun
      4 format_dr_here     unexpfun
      5  format_reason     unexpfun
      6 format_dr_here     unexpfun
      7           i_am       expfun
      8           i_am       expfun
      9           i_am       expfun
                                                                                      code
      1                                                [<expfun> i_am|rprojroot::has_file]
      2                                              [<expfun> i_am] -> [<expfun> dr_here]
      3                                  [<expfun> dr_here] -> [<unexpfun> format_dr_here]
      4 [<unexpfun> format_dr_here] -> [<unexpfun> format_reason|rprojroot::get_root_desc]
      5              [<unexpfun> format_reason] -> [<unexpfun> format_root_criteria_items]
      6                                     [<unexpfun> format_dr_here] -> [<expfun> here]
      7                                     [<expfun> i_am] -> [<unexpfun> mockable_getwd]
      8                                        [<expfun> i_am] -> [<unexpfun> set_fix_fun]
      9                                      [<expfun> i_am] -> [<unexpfun> set_root_crit]
    Code
      flow_view_deps(lifecycle::signal_experimental, max_depth = 1, include_formals = FALSE,
      out = "data")
    Output
                   child_header external_ref child_style parent_header parent_style
      1 signal_experimental (1)         NULL     trimmed            NA           NA
                                       code
      1 [<trimmed> signal_experimental (1)]
    Code
      flow_view_deps(lifecycle::signal_experimental, max_depth = 1, include_formals = TRUE,
      out = "data")
    Output
                   child_header      external_ref child_style parent_header
      1 signal_experimental (1) rlang::caller_env     trimmed            NA
        parent_style                                                  code
      1           NA [<trimmed> signal_experimental (1)|rlang::caller_env]

