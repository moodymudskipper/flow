# flow_data works with simple if and empty body

    Code
      flow_data(fun)
    Output
      $nodes
        id block_type
      1  0     header
      2  1         if
      3  2   standard
      4 -1        end
      5  3     return
                                                                                       code_str
      1                                                                                  fun(x)
      2 <U+2800><U+2800>if<U+2800>(x)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      3                                                                                        
      4                                                                                        
      5                                                                                        
        label
      1      
      2      
      3      
      4      
      5      
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2          y    ->
      3    2 -1               ->
      4    1 -1          n    ->
      5   -1  3               ->
      

# flow_data works with simple if

    Code
      flow_data(fun)
    Output
      $nodes
        id block_type
      1  0     header
      2  1         if
      3  2   standard
      4 -1        end
      5  3     return
                                                                                       code_str
      1                                                                                  fun(x)
      2 <U+2800><U+2800>if<U+2800>(x)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      3                                                                                     foo
      4                                                                                        
      5                                                                                        
        label
      1      
      2      
      3      
      4      
      5      
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2          y    ->
      3    2 -1               ->
      4    1 -1          n    ->
      5   -1  3               ->
      

# flow_data works with simple if else

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
      

# flow_data works returning on the yes branch

    Code
      flow_data(fun)
    Output
      $nodes
        id block_type
      1  0     header
      2  1         if
      3  2   standard
      4 -2     return
      5  3   standard
      6 -1        end
      7  4     return
                                                                                       code_str
      1                                                                                  fun(x)
      2 <U+2800><U+2800>if<U+2800>(x)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      3                                                                             return(foo)
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
      

# flow_data works stopping on the no branch

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
      1                                                                                  fun(x)
      2 <U+2800><U+2800>if<U+2800>(x)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      3                                                                                     foo
      4                                                                               stop(bar)
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
      

# flow_data works stopping on the yes branch and returning on the right branch

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
      6 -3     return
      7  4     return
                                                                                       code_str
      1                                                                                  fun(x)
      2 <U+2800><U+2800>if<U+2800>(x)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      3                                                                               stop(foo)
      4                                                                                        
      5                                                                             return(bar)
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
      5    3 -3               ->
      

# flow_data works with nested if calls

    Code
      flow_data(fun)
    Output
      $nodes
        id block_type
      1  0     header
      2  1         if
      3  2         if
      4  3   standard
      5  4   standard
      6 -2        end
      7 -1        end
      8  5     return
                                                                                       code_str
      1                                                                                  fun(x)
      2 <U+2800><U+2800>if<U+2800>(x)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      3 <U+2800><U+2800>if<U+2800>(y)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      4                                                                                     foo
      5                                                                                     bar
      6                                                                                        
      7                                                                                        
      8                                                                                        
        label
      1      
      2      
      3      
      4      
      5      
      6      
      7      
      8      
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2          y    ->
      3    2  3          y    ->
      4    3 -2               ->
      5    2  4          n    ->
      6    4 -2               ->
      7   -2 -1               ->
      8    1 -1          n    ->
      9   -1  5               ->
      

---

    Code
      flow_data(fun)
    Output
      $nodes
        id block_type
      1  0     header
      2  1         if
      3  2         if
      4  3   standard
      5 -3       stop
      6  4   standard
      7 -4       stop
      8 -1        end
      9  5     return
                                                                                       code_str
      1                                                                        fun(x,<U+2800>y)
      2 <U+2800><U+2800>if<U+2800>(x)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      3 <U+2800><U+2800>if<U+2800>(y)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      4                                                                                  stop()
      5                                                                                        
      6                                                                                  stop()
      7                                                                                        
      8                                                                                        
      9                                                                                        
        label
      1      
      2      
      3      
      4      
      5      
      6      
      7      
      8      
      9      
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2          y    ->
      3    2  3          y    ->
      4    3 -3               ->
      5    2  4          n    ->
      6    1 -1          n    ->
      7   -1  5               ->
      

