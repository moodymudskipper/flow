# nocov start

#' Build Report From Tests
#'
#' Build a markdown report from test scripts, showing the paths taken in tested
#' functions, and where they fail if they do.
#' See also the vignette *"Build reports to document functions and unit tests"*.
#'
#' @param out path to html output, if left `NULL` a temp *html*
#'   file will be created and opened.
#' @param failed_only whether to restrict the report to failing tests only
#' @inheritParams flow_run
#'
#' @return Returns `NULL` invisibly (called for side effects)
#' @export
flow_test <- function(
    prefix = NULL,
    code = TRUE,
    narrow = FALSE,
    truncate = NULL,
    swap = TRUE,
    out = NULL,
    failed_only = FALSE) {
  scripts <- list.files(
    path = "tests/testthat",
    pattern = "\\.r$",
    ignore.case = TRUE,
    full.names = TRUE)

  ## create temp file
  tmp_dir <- tempdir()
  rmd_output <- tempfile(fileext = ".Rmd", tmpdir = tmp_dir)
  if(is.null(out)) {
    missing_output <- TRUE
    out <- tempfile(fileext = ".html")
  } else {
    missing_output <- FALSE
  }
  out <- here::here(out)


  ## fetch pkgname from root folder
  pkg <- basename(getwd())

  ## fetch names of all the package's functions
  all_funs <- as.character(lsf.str(asNamespace(pkg)))

  ## print header and library call to file
  cat(file = rmd_output, sprintf(
    '---
title: "{%s} Unit Test Report"
output: html_document
---

*Built with* [*{flow}*](https://moodymudskipper.github.io/flow/)

```{r, include = FALSE}
library(%s)
```
# {.tabset}

', pkg, pkg
  ))

  out <- normalizePath(out, mustWork = FALSE)

  ## create testthat envir so we can run the code without attaching testthat
  testthat_funs <- as.list(asNamespace("testthat"))[getNamespaceExports("testthat")]
  testthat_env  <- as.environment(testthat_funs)
  parent.env(testthat_env) <- .GlobalEnv

  ## create pkg envir so we can run the code without attaching it
  pkg_funs <- as.list(asNamespace(pkg))
  pkg_env  <- as.environment(pkg_funs)
  parent.env(pkg_env) <- testthat_env

  ## create a child envir of the latter where we'll execute our code
  e <- new.env(parent = pkg_env)

  n_test_that_calls <- sum(
    sapply(scripts, function(x) sum(all.names(parse(file = x)) == "test_that"))
  )

  ## setup progress bar
  pb = txtProgressBar(min = 0, max = n_test_that_calls, initial = 0)
  stepi = 0
  writeLines("generating unit test report")

  ## iterate through test scripts
  for(script in scripts) {
    i <- 0

    ## print name of script as title 2
    script_short <- sub("\\.R", "", basename(script))
    cat(file = rmd_output, sprintf("## %s\n\n", script_short), append = TRUE)

    calls <- parse(file = script)
    # call <- calls[[1]]

    ## iterate through calls in script
    for (call in calls) {
      if(!identical(call[[1]], quote(test_that))) {
        # we should save these calls and prefix next code with them
        eval(call, e)
      } else {

        find_pkg_fun_calls <- function(call, ind) {
          call <- call[[ind]]
          is.call(call) && is.symbol(call[[1]]) && as.character(call[[1]]) %in% all_funs
        }

        i2 <- numeric()
        inspected_funs <- character()

        wrap_call <- function(call, ind) {
          call <- call[[ind]]
          i <<- i + 1
          i2 <<- c(i2, i)
          inspected_funs <<- c(inspected_funs, as.character(call[[1]]))
          img_path <- sprintf("%s/%s_%s.png", tmp_dir, script_short, i)
          as.call(c(
            quote(flow::flow_run),
            call,
            prefix = prefix,
            code = code,
            narrow = narrow,
            truncate = truncate,
            swap = swap,
            out = img_path))
        }

        call_wrapped <- call_apply(
          call,
          find = find_pkg_fun_calls,
          replace = wrap_call
        )


        success <- eval_silent(call_wrapped, e)

        ## update progress bar
        stepi <- stepi + 1
        setTxtProgressBar(pb,stepi)


        if(!failed_only || !success) {
          #success <- if(success) "passed" else "failed"

          chunk_code <- paste(styler::style_text(robust_deparse(call)), collapse = "\n")
          desc <- eval(match.call(testthat::test_that, call)[["desc"]], e)

          if(success) {
            desc <- sprintf('<span style="color: green;">%s</span>', desc)
          } else {
            desc <- sprintf('<span style="color: red;">%s</span>', desc)
          }

          ## print test description as title 3
          cat(
            file = rmd_output,
            sprintf("### %s {.tabset}\n\n", desc),
            append = TRUE)

          ## print code as first title 4
          code_section <- sprintf("#### code\n\n```{r, eval = FALSE}\n%s\n```\n\n", chunk_code)
          cat(file = rmd_output, code_section, append = TRUE)

          img_paths <- sprintf("%s/%s_%s.png", tmp_dir, script_short, i2)
          # FIXME: not sure why some images are not produced

          inspected_funs <- inspected_funs[file.exists(img_paths)]
          img_paths <- img_paths[file.exists(img_paths)]

          if (length(img_paths)) {
            diagram_sections <- sprintf("#### %s\n\n![](%s)\n\n", inspected_funs, img_paths)
            cat(file = rmd_output, diagram_sections, append = TRUE, sep= "")
          }
        }
      }
    }
  }

  rmarkdown::render(rmd_output, output_file = out, quiet = TRUE)

  if(missing_output) {
    browseURL(out)
  }

  invisible(NULL)
}


call_apply <- function(call, find, replace = NULL, output = c("call", "list", "indices")) {
  output = match.arg(output)
  fun_bool <- is.function(call)
  if(fun_bool) {
    call_bkp <- call
    call <- body(call)
  }
  #~~~~~~~~~~~~~~~~~~~~
  # find

  if(!is.function(find))
    find <- as.function(c(
      alist(call=, ind=), bquote(identical(call[[ind]], quote(.(find))))))

  if(!is.null(replace) && !is.function(replace))
    replace <- as.function(c(
      alist(call=, ind=), bquote(quote(.(replace)))))

  fetch_indices <- function(ind) {
    # return ind if target was found
    if(find(call, ind = ind)) return(ind)
    # if call is not a call we're on a leaf, nothing else to do
    if(!is.call(call[[ind]])) return(NULL)
    # go through items and recurse with updated ind
    lapply(seq_along(call[[ind]]), function(i) fetch_indices(c(ind, i)))
  }
  # get sparse nested list
  indices <- lapply(seq_along(call), fetch_indices)
  # use rapply to flatten it, as.call necessary not to flatten vectors
  indices <- rapply(indices, function(x) as.call(c(quote(c), x)), how = "unlist")
  # eval items
  indices <- lapply(indices, eval)
  if(output == "indices") return(indices)

  #~~~~~~~~~~~~~~~~~~~~
  # replace
  if(output == "call") {
    res <- call
    for(ind in indices) {
      res[[ind]] <- replace(call, ind)
    }
    if(fun_bool) {
      body(call_bkp) <- res
      return(call_bkp)
    }
    return(res)
  }

  #~~~~~~~~~~~~~~~~~~~~~~
  # extract
  if(is.null(replace))
    replace <- as.function(c(
      alist(call=, ind=), quote(call[[ind]])))
  lapply(indices, function(ind) replace(call, ind))
}

eval_silent <- function(call, env = parent.frame()) {
  sink_file <- file(tempfile(), open = "w")
  sink(file = sink_file, type = "output")
  sink(file = sink_file, type = "message")
  on.exit({
    sink(type = "output")
    sink(type = "message")
  })
  suppressWarnings(!inherits(try(eval(call, env), silent = TRUE), "try-error"))
}

# nocov end
