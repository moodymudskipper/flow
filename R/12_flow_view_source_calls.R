extract_strings <- function(call) {
  rec <- function(call) {
    if(!is.call(call)) return(call) else lapply(call, rec)
  }
  unlist(Filter(is.character,unlist(rec(call))))
}

#' Draw diagram of source dependencies
#'
#' Assuming a project where files source each other, draw their dependency graph.
#'
#' This evaluates the `file` argument of `source` in the global environment,
#' when this fails, as it might with constructs like `for (file in files) source(file)`
#' the unevaluated argument is printed instead between backticks. Since this messes
#' up the relationships in the graph, an warning is thus issued. In a case like `source(file.path(my_dir, "foo.R"))`
#' defining `my_dir` will be enough to solve the issue.
#' In the latter case, if `smart` is `TRUE`, the function will check in all the paths in scope
#' if any script is named "foo.R" and will consider it if a single fitting candidate is found.
#'
#' `c(c(1)`
#' `c(c(1))`
#'
#' @param paths Paths to scripts or folders containing scripts
#'   By default explores the working directory.
#' @param recursive Passed to `list.files()` when `paths` contains directories
#' @param basename Whether to display only the base name of the script
#' @param extension Whether to display the extension
#' @param smart Whether to parse complex source calls for strings that look like script and
#'   match those to files found in `paths`
#' @inheritParams flow_view
#'
#' @return `flow_view_source_calls()` returns a `"flow_diagram"` object by default, and the output path invisibly if `out` is not
#' `NULL` (called for side effects). `flow_run()` returns the output of the wrapped call.
#' @export
flow_view_source_calls <- function(paths = ".", recursive = TRUE, basename = TRUE, extension = FALSE, smart = TRUE, out = NULL) {
  paths <- flatten_paths(paths)
  svg <- is.null(out) || endsWith(out, ".html") || endsWith(out, ".html")
  env <- parent.frame()
  fetch_source <- function(file) {
    code <- as.list(parse(file))
    # FIXME: not only looking at the top level, recurse into code to find the calls
    source_calls <- Filter(function(x) is.call(x) && (
      identical(x[[1]], quote(source)) ||
        identical(x[[1]], quote(sourceDirectory)) ||
        identical(x[[1]], call("::", quote(R.utils), quote(sourceDirectory)))) ,
      code
    )
    if (!length(source_calls)) return(NULL)
    # attempt to eval the second argument
    paths <- sapply(source_calls, function(x) {
      tryCatch({
        # if we can eval, format and use
        file <- eval(x[[2]], env)
        # if we used sourceDirectory fetch all paths
        if (!identical(x[[1]], quote(source))) {
          file <- scripts_from_sourceDir(path = file, call = x, env = env)
        }
        basename_extension(file, basename, extension)
      },
      error = function(e) {
        # If we can't eval, check if it contains a path,
        #   as in file.path(foo, "bar.R") for instance
        if (smart) {
          strings <- extract_strings(x)
          file <- grep("\\.[rR]$", strings, value = TRUE)
          if(length(file) == 1) {
            # find if we have a matching file in paths and if so, format and use
            file <- paths[basename(file) == basename(paths)]
            if (length(file) == 1) {
              return(basename_extension(file, basename, extension))
            }
          } else {
            folder <- strings[strings == basename(dirname(paths))]
            if (length(folder) == 1) {
              files <- scripts_from_sourceDir(path = folder, call = x, env = env)
              return(basename_extension(files, basename, extension))
            }
          }
        }
        #"UNKNOWN"
        paste0("`", paste(deparse(x[[2]]), collapse = " "), "`")
      }
      )
    })
    data.frame(parent = file, child = paths)
  }

  graph <- do.call(rbind, lapply(paths, fetch_source))
  if (is.null(graph)) {
    message("The selected files don't use `source()`")
    return(invisible(NULL))
  }

  if (basename) graph$parent <- basename(graph$parent)
  if (!extension)  graph$parent <- sub("\\.[rR]$", "", graph$parent)

  # give useful warning for unevaled source
  # not clean but will do for now
  unevaled <- unique(graph$child[startsWith(graph$child, "`")])
  if (length(unevaled)) {
    calls <- parse(text = substr(unevaled, 2, nchar(unevaled)- 1))
    calls <- lapply(as.list(calls), remove_namespaced_calls)
    all_names <- unique(unlist(lapply(calls, all.names)))
    non_existent <- Filter(function(x) ! exists(x, .GlobalEnv), all_names)
    warning(paste0(
      "Some `file` arguments in `source()` calls could not be evaluated, ",
      "because some objects could not be found:\n",
      toString(paste0("`", non_existent, "`"))))
  }
  if (identical(out, "data")) return(graph)

  nomnoml_code <- c("#direction: right", sprintf("[%s] -> [%s]", graph$parent, graph$child))
  nomnoml_code <- paste(nomnoml_code, collapse = "\n")
  if (identical(out, "code")) return(nomnoml_code)
  out <- save_nomnoml(nomnoml_code, out)
  if (inherits(out, "htmlwidget"))
    as_flow_diagram(out, data = graph, code = nomnoml_code)
  else invisible(out)
}

flatten_paths <- function (paths, recursive = TRUE) {
  paths_are_dirs <- sapply(paths, dir.exists)
  dirs <- paths[paths_are_dirs]
  paths_from_dirs <- unlist(lapply(dirs, list.files, recursive = recursive,
                                   pattern = "\\.[rR]$", full.names = TRUE))
  paths <- c(paths[!paths_are_dirs], paths_from_dirs)
  paths
}

scripts_from_sourceDir <- function(path, call, env) {
  matched_call <- match.call(
    function(path, pattern, recursive, envir, onError, modifiedOnly, ..., verbose) {},
    call
  )
  recursive <- tryCatch(
    eval(matched_call$recursive, env),
    error = function(e) TRUE
  ) %||% TRUE

  pattern <- tryCatch(
    eval(matched_call$pattern, env),
    error = function(e) ".*[.](r|R|s|S|q)([.](lnk|LNK))*$"
  ) %||% ".*[.](r|R|s|S|q)([.](lnk|LNK))*$"

  path <- list.files(path, pattern = pattern, recursive = recursive)
  path
}

basename_extension <- function(x, basename, extension) {
  if (basename) x <- basename(x)
  if (!extension) x <- sub("\\.[rR]$", "", x)
  x
}
