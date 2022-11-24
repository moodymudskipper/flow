# flow_view_uses

    Code
      flow_view_uses(purrr:::accum_index, out = "data")
    Output
                          fun               vars   style2   style1
      257        reduce2_impl        accum_index unexpfun unexpfun
      809         reduce_impl        accum_index unexpfun unexpfun
      675         accumulate2       reduce2_impl unexpfun   expfun
      1803            reduce2       reduce2_impl unexpfun   expfun
      1900      reduce2_right       reduce2_impl unexpfun   expfun
      1249         accumulate        reduce_impl unexpfun   expfun
      1652             reduce        reduce_impl unexpfun   expfun
      2323       reduce_right        reduce_impl unexpfun   expfun
      862    accumulate_right         accumulate   expfun   expfun
      625  reduce_subset_call             reduce   expfun unexpfun
      2917          assign_in reduce_subset_call unexpfun   expfun
      1220          modify_in          assign_in   expfun   expfun
      1480            pluck<-          assign_in   expfun   expfun
                                                              code
      257    [<unexpfun> reduce2_impl] -> [<unexpfun> accum_index]
      809     [<unexpfun> reduce_impl] -> [<unexpfun> accum_index]
      675      [<expfun> accumulate2] -> [<unexpfun> reduce2_impl]
      1803         [<expfun> reduce2] -> [<unexpfun> reduce2_impl]
      1900   [<expfun> reduce2_right] -> [<unexpfun> reduce2_impl]
      1249       [<expfun> accumulate] -> [<unexpfun> reduce_impl]
      1652           [<expfun> reduce] -> [<unexpfun> reduce_impl]
      2323     [<expfun> reduce_right] -> [<unexpfun> reduce_impl]
      862     [<expfun> accumulate_right] -> [<expfun> accumulate]
      625     [<unexpfun> reduce_subset_call] -> [<expfun> reduce]
      2917 [<expfun> assign_in] -> [<unexpfun> reduce_subset_call]
      1220            [<expfun> modify_in] -> [<expfun> assign_in]
      1480              [<expfun> pluck<-] -> [<expfun> assign_in]

