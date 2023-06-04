# flow_view_uses

    Code
      flow_view_uses(save_nomnoml, out = "data")
    Output
                                fun                     vars   style2   style1
      77          flow_view_nomnoml             save_nomnoml unexpfun unexpfun
      406    flow_view_source_calls             save_nomnoml unexpfun   expfun
      609         flow_compare_runs             save_nomnoml unexpfun   expfun
      814            flow_view_vars             save_nomnoml unexpfun   expfun
      1692           flow_view_deps             save_nomnoml unexpfun   expfun
      2735           flow_view_uses             save_nomnoml unexpfun   expfun
      929                 flow_view        flow_view_nomnoml unexpfun   expfun
      1144 append_function_diagrams                flow_view   expfun unexpfun
      2503          flow_view_addin                flow_view   expfun unexpfun
      996                  flow_doc append_function_diagrams unexpfun   expfun
      1218          flow_view_shiny           flow_view_deps   expfun   expfun
                                                                     code
      77      [<unexpfun> flow_view_nomnoml] -> [<unexpfun> save_nomnoml]
      406  [<expfun> flow_view_source_calls] -> [<unexpfun> save_nomnoml]
      609       [<expfun> flow_compare_runs] -> [<unexpfun> save_nomnoml]
      814          [<expfun> flow_view_vars] -> [<unexpfun> save_nomnoml]
      1692         [<expfun> flow_view_deps] -> [<unexpfun> save_nomnoml]
      2735         [<expfun> flow_view_uses] -> [<unexpfun> save_nomnoml]
      929          [<expfun> flow_view] -> [<unexpfun> flow_view_nomnoml]
      1144  [<unexpfun> append_function_diagrams] -> [<expfun> flow_view]
      2503           [<unexpfun> flow_view_addin] -> [<expfun> flow_view]
      996    [<expfun> flow_doc] -> [<unexpfun> append_function_diagrams]
      1218        [<expfun> flow_view_shiny] -> [<expfun> flow_view_deps]

