# sub_fun_id works

    Code
      flow_data(fun, sub_fun_id = 2)
    Output
      $nodes
        id block_type code_str label
      1  0     header   fun(z)      
      2  1   standard        z      
      3  2     return               
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2               ->
      

# flow_data works with prefixed comments

    Code
      flow_data(fun, prefix = "##")
    Output
      $nodes
        id block_type code_str   label
      1  0     header   fun(x)        
      2  1   standard        x comment
      3  2     return                 
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2               ->
      

