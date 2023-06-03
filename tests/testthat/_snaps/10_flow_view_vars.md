# flow_view_vars

    Code
      flow_view_vars(ave, out = "code")
    Output
      [1] "\n# direction: down\n#.fun: visual=roundrect fill=#ddebf7 title=bold\n#.arg: visual=roundrect fill=#e2efda title=bold\n#.var: visual=roundrect fill=#f0f0f0 title=bold\n#.newvar: visual=roundrect fill=#fff2cc title=bold\n#.return: visual=end fill=#70ad47  empty\n#.deadcode: visual=roundrect fill=#fce4d6 dashed title=bold\n[<fun> ave] -> [<arg> x]\n[<fun> ave] -> [<arg> ...]\n[<fun> ave] -> [<arg> FUN]\n[<arg> FUN] -> [<var> x*]\n[<arg> x] -> [<var> x*]\n[<arg> x] -> [<var> x*]\n[<arg> ...] --> [<var> x*]\n[<arg> ...] -> [<var> g]\n[<arg> x] -> [<var> x**]\n[<var> g] -> [<var> x**]\n[<arg> FUN] -> [<var> x**]\n[<arg> x] -> [<var> x**]\n[<arg> ...] --> [<var> x**]\n[<var> x*] -> [<var> x***]\n[<var> x**] -> [<var> x***]\n[<var> x***] -> [<return> *OUT*]"
    Code
      flow_view_vars(ave, out = "data")
    Output
           lhs  rhs   link action
      1      x  ave   args   args
      2    ...  ave   args   args
      3    FUN  ave   args   args
      4     x*  FUN direct   edit
      5     x*    x direct   edit
      6     x*    x direct   edit
      7     x*  ...     cf   edit
      8      g  ... direct  write
      9    x**    x direct   edit
      10   x**    g direct   edit
      11   x**  FUN direct   edit
      12   x**    x direct   edit
      13   x**  ...     cf   edit
      14  x***   x* direct  write
      15  x***  x** direct  write
      16 *OUT* x*** direct  write

