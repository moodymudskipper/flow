# flow_data works with empty fun

    Code
      flow_data(fun)
    Output
      $nodes
        id block_type code_str label
      1  0     header   fun(x)      
      2  1   standard               
      3  2     return               
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2               ->
      

# flow_data works with one symbol in body

    Code
      flow_data(fun)
    Output
      $nodes
        id block_type code_str label
      1  0     header   fun(x)      
      2  1   standard        x      
      3  2     return               
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2               ->
      

# flow_data works with one call in body

    Code
      flow_data(fun)
    Output
      $nodes
        id block_type            code_str label
      1  0     header              fun(x)      
      2  1   standard x<U+2800>+<U+2800>y      
      3  2     return                          
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2               ->
      

# flow_data works with 2 calls in body

    Code
      flow_data(fun)
    Output
      $nodes
        id block_type                                 code_str label
      1  0     header                                   fun(x)      
      2  1   standard x<U+2800>+<U+2800>y\nu<U+2800>+<U+2800>v      
      3  2     return                                               
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2               ->
      

# flow_data works on calls

    Code
      flow_data(call)
    Output
      $nodes
        id block_type                                                     code_str
      1  1   standard x<U+2800><-<U+2800>x<U+2800>*<U+2800>2\ny<U+2800><-<U+2800>x
      2  2     return                                                             
        label
      1      
      2      
      
      $edges
        from to edge_label arrow
      1    1  2               ->
      

# flow_data works on paths

    Code
      flow_data(tmp)
    Output
      $nodes
        id block_type                                                     code_str
      1  1   standard x<U+2800><-<U+2800>x<U+2800>*<U+2800>2\ny<U+2800><-<U+2800>x
      2  2     return                                                             
        label
      1      
      2      
      
      $edges
        from to edge_label arrow
      1    1  2               ->
      

# flow_data works on lists

    Code
      flow_data(list(f = fun))
    Output
      $nodes
        id block_type code_str label
      1  0     header     f(x)      
      2  1   standard        x      
      3  2     return               
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2               ->
      

