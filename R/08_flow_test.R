
#' build report from tests
#'
#' @param out path to output (`.html` or `.md`)
#' @param failed_only whether to restrict the report to failing tests only
#'
#' @return
#' @export
#'
#' @examples
flow_test <- function(out = "tests.html", failed_only = FALSE) {
  scripts <- list.files(
    path = "tests/testthat",
    pattern = "\\.r$",
    ignore.case = TRUE,
    full.names = TRUE)

  ## create temp file
  tmp_dir <- tempdir()
  rmd_output <- tempfile(fileext = ".Rmd", tmpdir = tmp_dir)

  ## fetch pkgname from root folder
  pkg <- basename(getwd())

  ## fetch names of all the package's functions
  all_funs <- as.character(lsf.str(asNamespace(pkg)))

  ## print header and library call to file
  cat(file = rmd_output, sprintf(
    '---
title: "Test diagrams"
date: "`r Sys.Date()`"
output: html_document
---

```{r, include = FALSE}
library(%s)
```
# Test report {.tabset}

', pkg
  ))

  # script <- scripts[[5]]

  e <- new.env(parent = .GlobalEnv)

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
          call("flow_run", call, out = img_path)
        }

        # ## run the call
        # eval(call2, e)
        #
        call_wrapped <- call_apply(
          call,
          find = find_pkg_fun_calls,
          replace = wrap_call
          # ,
          # output = "list"
        )

        success <- eval(call_wrapped, e)

        if(!failed_only || !sucess) {
        success <- if(success) "passed" else "failed"

        code <- paste(styler::style_text(deparse(call)), collapse = "\n")
        desc <- eval(match.call(testthat::test_that, call)[["desc"]], e)

        ## print test description as title 3
        cat(
          file = rmd_output,
          sprintf("### %s (%s) {.tabset}\n\n", desc, success),
          append = TRUE)

        ## print code as first title 4
        code_section <- sprintf("#### code\n\n```{r}\n%s\n```\n\n", code)
        cat(file = rmd_output, code_section, append = TRUE)


        diagram_sections <- sprintf(
          "#### %s\n\n![](%s/%s_%s.png)\n\n", inspected_funs, tmp_dir, script_short, i2)
        }


        cat(file = rmd_output, diagram_sections, append = TRUE, sep= "")
      }
    }
  }

  rmarkdown::render(rmd_output, output_file = out)
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
