# flow_data works with an empty for loop

    Code
      flow_data(fun)
    Output
      $nodes
        id block_type
      1  0     header
      2  1        for
      3  2   standard
      4 -1      start
      5  3     return
                                                                                                             code_str
      1                                                                                                        fun(x)
      2 <U+2800><U+2800>for<U+2800>(x<U+2800>in<U+2800>foo)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
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
      2    1  2               ->
      3    2 -1               ->
      4    1 -1       next    <-
      5   -1  3               ->
      

# flow_data works with simple for loop

    Code
      flow_data(fun)
    Output
      $nodes
        id block_type
      1  0     header
      2  1        for
      3  2   standard
      4 -1      start
      5  3     return
                                                                                                             code_str
      1                                                                                                        fun(x)
      2 <U+2800><U+2800>for<U+2800>(x<U+2800>in<U+2800>foo)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      3                                                                                                             x
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
      2    1  2               ->
      3    2 -1               ->
      4    1 -1       next    <-
      5   -1  3               ->
      

# flow_data works with simple while loop

    Code
      flow_data(fun)
    Output
      $nodes
        id block_type
      1  0     header
      2  1      while
      3  2   standard
      4 -1      start
      5  3     return
                                                                                            code_str
      1                                                                                       fun(x)
      2 <U+2800><U+2800>while<U+2800>(foo)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      3                                                                                            x
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
      2    1  2               ->
      3    2 -1               ->
      4    1 -1       next    <-
      5   -1  3               ->
      

# flow_data works with simple repeat loop

    Code
      flow_data(fun)
    Output
      $nodes
        id block_type code_str label
      1  0     header   fun(x)      
      2  1     repeat   repeat      
      3  2   standard        x      
      4 -1      start               
      5  3     return               
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2               ->
      3    2 -1               ->
      4    1 -1       next    <-
      5   -1  3               ->
      

# flow_data works if else call with for loops on each side

    Code
      flow_data(fun)
    Output
      $nodes
         id block_type
      1   0     header
      2   1         if
      3   2        for
      4   3   standard
      5  -2      start
      6   4        for
      7   5   standard
      8  -4      start
      9  -1        end
      10  6     return
                                                                                                              code_str
      1                                                                                                         fun(x)
      2                      <U+2800><U+2800>if<U+2800>(foo)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      3  <U+2800><U+2800>for<U+2800>(x<U+2800>in<U+2800>bar)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      4                                                                                                            baz
      5                                                                                                               
      6  <U+2800><U+2800>for<U+2800>(x<U+2800>in<U+2800>qux)<U+2800><U+2800>\n<U+2800><U+2800><U+2800><U+2800><U+2800>
      7                                                                                                           quux
      8                                                                                                               
      9                                                                                                               
      10                                                                                                              
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
      10      
      
      $edges
         from to edge_label arrow
      1     0  1               ->
      2     1  2          y    ->
      3     2  3               ->
      4     3 -2               ->
      5     2 -2       next    <-
      6    -2 -1               ->
      7     1  4          n    ->
      8     4  5               ->
      9     5 -4               ->
      10    4 -4       next    <-
      11   -4 -1               ->
      12   -1  6               ->
      

