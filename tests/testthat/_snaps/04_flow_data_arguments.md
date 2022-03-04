# nested_fun works

    Code
      out
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
      out
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
      

# flow_data works with narrow argument

    Code
      out
    Output
      $nodes
        id block_type          code_str label
      1  0     header            fun(x)      
      2  1         if   if (x)  \n           
      3  2   standard               foo      
      4  3   standard               bar      
      5 -1        end                        
      6  4     return                        
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2          y    ->
      3    2 -1               ->
      4    1  3          n    ->
      5    3 -1               ->
      6   -1  4               ->
      

---

    Code
      out
    Output
      $nodes
        id block_type          code_str label
      1  0     header         fun(x, y)      
      2  1         if   if (x)  \n           
      3  2   standard            stop()      
      4 -2       stop                        
      5  3   standard               bar      
      6 -1        end                        
      7  4     return                        
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2          y    ->
      3    2 -2               ->
      4    1  3          n    ->
      5    3 -1               ->
      6   -1  4               ->
      

---

    Code
      out
    Output
      $nodes
        id block_type          code_str label
      1  0     header         fun(x, y)      
      2  1         if   if (x)  \n           
      3  2   standard               foo      
      4  3   standard            stop()      
      5 -3       stop                        
      6 -1        end                        
      7  4     return                        
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2          y    ->
      3    2 -1               ->
      4    1  3          n    ->
      5    3 -3               ->
      6   -1  4               ->
      

