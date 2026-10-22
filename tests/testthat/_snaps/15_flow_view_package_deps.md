# flow_view_package_deps works

    Code
      flow_view_package_deps("pkgA", db = db, out = "data")
    Output
        package dependency
      1    pkgA       pkgB
      2    pkgA       pkgD
      3    pkgB       pkgC
                                                                                                                                                                                                                                                                                                   code
      1 #direction: right\n#.main: visual=roundrect fill=#d9e1f2 align=center\n#.dependency: visual=roundrect fill=#fff2cc align=center\n#.leaf: visual=roundrect fill=#ededed align=center\n[<main> pkgA] -> [<dependency> pkgB]\n[<main> pkgA] -> [<leaf> pkgD]\n[<dependency> pkgB] -> [<leaf> pkgC]
      2 #direction: right\n#.main: visual=roundrect fill=#d9e1f2 align=center\n#.dependency: visual=roundrect fill=#fff2cc align=center\n#.leaf: visual=roundrect fill=#ededed align=center\n[<main> pkgA] -> [<dependency> pkgB]\n[<main> pkgA] -> [<leaf> pkgD]\n[<dependency> pkgB] -> [<leaf> pkgC]
      3 #direction: right\n#.main: visual=roundrect fill=#d9e1f2 align=center\n#.dependency: visual=roundrect fill=#fff2cc align=center\n#.leaf: visual=roundrect fill=#ededed align=center\n[<main> pkgA] -> [<dependency> pkgB]\n[<main> pkgA] -> [<leaf> pkgD]\n[<dependency> pkgB] -> [<leaf> pkgC]
    Code
      flow_view_package_deps(c("pkgA", "pkgB"), db = db, out = "data")
    Output
        package dependency
      1    pkgA       pkgB
      2    pkgA       pkgD
      3    pkgB       pkgC
                                                                                                                                                                                                                                                                                       code
      1 #direction: right\n#.main: visual=roundrect fill=#d9e1f2 align=center\n#.dependency: visual=roundrect fill=#fff2cc align=center\n#.leaf: visual=roundrect fill=#ededed align=center\n[<main> pkgA] -> [<main> pkgB]\n[<main> pkgA] -> [<leaf> pkgD]\n[<main> pkgB] -> [<leaf> pkgC]
      2 #direction: right\n#.main: visual=roundrect fill=#d9e1f2 align=center\n#.dependency: visual=roundrect fill=#fff2cc align=center\n#.leaf: visual=roundrect fill=#ededed align=center\n[<main> pkgA] -> [<main> pkgB]\n[<main> pkgA] -> [<leaf> pkgD]\n[<main> pkgB] -> [<leaf> pkgC]
      3 #direction: right\n#.main: visual=roundrect fill=#d9e1f2 align=center\n#.dependency: visual=roundrect fill=#fff2cc align=center\n#.leaf: visual=roundrect fill=#ededed align=center\n[<main> pkgA] -> [<main> pkgB]\n[<main> pkgA] -> [<leaf> pkgD]\n[<main> pkgB] -> [<leaf> pkgC]
    Code
      flow_view_package_deps("pkgA", db = db, base = TRUE, out = "data")
    Output
        package dependency
      1    pkgA       pkgB
      2    pkgA       pkgD
      3    pkgA      utils
      4    pkgB       pkgC
      5    pkgD      stats
                                                                                                                                                                                                                                                                                                                                                                                 code
      1 #direction: right\n#.main: visual=roundrect fill=#d9e1f2 align=center\n#.dependency: visual=roundrect fill=#fff2cc align=center\n#.leaf: visual=roundrect fill=#ededed align=center\n[<main> pkgA] -> [<dependency> pkgB]\n[<main> pkgA] -> [<dependency> pkgD]\n[<main> pkgA] -> [<leaf> utils]\n[<dependency> pkgB] -> [<leaf> pkgC]\n[<dependency> pkgD] -> [<leaf> stats]
      2 #direction: right\n#.main: visual=roundrect fill=#d9e1f2 align=center\n#.dependency: visual=roundrect fill=#fff2cc align=center\n#.leaf: visual=roundrect fill=#ededed align=center\n[<main> pkgA] -> [<dependency> pkgB]\n[<main> pkgA] -> [<dependency> pkgD]\n[<main> pkgA] -> [<leaf> utils]\n[<dependency> pkgB] -> [<leaf> pkgC]\n[<dependency> pkgD] -> [<leaf> stats]
      3 #direction: right\n#.main: visual=roundrect fill=#d9e1f2 align=center\n#.dependency: visual=roundrect fill=#fff2cc align=center\n#.leaf: visual=roundrect fill=#ededed align=center\n[<main> pkgA] -> [<dependency> pkgB]\n[<main> pkgA] -> [<dependency> pkgD]\n[<main> pkgA] -> [<leaf> utils]\n[<dependency> pkgB] -> [<leaf> pkgC]\n[<dependency> pkgD] -> [<leaf> stats]
      4 #direction: right\n#.main: visual=roundrect fill=#d9e1f2 align=center\n#.dependency: visual=roundrect fill=#fff2cc align=center\n#.leaf: visual=roundrect fill=#ededed align=center\n[<main> pkgA] -> [<dependency> pkgB]\n[<main> pkgA] -> [<dependency> pkgD]\n[<main> pkgA] -> [<leaf> utils]\n[<dependency> pkgB] -> [<leaf> pkgC]\n[<dependency> pkgD] -> [<leaf> stats]
      5 #direction: right\n#.main: visual=roundrect fill=#d9e1f2 align=center\n#.dependency: visual=roundrect fill=#fff2cc align=center\n#.leaf: visual=roundrect fill=#ededed align=center\n[<main> pkgA] -> [<dependency> pkgB]\n[<main> pkgA] -> [<dependency> pkgD]\n[<main> pkgA] -> [<leaf> utils]\n[<dependency> pkgB] -> [<leaf> pkgC]\n[<dependency> pkgD] -> [<leaf> stats]
    Code
      flow_view_package_deps("pkgA", db = db, demote_nodep = TRUE, out = "data")
    Output
             package   dependency
      1 pkgA\n+ pkgD pkgB\n+ pkgC
                                                                                                                                                                                                                                             code
      1 #direction: right\n#.main: visual=roundrect fill=#d9e1f2 align=center\n#.dependency: visual=roundrect fill=#fff2cc align=center\n#.leaf: visual=roundrect fill=#ededed align=center\n[<main> pkgA\n+ pkgD] -> [<dependency> pkgB\n+ pkgC]

