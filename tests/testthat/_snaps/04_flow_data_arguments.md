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
      

# flow_data works with narrow argument

    Code
      flow_data(fun)
    Output
      $nodes
        id block_type
      1  0     header
      2  1         if
      3  2   standard
      4  3   standard
      5 -1        end
      6  4     return
                                                                                       code_str
      1                                                                                  fun(x)
      2 <U+2800><U+2800>if<U+2800>(x)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      3                                                                                     foo
      4                                                                                     bar
      5                                                                                        
      6                                                                                        
        label
      1      
      2      
      3      
      4      
      5      
      6      
      
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
      flow_data(fun)
    Output
      $nodes
        id block_type
      1  0     header
      2  1         if
      3  2   standard
      4 -2       stop
      5  3   standard
      6 -1        end
      7  4     return
                                                                                       code_str
      1                                                                        fun(x,<U+2800>y)
      2 <U+2800><U+2800>if<U+2800>(x)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      3                                                                                  stop()
      4                                                                                        
      5                                                                                     bar
      6                                                                                        
      7                                                                                        
        label
      1      
      2      
      3      
      4      
      5      
      6      
      7      
      
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
      flow_data(fun)
    Output
      $nodes
        id block_type
      1  0     header
      2  1         if
      3  2   standard
      4  3   standard
      5 -3       stop
      6 -1        end
      7  4     return
                                                                                       code_str
      1                                                                        fun(x,<U+2800>y)
      2 <U+2800><U+2800>if<U+2800>(x)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      3                                                                                     foo
      4                                                                                  stop()
      5                                                                                        
      6                                                                                        
      7                                                                                        
        label
      1      
      2      
      3      
      4      
      5      
      6      
      7      
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2          y    ->
      3    2 -1               ->
      4    1  3          n    ->
      5    3 -3               ->
      6   -1  4               ->
      

