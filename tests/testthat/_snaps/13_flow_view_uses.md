# flow_view_uses

    Code
      flow_view_uses(save_nomnoml, out = "data")
    Output
                                fun                     vars   style2   style1
      77          flow_view_nomnoml             save_nomnoml unexpfun unexpfun
      382    flow_view_source_calls             save_nomnoml unexpfun   expfun
      585         flow_compare_runs             save_nomnoml unexpfun   expfun
      790            flow_view_vars             save_nomnoml unexpfun   expfun
      1659           flow_view_deps             save_nomnoml unexpfun   expfun
      2702           flow_view_uses             save_nomnoml unexpfun   expfun
      905                 flow_view        flow_view_nomnoml unexpfun   expfun
      1126 append_function_diagrams                flow_view   expfun unexpfun
      2470          flow_view_addin                flow_view   expfun unexpfun
      974                  flow_doc append_function_diagrams unexpfun   expfun
      1200          flow_view_shiny           flow_view_deps   expfun   expfun
                                                                     code
      77      [<unexpfun> flow_view_nomnoml] -> [<unexpfun> save_nomnoml]
      382  [<expfun> flow_view_source_calls] -> [<unexpfun> save_nomnoml]
      585       [<expfun> flow_compare_runs] -> [<unexpfun> save_nomnoml]
      790          [<expfun> flow_view_vars] -> [<unexpfun> save_nomnoml]
      1659         [<expfun> flow_view_deps] -> [<unexpfun> save_nomnoml]
      2702         [<expfun> flow_view_uses] -> [<unexpfun> save_nomnoml]
      905          [<expfun> flow_view] -> [<unexpfun> flow_view_nomnoml]
      1126  [<unexpfun> append_function_diagrams] -> [<expfun> flow_view]
      2470           [<unexpfun> flow_view_addin] -> [<expfun> flow_view]
      974    [<expfun> flow_doc] -> [<unexpfun> append_function_diagrams]
      1200        [<expfun> flow_view_shiny] -> [<expfun> flow_view_deps]

