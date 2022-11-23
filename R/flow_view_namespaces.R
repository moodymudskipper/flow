# FIXME: I think we can, maybe optionally, disentangle the graph, we should keep only longest path


flow_view_namespaces <- function(out = NULL, include_base = FALSE) {
  nomnoml_setup <- c(
    "# direction: right", "#.attached: visual=roundrect fill=#ddebf7 title=bold",
    "#.unattached: visual=roundrect fill=#fff2cc title=bold",
    "#.base: visual=roundrect fill=#fce4d6 dashed title=bold"
  )

  # build data from namespaces
  ns <- loadedNamespaces()
  installed <- installed.packages()[,c("Package", "LibPath", "Version", "Depends", "Imports", "LinkingTo", "Suggests", "Enhances")]
  installed <- as.data.frame(installed)
  # stick to loaded namespaces
  loaded <- installed[installed$Package %in% setdiff(ns, "base"), ]
  # we might have duplicated packages, installed in different libPaths
  # we fetch the actual path and keep the matches
  loaded$LibPath_loaded <- dirname(sapply(loaded$Package, function(x) asNamespace(x)[[".__NAMESPACE__."]]$path))
  loaded <- loaded[loaded$LibPath == loaded$LibPath_loaded,]
  loaded$LibPath_loaded <- NULL
  # we assume that the loaded packages are loaded from the first fitting libPath

  loaded <- reshape(
    loaded,
    direction = "long",
    idvar = c("Package", "Version", "LibPath"), # columns to keep, so we can pivot along them
    timevar = "dep_type", # name of the new column that would store the column names of the wide form
    v.names = "deps", # name of the column that will store the values
    varying = c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances"), # columns to pivot
    times = c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances") # values to give to the column names, by default an index
  )

  # remove Enhances, LinkingTo
  loaded <- loaded[!loaded$dep_type %in% c("Enhances", "LinkingTo", "Suggests"),]

  # remove versions
  loaded$deps <- gsub("\\s?\\(.*?\\)", "", loaded$deps)
  # remove new lines and potential multi spaces
  loaded$deps <- gsub("\\s+", " ", loaded$deps)
  loaded$deps <- strsplit(loaded$deps, ", ")
  loaded <- do.call(rbind, Map(
    function(Package, Version, LibPath, deps) data.frame(Package, Version, LibPath, deps),
    loaded$Package, loaded$Version, loaded$LibPath, loaded$deps
  ))
  loaded <- loaded[!is.na(loaded$deps) & loaded$deps != "R", ]

  # remove deps that are not loaded (imports and depends should be loaded, but not all others)

  loaded <- loaded[loaded$deps %in% setdiff(ns, "base"), ]

  row.names(loaded) <- NULL
  names(loaded) <- c("parent", "version", "libpath", "child")

  # attached
  attached <- sub("^package:", "", grep("^package:", search(), value = TRUE))
  # loaded$parent_attached <- loaded$parent %in% attached
  # loaded$child_attached <- loaded$child %in% attached

  # style
  base_pkgs <- c("stats", "graphics", "grDevices", "utils", "datasets", "methods", "base")
  loaded$style_parent <- "unattached"
  loaded$style_parent[loaded$parent %in% attached] <- "attached"
  loaded$style_parent[loaded$parent %in% base_pkgs] <- "base"
  loaded$style_child <-  "unattached"
  loaded$style_child[loaded$child %in% attached] <- "attached"
  loaded$style_child[loaded$child %in% base_pkgs] <- "base"


  if (!include_base) {
    loaded <- loaded[
      loaded$style_parent != "base" & loaded$style_child != "base",
    ]
  } else {
    # we still remove dependencies between base packages
    loaded <- loaded[
      loaded$style_parent != "base" | loaded$style_child != "base",
    ]
  }

  # simplify
  if (TRUE) {
    # very wasteful but quick enough anyway
    get_deps <- function(pkg) {
      #print(pkg)
      own_deps <- loaded$child[loaded$parent == pkg]

      rec_deps <- lapply(own_deps, get_deps)
      #print(unique(c(own_deps, rec_deps)))
      unique(unlist(c(own_deps, rec_deps)))
    }
    browser()
    pkgs <- unique(loaded$parent[loaded$style_parent == "attached"])
    deps <- sapply(pkgs, get_deps, simplify = FALSE, USE.NAMES = TRUE)
    # FIXME: from there rebuild a "loaded" dataframe
  }

  nomnoml_code <- sprintf(
    "[<%s> %s] -> [<%s> %s]",
    loaded$style_parent,
    loaded$parent,
    loaded$style_child,
    loaded$child
  )

  nomnoml_code_full <- paste(c(nomnoml_setup, nomnoml_code), collapse = "\n")
  if (identical(out, "code")) return(nomnoml_code)
  svg <- is.null(out) || endsWith(out, ".html") || endsWith(out, ".htm")
  out <- save_nomnoml(nomnoml_code_full, svg, out)
  if(inherits(out, "htmlwidget")) out else invisible(out)
}
