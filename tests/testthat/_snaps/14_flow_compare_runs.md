# flow_compare_runs

    Code
      flow_compare_runs(rle(NULL), rle(c(1, 2, 2, 3)), out = "data")
    Output
      $nodes
         id block_type
      1   0     header
      2   1         if
      3   2  standardr
      4  -2       stop
      5  -1        end
      6   3  standardg
      7   4         if
      8   5   standard
      9  -5     return
      10 -4        end
      11  6  standardg
      12  7     return
                                                                                                                                       code_str
      1                                                                                                                                  rle(x)
      2                                                                                            ⠀ if (!is.vector(x) && !is.list(x)) ⠀\n⠀ ⠀ ⠀
      3                                                                                          stop("'x' must be a vector of an atomic type")
      4                                                                                                                                        
      5                                                                                                                                        
      6                                                                                                                          n <- length(x)
      7                                                                                                                 ⠀ if (n == 0L) ⠀\n⠀ ⠀ ⠀
      8                                                        return(structure(list(\n⠀ lengths = integer(),\n⠀ values = x\n), class = "rle"))
      9                                                                                                                                        
      10                                                                                                                                       
      11 y <- x[-1L] != x[-n]\ni <- c(which(y | is.na(y)), n)\nstructure(list(\n⠀ lengths = diff(c(0L, i)),\n⠀ values = x[i]\n), class = "rle")
      12                                                                                                                                       
         label passes
      1             0
      2             1
      3             1
      4             0
      5             0
      6             0
      7             0
      8             0
      9             0
      10            0
      11            0
      12            0
      
      $edges
         from to edge_label arrow passes
      1     0  1        (1)    ->      1
      2     1  2   y (x: 1)    ->      1
      3     2 -2             --:>      0
      4     1 -1 n (ref: 1)    ->      0
      5    -1  3   (ref: 1)    ->      0
      6     3  4   (ref: 1)    ->      0
      7     4  5          y  --:>      0
      8     5 -5             --:>      0
      9     4 -4 n (ref: 1)    ->      0
      10   -4  6   (ref: 1)    ->      0
      11    6  7   (ref: 1)    ->      0
      

