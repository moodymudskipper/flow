# flow_run

    Code
      flow_run(ave(1:10), out = "data")
    Output
      $nodes
        id block_type
      1  0     header
      2  1         if
      3  2   standard
      4  3   standard
      5 -1        end
      6  4   standard
      7  5     return
                                                                           code_str
      1                                                     ave(x, ..., FUN = mean)
      2                                                ⠀ if (missing(...)) ⠀\n⠀ ⠀ ⠀
      3                                                               x[] <- FUN(x)
      4 g <- interaction(..., drop = TRUE)\nsplit(x, g) <- lapply(split(x, g), FUN)
      5                                                                            
      6                                                                           x
      7                                                                            
        label passes
      1            0
      2            1
      3            1
      4            0
      5            1
      6            1
      7            0
      
      $edges
        from to edge_label arrow passes
      1    0  1               ->      1
      2    1  2          y    ->      1
      3    2 -1               ->      1
      4    1  3          n  --:>      0
      5    3 -1             --:>      0
      6   -1  4               ->      1
      7    4  5               ->      1
      

