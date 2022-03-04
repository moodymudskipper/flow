# flow_data works with an empty for loop

    Code
      out
    Output
      $nodes
        id block_type                  code_str label
      1  0     header                    fun(x)      
      2  1        for   for (x in foo)  \n           
      3  2   standard                                
      4 -1      start                                
      5  3     return                                
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2               ->
      3    2 -1               ->
      4    1 -1       next    <-
      5   -1  3               ->
      

# flow_data works with simple for loop

    Code
      out
    Output
      $nodes
        id block_type                  code_str label
      1  0     header                    fun(x)      
      2  1        for   for (x in foo)  \n           
      3  2   standard                         x      
      4 -1      start                                
      5  3     return                                
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2               ->
      3    2 -1               ->
      4    1 -1       next    <-
      5   -1  3               ->
      

# flow_data works with simple while loop

    Code
      out
    Output
      $nodes
        id block_type               code_str label
      1  0     header                 fun(x)      
      2  1      while   while (foo)  \n           
      3  2   standard                      x      
      4 -1      start                             
      5  3     return                             
      
      $edges
        from to edge_label arrow
      1    0  1               ->
      2    1  2               ->
      3    2 -1               ->
      4    1 -1       next    <-
      5   -1  3               ->
      

# flow_data works with simple repeat loop

    Code
      out
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
      out
    Output
      $nodes
         id block_type                  code_str label
      1   0     header                    fun(x)      
      2   1         if         if (foo)  \n           
      3   2        for   for (x in bar)  \n           
      4   3   standard                       baz      
      5  -2      start                                
      6   4        for   for (x in qux)  \n           
      7   5   standard                      quux      
      8  -4      start                                
      9  -1        end                                
      10  6     return                                
      
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
      

