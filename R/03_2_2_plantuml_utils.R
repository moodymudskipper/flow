
plantuml_skinparam <- "
skinparam ActivityBorderColor black
skinparam ActivityBackgroundColor #ededed
skinparam SequenceGroupBorderColor black
skinparam ActivityDiamondBorderColor black
skinparam ArrowColor black
"



build_elseif_txt <- function(expr, truncate) {
  ## flag if the expr is an `if` call
  is_elseif <-
    is.call(expr) && identical(expr[[1]], quote(`if`))
  ## is it ?
  if(is_elseif) {
    ## build elseif header code and yes code
    elseif_txt <- sprintf(
      "#e2efda:elseif (if(%s)) then (y)",
      paste(deparse_plantuml(expr[[2]], truncate), collapse= "\\n"))
    yes_txt <- build_plantuml_code(expr[[3]], truncate = truncate)
    ## is there an else clause ?
    if(length(expr) == 4) {
      ## recurse to build else code, and paste codes
      txt <- paste(elseif_txt, yes_txt, build_elseif_txt(expr[[4]], truncate), sep = "\n")
    } else {
      ##  paste codes
      txt <- paste(elseif_txt, yes_txt, sep = "\n")
    }
  } else {
    ## build else code
    else_txt <- "else (n)"
    no_txt <-  build_plantuml_code(expr, truncate = truncate)
    txt <- paste(else_txt, no_txt, sep = "\n")
  }
  ## return the code
  txt
}

# deparse an expression to a correctly escaped character vector
deparse_plantuml <- function(x, truncate) {
  ## deparse to a string
  x <- robust_deparse(x)
  ## format using styler
  x <- styler::style_text(x)

  ## truncate if relevant
  if(!is.null(truncate))  {
    x <- ifelse(
      nchar(x) > truncate,
      paste(substr(x, 1, truncate-3),"..."),
      x)
  }
  ## replace plantuml special characters with <U+*> syntax
  chars <- c("\\[","\\]","~","\\.","\\*","_","\\-",'"', "<", ">", "&", "\\\\")
  x <- to_unicode(x, chars) #

  ## collapse
  x <- paste(x, collapse = "\\n")
  x
}

to_unicode <- function(x, chars = character()) {
  ## should we replace only given chars ?
  if(length(chars)) {
    ## replace recursively the matches
    m <- gregexpr(paste(chars, collapse="|"), x)
    regmatches(x, m) <- lapply(regmatches(x, m), to_unicode)
    return(x)
  }
  ## convert all chars to <U+*> syntax
  x <- ifelse(Encoding(x) != 'UTF-8', enc2utf8(enc2native(x)), x)
  bytes <- iconv(x, "UTF-8", "UTF-32BE", toRaw=TRUE)
  byte_to_unicode <- function(x) paste(sprintf(
    "<U+%s%s>", x[c(FALSE, FALSE, TRUE, FALSE)], x[c(FALSE, FALSE, FALSE, TRUE)]),
    collapse = "")
  vapply(bytes, FUN.VALUE = character(1), byte_to_unicode)
}
