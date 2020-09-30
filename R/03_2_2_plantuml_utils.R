
plantuml_skinparam <- "
skinparam ActivityBorderColor black
skinparam ActivityBackgroundColor #ededed
skinparam SequenceGroupBorderColor black
skinparam ActivityDiamondBorderColor black
skinparam ArrowColor black
"



build_elseif_txt <- function(expr) {
  is_elseif <-
    is.call(expr) && identical(expr[[1]], quote(`if`))
  if(is_elseif) {
    elseif_txt <- sprintf(
      "#e2efda:elseif (if(%s)) then (y)",
      paste(deparse_plantuml(expr[[2]]), collapse= "\\n"))
    yes_txt <- build_plantuml_code(expr[[3]])
    if(length(expr) == 4)
      txt <- paste(elseif_txt, yes_txt, build_elseif_txt(expr[[4]]), sep = "\n")
    else {
      txt <- paste(elseif_txt, yes_txt, sep = "\n")
    }
  } else {
    else_txt <- "else (n)"
    no_txt <-  build_plantuml_code(expr)
    txt <- paste(else_txt, no_txt, sep = "\n")
  }
  txt
}

# deparse an expression to a correctly escaped character vector
deparse_plantuml <- function(x) {
  x <- paste(deparse(x, backtick = TRUE),collapse = "\n")
  x <- styler::style_text(x)
  chars <- c("\\[","\\]","~","\\.","\\*","_","\\-",'"', "<", ">", "&", "\\\\")
  x <- to_unicode(x, chars) #
  x <- paste(x, collapse = "\\n")
  x
}

to_unicode <- function(x, chars = character()) {
  if(length(chars)) {
    # if chars is given, replace recursively the matches
    m <- gregexpr(paste(chars, collapse="|"), x)
    regmatches(x, m) <- lapply(regmatches(x, m), to_unicode)
    return(x)
  }
  # encode all to UTF-8
  x <- ifelse(Encoding(x) != 'UTF-8', enc2utf8(enc2native(x)), x)
  bytes <- iconv(x, "UTF-8", "UTF-32BE", toRaw=TRUE)
  vapply(bytes, FUN.VALUE = character(1), function(x) paste(sprintf(
    "<U+%s%s>", x[c(FALSE, FALSE, TRUE, FALSE)], x[c(FALSE, FALSE, FALSE, TRUE)]),
    collapse = ""))
}
