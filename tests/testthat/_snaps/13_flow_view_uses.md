# flow_view_uses

    Code
      flow_view_uses(save_nomnoml, out = "data")
    Output
                              fun                     vars   style2   style1
      1         flow_view_nomnoml             save_nomnoml unexpfun unexpfun
      2    flow_view_source_calls             save_nomnoml unexpfun   expfun
      3         flow_compare_runs             save_nomnoml unexpfun   expfun
      4            flow_view_vars             save_nomnoml unexpfun   expfun
      5            flow_view_deps             save_nomnoml unexpfun   expfun
      6            flow_view_uses             save_nomnoml unexpfun   expfun
      7                 flow_view        flow_view_nomnoml unexpfun   expfun
      8  append_function_diagrams                flow_view   expfun unexpfun
      9           flow_view_addin                flow_view   expfun unexpfun
      10                 flow_doc append_function_diagrams unexpfun   expfun
      11          flow_view_shiny           flow_view_deps   expfun   expfun
                                                                   code
      1     [<unexpfun> flow_view_nomnoml] -> [<unexpfun> save_nomnoml]
      2  [<expfun> flow_view_source_calls] -> [<unexpfun> save_nomnoml]
      3       [<expfun> flow_compare_runs] -> [<unexpfun> save_nomnoml]
      4          [<expfun> flow_view_vars] -> [<unexpfun> save_nomnoml]
      5          [<expfun> flow_view_deps] -> [<unexpfun> save_nomnoml]
      6          [<expfun> flow_view_uses] -> [<unexpfun> save_nomnoml]
      7          [<expfun> flow_view] -> [<unexpfun> flow_view_nomnoml]
      8   [<unexpfun> append_function_diagrams] -> [<expfun> flow_view]
      9            [<unexpfun> flow_view_addin] -> [<expfun> flow_view]
      10   [<expfun> flow_doc] -> [<unexpfun> append_function_diagrams]
      11        [<expfun> flow_view_shiny] -> [<expfun> flow_view_deps]

