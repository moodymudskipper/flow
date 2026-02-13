# flow_view_uses

    Code
      uses_sorted
    Output
                              fun                     vars   style2   style1
      9  append_function_diagrams                flow_view   expfun unexpfun
      5         flow_compare_runs             save_nomnoml unexpfun   expfun
      11                 flow_doc append_function_diagrams unexpfun   expfun
      8                 flow_view        flow_view_nomnoml unexpfun   expfun
      10          flow_view_addin                flow_view   expfun unexpfun
      2            flow_view_deps             save_nomnoml unexpfun   expfun
      4         flow_view_nomnoml             save_nomnoml unexpfun unexpfun
      7           flow_view_shiny           flow_view_deps   expfun   expfun
      6    flow_view_source_calls             save_nomnoml unexpfun   expfun
      3            flow_view_uses             save_nomnoml unexpfun   expfun
      1            flow_view_vars             save_nomnoml unexpfun   expfun
                                                                   code
      9   [<unexpfun> append_function_diagrams] -> [<expfun> flow_view]
      5       [<expfun> flow_compare_runs] -> [<unexpfun> save_nomnoml]
      11   [<expfun> flow_doc] -> [<unexpfun> append_function_diagrams]
      8          [<expfun> flow_view] -> [<unexpfun> flow_view_nomnoml]
      10           [<unexpfun> flow_view_addin] -> [<expfun> flow_view]
      2          [<expfun> flow_view_deps] -> [<unexpfun> save_nomnoml]
      4     [<unexpfun> flow_view_nomnoml] -> [<unexpfun> save_nomnoml]
      7         [<expfun> flow_view_shiny] -> [<expfun> flow_view_deps]
      6  [<expfun> flow_view_source_calls] -> [<unexpfun> save_nomnoml]
      3          [<expfun> flow_view_uses] -> [<unexpfun> save_nomnoml]
      1          [<expfun> flow_view_vars] -> [<unexpfun> save_nomnoml]

