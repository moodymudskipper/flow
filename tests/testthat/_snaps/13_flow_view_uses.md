# flow_view_uses

    Code
      flow_view_uses(save_nomnoml, out = "data")
    Output
                                fun                     vars   style2   style1
      77          flow_view_nomnoml             save_nomnoml unexpfun unexpfun
      382    flow_view_source_calls             save_nomnoml unexpfun   expfun
      583         flow_compare_runs             save_nomnoml unexpfun unexpfun
      788            flow_view_vars             save_nomnoml unexpfun   expfun
      1657           flow_view_deps             save_nomnoml unexpfun   expfun
      2698           flow_view_uses             save_nomnoml unexpfun   expfun
      903                 flow_view        flow_view_nomnoml unexpfun   expfun
      1124 append_function_diagrams                flow_view   expfun unexpfun
      2468          flow_view_addin                flow_view   expfun unexpfun
      972                  flow_doc append_function_diagrams unexpfun   expfun
      1198          flow_view_shiny           flow_view_deps   expfun   expfun
                                                                     code
      77      [<unexpfun> flow_view_nomnoml] -> [<unexpfun> save_nomnoml]
      382  [<expfun> flow_view_source_calls] -> [<unexpfun> save_nomnoml]
      583     [<unexpfun> flow_compare_runs] -> [<unexpfun> save_nomnoml]
      788          [<expfun> flow_view_vars] -> [<unexpfun> save_nomnoml]
      1657         [<expfun> flow_view_deps] -> [<unexpfun> save_nomnoml]
      2698         [<expfun> flow_view_uses] -> [<unexpfun> save_nomnoml]
      903          [<expfun> flow_view] -> [<unexpfun> flow_view_nomnoml]
      1124  [<unexpfun> append_function_diagrams] -> [<expfun> flow_view]
      2468           [<unexpfun> flow_view_addin] -> [<expfun> flow_view]
      972    [<expfun> flow_doc] -> [<unexpfun> append_function_diagrams]
      1198        [<expfun> flow_view_shiny] -> [<expfun> flow_view_deps]

