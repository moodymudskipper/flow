#' View package dependencies as a flow diagram
#'
#' @description
#' `r lifecycle::badge("experimental")`
#' 
#' Creates a dependency graph showing how packages depend on each other.
#' The function recursively resolves package dependencies and generates
#' a nomnoml diagram.
#'
#' @param pkg Character vector of package names to analyze
#' @param db A matrix of package metadata as returned by
#'   [utils::available.packages()], passed to [tools::package_dependencies()].
#'   By default the package index of the repositories set in
#'   `getOption("repos")` is used, which requires an internet connection.
#' @param demote_nodep Logical. If TRUE, packages with no dependencies are shown
#'   with a "+" prefix in the diagram
#' @param base Logical. If FALSE (default), base packages are excluded from
#'   the dependency graph
#' @param out Output specification. If NULL, returns a flow_diagram object.
#'   Can be "html", "png", "pdf", etc. for file output, or "data" to return
#'   the dependency data
#'
#' @return A flow_diagram object containing the dependency graph, or the
#'   output path if out is specified
#'
#' @export
#' @examples
#' # a toy package database, to run offline
#' db <- cbind(
#'   Package = c("pkgA", "pkgB", "pkgC"),
#'   Depends = c("R (>= 4.0)", NA, NA),
#'   Imports = c("pkgB, utils", "pkgC", NA),
#'   LinkingTo = NA
#' )
#' flow_view_package_deps("pkgA", db = db)
#'
#' # Include base packages
#' flow_view_package_deps("pkgA", db = db, base = TRUE)
#'
#' # Show packages with no dependencies inside their dependent's box
#' flow_view_package_deps("pkgA", db = db, demote_nodep = TRUE)
#'
#' @examplesIf interactive()
#' # Use the CRAN package index
#' flow_view_package_deps("dplyr")
#' flow_view_package_deps(c("dplyr", "ggplot2"))
flow_view_package_deps <- function(pkg, db = NULL, demote_nodep = FALSE, base = FALSE,
                                  out = NULL) {

  # fetch the package index once rather than at every iteration
  if (is.null(db)) db <- utils::available.packages()

  # Initialize dependencies data frame
  all_deps <- tools::package_dependencies(pkg, db = db)
  deps <- data.frame(
    pkg = rep(names(all_deps), lengths(all_deps)),
    dep = unlist(all_deps, use.names = FALSE)
  )
  
  # Recursively resolve dependencies
  todo <- setdiff(deps$dep, c(deps$pkg, NA))
  while (length(todo)) {
    dep <- tools::package_dependencies(todo[[1]], db = db)[[1]]
    if (!length(dep)) dep <- NA
    new <- data.frame(pkg = todo[[1]], dep = dep)
    deps <- rbind(deps, new)
    todo <- setdiff(deps$dep, c(deps$pkg, NA))
  }
  
  # Filter out base packages if requested
  if (!base) {
    deps <- deps[!deps$dep %in% base_packages & !deps$pkg %in% base_packages, ]
  }
  
  # Remove NA dependencies
  deps <- deps[!is.na(deps$dep), ]
  
  # Handle packages with no dependencies if demote_nodep is TRUE
  if (demote_nodep) {
    nodep_pkgs <- setdiff(deps$dep, deps$pkg)
    deps2 <- aggregate(
      dep ~ pkg,
      data = deps[deps$dep %in% nodep_pkgs, ],
      FUN = function(x) paste("+", x, collapse = "\n")
    )
    deps2$pkg2 <- paste0(deps2$pkg, "\n", deps2$dep)
    deps$pkg2 <- deps2$pkg2[match(deps$pkg, deps2$pkg)]
    deps$dep2 <- deps2$pkg2[match(deps$dep, deps2$pkg)]
    deps$pkg <- ifelse(is.na(deps$pkg2), deps$pkg, deps$pkg2)
    deps$dep <- ifelse(is.na(deps$dep2), deps$dep, deps$dep2)
    deps <- deps[!deps$dep %in% nodep_pkgs, ]
  }
  
  # Generate nomnoml code with styling
  # Identify main packages (those originally requested)
  main_pkgs <- pkg
  
  # Extract original package names (before first \n) for main package detection
  deps$pkg_original <- sub("\\n.*$", "", deps$pkg)
  deps$dep_original <- sub("\\n.*$", "", deps$dep)
  
  # Identify leaf packages (dependencies that have no dependencies)
  if (demote_nodep) {
    # When demoting, we don't want any leaf styling (gray nodes)
    leaf_pkgs <- character(0)
  } else {
    leaf_pkgs <- setdiff(deps$dep, deps$pkg)
  }
  
  deps$pkg_styled <- ifelse(deps$pkg_original %in% main_pkgs, 
                           sprintf("[<main> %s]", deps$pkg),
                           sprintf("[<dependency> %s]", deps$pkg))
  deps$dep_styled <- ifelse(deps$dep_original %in% main_pkgs,
                           sprintf("[<main> %s]", deps$dep),
                           ifelse(deps$dep %in% leaf_pkgs,
                                  sprintf("[<leaf> %s]", deps$dep),
                                  sprintf("[<dependency> %s]", deps$dep)))
  
  code_lines <- sprintf("%s -> %s", deps$pkg_styled, deps$dep_styled)
  
  # Add custom styling header (using flow_view_deps pattern)
  nomnoml_setup <- c(
    "#direction: right",
    "#.main: visual=roundrect fill=#d9e1f2 align=center",
    "#.dependency: visual=roundrect fill=#fff2cc align=center",
    "#.leaf: visual=roundrect fill=#ededed align=center"
  )
  
  code <- paste(c(nomnoml_setup, code_lines), collapse = "\n")

  if (identical(out, "data")) {
    data <- data.frame(
      package = deps$pkg,
      dependency = deps$dep,
      code = code
    )
    return(data)
  }
  
  # Create flow diagram
  if (is.null(out)) {
    widget <- nomnoml::nomnoml(code)
    return(as_flow_diagram(widget, list(nodes = deps), code))
  } else {
    # Use existing save_nomnoml infrastructure
    out <- save_nomnoml(code, out)
    if (inherits(out, "htmlwidget")) {
      return(as_flow_diagram(out, list(nodes = deps), code))
    } else {
      return(invisible(out))
    }
  }
}

# packages with priority "base", hardcoded to avoid calling installed.packages()
base_packages <- c(
  "base", "compiler", "datasets", "graphics", "grDevices", "grid", "methods",
  "parallel", "splines", "stats", "stats4", "tcltk", "tools", "utils"
)
