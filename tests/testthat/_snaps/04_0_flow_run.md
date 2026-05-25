# flow_run

    Code
      flow_run(ave(1:10), out = "data")
    Output
      $nodes
        id block_type                                                       code_str
      1  0     header                                        ave(x, ..., FUN = mean)
      2  1         if                                   ⠀ if (missing(...)) ⠀\n⠀ ⠀ ⠀
      3  2   standard                                                  x[] <- FUN(x)
      4  3   standard g <- interaction(...)\nsplit(x, g) <- lapply(split(x, g), FUN)
      5 -1        end                                                               
      6  4   standard                                                              x
      7  5     return                                                               
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
      

