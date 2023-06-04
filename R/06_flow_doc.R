# nocov start

#' Draw Flow Diagrams for an Entire Package
#'
#' @param pkg package name as a string, or `NULL` to signify currently developed package.
#' @param out path to html output, if left `NULL` a temp *html*
#'   file will be created and opened
#' @inheritParams flow_view
#' @return Returns `NULL` invisibly (called for side effects).
#' @export
flow_doc <- function(
  pkg = NULL,
  prefix = NULL,
  code = TRUE,
  narrow = FALSE,
  truncate = NULL,
  swap = TRUE,
  out = NULL,
  engine = c("nomnoml", "plantuml")) {
  ## preprocess arguments
  engine <- match.arg(engine)
  as_dots <- function(x) {
    f <- function(...) environment()$...
    do.call(f, as.list(x))
  }
  if (is.null(pkg)) {
    pkg <- read.dcf("DESCRIPTION")[,"Package"][[1]]
  }

  ## define pkgdown flags
  missing_out <- is.null(out)

  ## did we specify an output?
  if(missing_out) {
      ## default output
      out <- tempfile(fileext = ".html")
  }
  out <- here::here(out)

  ext <- sub("^.*?\\.(.*?)", "\\1", out)

  exported <- getNamespaceExports(pkg)

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

  if(ext == "md")  {
    rmd_header <- ''
  } else {
    rmd_header <- sprintf(paste(
      '---',
      'title: "%s"',
      'output:',
      '  html_document:',
      '    toc: true',
      '    toc_float: true',
      '---\n\n', sep="\n"), pkg)
  }

  cat(rmd_header, file = rmd_output)


  append_function_diagrams(
    title = "# Exported functions\n\n",
    progress_txt = "Building diagrams of exported functions\n",
    funs_split = exported_funs_split,
    out = rmd_output,
    ns = ns,
    path = path,
    exp_unexp = "exp",
    pkg = pkg,

    prefix = prefix,
    truncate = truncate,
    swap = swap,
    narrow = narrow,
    code = code,
    engine = engine)

  append_function_diagrams(
    title = "# Unexported functions\n\n",
    progress_txt = "Building diagrams of unexported functions\n",
    funs_split = unexported_funs_split,
    out = rmd_output,
    ns = ns,
    path = path,
    exp_unexp = "unexp",
    pkg = pkg,

    prefix = prefix,
    truncate = truncate,
    swap = swap,
    narrow = narrow,
    code = code,
    engine = engine)

  cat("knitting")

  rmarkdown::render(rmd_output, output_file = out, output_format = "html_document")

  if(missing_out) {
    browseURL(out)
  }

  invisible(NULL)
}




append_function_diagrams <- function(
  title,
  progress_txt,
  funs_split,
  out,
  ns,
  path,
  exp_unexp,
  pkg,
  ...) {
  if(!length(funs_split)) return(invisible(NULL))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Write  title
  cat(title, file = out, append = TRUE)

  ## setup progress bar
  pb = txtProgressBar(min = 0, max = length(unlist(funs_split)), initial = 0)
  stepi = 0
  cat(progress_txt)

  ## for every letter
  for(L in names(funs_split)) {

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Write letter title
    letter_title <- sprintf("## %s\n\n", L)
    cat(letter_title, file = out, append = TRUE)

    ## for every function of the letter group
    for(fun_chr in funs_split[[L]]) {

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
      cat(fun_title, file = out, append = TRUE)

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # function image

      ## build path to image
      out_tmp <- file.path(path, paste0(exp_unexp, "_", stepi, ".png"))

      ## does the function have a body ?
      if(!is.null(body(fun_val))) {
        ## draw to the file and write link to image
        capture.output(suppressMessages(
          flow_view(setNames(c(fun_val), fun_chr),  ..., out = out_tmp)))
        fun_img <- sprintf('![](%s_%s.png)\n\n', exp_unexp, stepi)
        cat(fun_img, file = out, append = TRUE)
      } else {
        ## write that the function doesn't have a body
        cat("`", fun_chr, "` doesn't have a body\n\n", sep="",
            file = out, append = TRUE)
      }

      ## for all nested functions
      for(i in seq_along(sub_funs)) {
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # subfunction title

        ## define and write the title
        sub_fun_val <- eval(sub_funs[[i]])
        sub_fun_chr <- names(sub_funs)[[i]]

        sub_fun_title <- sprintf("#### %s\n\n", sub_fun_chr)
        cat(sub_fun_title, file = out, append = TRUE)


        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # subfunction image

        ## is the nested function named ?
        if(grepl("^\\d+$", sub_fun_chr)) {
          ## name the function "function"
          sub_fun_chr <- "function"
        }

        ## build path to image
        out_tmp <- file.path(path, paste0(exp_unexp, "_", stepi,"_", i, ".png"))

        ## does the function have a body ?
        if(!is.null(body(sub_fun_val))) {
          ## draw to the file and write link to image
          capture.output(suppressMessages(
            flow_view(setNames(c(sub_fun_val), sub_fun_chr),  ..., out = out_tmp)))
          sub_fun_img <- sprintf('![](%s_%s_%s.png)\n\n', exp_unexp, stepi, i)
          cat(sub_fun_img, file = out, append = TRUE)
        } else {
          ## write that the function doesn't have a body
          cat("`", sub_fun_chr, "` doesn't have a body\n\n", sep="",
              file = out, append = TRUE)
        }

      }
    }
  }

  ## close progress bar
  close(pb)
}

# nocov end
