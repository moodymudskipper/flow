


#' Draw Flow Diagrams for an Entire Package
#'
#' @param pkg package name as a string
#' @param out path to an html file to write to
#' @inheritParams flow_view
#' @details
#' if `pkg` and `out` are left `NULL`, a vignette `diagrams.md` will be built
#' in the root, so that `pkgdown::build_site` will use it as an additional page.
#' @export
flow_doc <- function(pkg = NULL, out = NULL, prefix = NULL, truncate = NULL,
                     swap = TRUE, narrow = FALSE, code = TRUE, svg = FALSE,
                     engine = c("nomnoml", "plantuml"), engine_opts = getOption("flow.engine_opts")) {
  ## preprocess arguments
  engine <- match.arg(engine)
  as_dots <- function(x) {
    f <- function(...) environment()$...
    do.call(f, as.list(x))
  }
  `...` <- as_dots(list(prefix = prefix, truncate = truncate,
                        swap = swap, narrow = narrow, code = code, svg = svg,
                        engine = engine, engine_opts = engine_opts))

  ## define pkgdown flag
  pkgdown <- is.null(pkg)

  ## did we specify an output?
  if(is.null(out)) {
    ## did we specify a package?
    if(pkgdown) {
      ## output so pkgdown::build_site will add report on new page on website
      out <- "diagrams.md"
    } else {
      ## default output
      out <- paste0(pkg, ".html")
    }
  }

  ## fetch lists of exported and uneported functions from package

  ## did we specify a package?
  if(pkgdown) {
    ## guess pkg from working dir and exported funs from NAMESPACE
    pkg <- basename(getwd())
    exported <- gsub("export\\((.*?)\\)", "\\1", grep("^export", readLines("NAMESPACE"), value = TRUE))
  } else {
    ## fetch exported functions
    exported <- getNamespaceExports(pkg)
  }

  ## discard reexported funs from other NS and split into exp and unexp
  all_funs <- lsf.str(asNamespace(pkg))
  exported_funs <- intersect(all_funs, exported)
  unexported_funs <- setdiff(all_funs, exported_funs)

  ## split those lists by first letter
  f <- toupper(substr(exported_funs,1,1))
  f[! f %in% LETTERS] <- "-"
  exported_funs_split <-split(exported_funs, f)
  f <- toupper(substr(unexported_funs,1,1))
  f[! f %in% LETTERS] <- "-"
  unexported_funs_split <- split(unexported_funs, f)

  ## create a temp folder and location for rmd and intermediate files
  path <- file.path(tempdir(), pkg)
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  # this won't trigger a cmd check note
  rmd_output <- file.path(path, "test.Rmd")
  ns <- asNamespace(pkg)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Write Rmd header

    if(pkgdown)  {
      rmd_header <- '*This page was built using the [{flow}](https://moodymudskipper.github.io/flow/) package*\n\n'
    } else {
      rmd_header <- sprintf('---
title: "%s"
output:
  html_document:
    toc: true
    toc_float: true
---

', pkg)
    }

  cat(rmd_header, file = rmd_output)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Write "Exported functions" title
  # Title Exported
  title_exported <- "# Exported functions\n\n"
  cat(title_exported, file = rmd_output, append = TRUE)

  ## setup progress bar
  pb = txtProgressBar(min = 0, max = length(exported_funs), initial = 0)
  stepi = 0
  cat("Building diagrams of exported functions\n")

  ## for every letter
  for(L in names(exported_funs_split)) {


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Write letter title
    letter_title <- sprintf("## %s\n\n", L)
    cat(letter_title, file = rmd_output, append = TRUE)

    ## for every function of the letter group
    for(fun_chr in exported_funs_split[[L]]) {

      ## fetch function value and subfunctions
      stepi <- stepi + 1
      setTxtProgressBar(pb,stepi)

      fun_lng <- str2lang(sprintf("%s::`%s`", pkg, fun_chr))
      fun_val <- get(fun_chr, envir = ns)
      sub_funs <- find_funs(body(fun_val))
      names(sub_funs) <- ifelse(
        names(sub_funs) == "",
        seq_along(sub_funs),
        names(sub_funs)
      )
      has_subfuns <- length(sub_funs) > 0

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # function title

      ## is there nested function definitions ?
      if(has_subfuns) {
        ## build function title including tabset
        fun_title <- sprintf('### %s {.tabset}\n\n#### %s\n\n', fun_chr, fun_chr)
      } else {
        ## build function title
        fun_title <- sprintf("### %s\n\n", fun_chr)
      }

      ## write function title
      cat(fun_title, file = rmd_output, append = TRUE)

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # function image

      ## build path to image
      out_tmp <- file.path(path, paste0("exp_", stepi, ".png"))

      ## does the function have a body ?
      if(!is.null(body(fun_val))) {
        ## draw to the file and write link to image
        capture.output(suppressMessages(
          flow_view(setNames(c(fun_val), fun_chr),  ..., out = out_tmp)))
        fun_img <- sprintf('![](exp_%s.png)\n\n', stepi)
        cat(fun_img, file = rmd_output, append = TRUE)
      } else {
        ## write that the function doesn't have a body
        cat("`", fun_chr, "` doesn't have a body\n\n", sep="",
            file = rmd_output, append = TRUE)
      }

      ## for all nested functions
      for(i in seq_along(sub_funs)) {
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # subfunction title

        ## define and write the title
        sub_fun_val <- eval(sub_funs[[i]])
        sub_fun_chr <- names(sub_funs)[[i]]

        sub_fun_title <- sprintf("#### %s\n\n", sub_fun_chr)
        cat(sub_fun_title, file = rmd_output, append = TRUE)

        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # subfunction image

        ## is the nested function named ?
        if(grepl("^\\d+$", sub_fun_chr)) {
          ## name the function "function"
          sub_fun_chr <- "function"
        }

        ## build path to image
        out_tmp <- file.path(path, paste0("exp_", stepi,"_", i, ".png"))

        ## does the function have a body ?
        if(!is.null(body(sub_fun_val))) {
          ## draw to the file and write link to image
          capture.output(suppressMessages(
            flow_view(setNames(c(sub_fun_val), sub_fun_chr),  ..., out = out_tmp)))
          sub_fun_img <- sprintf('![](exp_%s_%s.png)\n\n', stepi, i)
          cat(sub_fun_img, file = rmd_output, append = TRUE)
        } else {
          ## write that the function doesn't have a body
          cat("`", sub_fun_chr, "` doesn't have a body\n\n", sep="",
              file = rmd_output, append = TRUE)
        }

      }
      #nc <- nchar(fun_chr)
    }
  }

  ## close progress bar
  close(pb)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Title Unexported
  title_unexported <- "# Unexported functions\n\n"
  cat(title_unexported, file = rmd_output, append = TRUE)

  pb = txtProgressBar(min = 0, max = length(exported_funs), initial = 0)
  stepi = 0
  cat("Building diagrams of unexported functions\n")

  for(L in names(unexported_funs_split)) {

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Letter title
    letter_title <- sprintf("## %s\n\n", L)
    cat(letter_title, file = rmd_output, append = TRUE)

    for(fun_chr in unexported_funs_split[[L]]) {
      stepi <- stepi + 1
      setTxtProgressBar(pb,stepi)

      fun_lng <- str2lang(sprintf("%s::`%s`", pkg, fun_chr))
      fun_val <- get(fun_chr, envir = ns)
      sub_funs <- find_funs(body(fun_val))
      names(sub_funs) <- ifelse(
        names(sub_funs) == "",
        seq_along(sub_funs),
        names(sub_funs)
      )
      has_subfuns <- length(sub_funs) > 0

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # function title

      if(has_subfuns)
        fun_title <- sprintf('### %s {.tabset}\n\n#### %s\n\n', fun_chr, fun_chr)
      else
        fun_title <- sprintf("### %s\n\n", fun_chr)

      cat(fun_title, file = rmd_output, append = TRUE)

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # function image

      out_tmp <- file.path(path, paste0("unexp_", stepi, ".png"))
      if(!is.null(body(fun_val))) {
        capture.output(suppressMessages(
          flow_view(setNames(c(fun_val), fun_chr),  ..., out = out_tmp)))
        fun_img <- sprintf('![](unexp_%s.png)\n\n', stepi)
        cat(fun_img, file = rmd_output, append = TRUE)
      } else {
        cat("`", fun_chr, "` doesn't have a body\n\n", sep="",
            file = rmd_output, append = TRUE)
      }

      for(i in seq_along(sub_funs)) {
        sub_fun_val <- eval(sub_funs[[i]])
        sub_fun_chr <- names(sub_funs)[[i]]

        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # subfunction title
        sub_fun_title <- sprintf("#### %s\n\n", sub_fun_chr)
        cat(sub_fun_title, file = rmd_output, append = TRUE)

        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # subfunction image
        if(grepl("^\\d+$", sub_fun_chr)) sub_fun_chr <- "function"
        out_tmp <- file.path(path, paste0("unexp_", stepi,"_", i, ".png"))

        if(!is.null(body(sub_fun_val))) {
          capture.output(suppressMessages(
            flow_view(setNames(c(sub_fun_val), sub_fun_chr),  ..., out = out_tmp)))
          sub_fun_img <- sprintf('![](unexp_%s_%s.png)\n\n', stepi, i)
          cat(sub_fun_img, file = rmd_output, append = TRUE)
        } else {
          cat("`", sub_fun_chr, "` doesn't have a body\n\n", sep="",
              file = rmd_output, append = TRUE)
        }

      }
    }
  }
  close(pb)

  cat("knitting")
  out <- suppressWarnings(normalizePath(out, winslash = "/"))
  rmarkdown::render(rmd_output, output_file = out)
  if(pkgdown) {
    # remove the "<!DOCTYPE html>" line
    writeLines(readLines(out)[-1], out)
  }
  invisible(NULL)
}

