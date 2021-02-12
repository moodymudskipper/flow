dput2 <- function(x,
                  name=as.character(substitute(x)),
                  multiline = TRUE,
                  n=if ('list' %in% class(x)) length(x) else nrow(x),
                  random=FALSE,
                  seed = 1){
  name
  if('tbl_df' %in% class(x)) create_fun <- "tibble::tibble" else
    if('list' %in% class(x)) create_fun <- "list" else
      if('data.table' %in% class(x)) create_fun <- "data.table::data.table" else
        create_fun <- "data.frame"

      if(random) {
        set.seed(seed)
        if(create_fun == "list") x <- x[sample(1:length(x),n)] else
          x <- x[sample(1:nrow(x),n),]
      } else {
        x <- head(x,n)
      }

      line_sep <- if (multiline) "\n    " else ""
      cat(sep='',name," <- ",create_fun,"(\n  ",
          paste0(unlist(
            Map(function(item,nm) paste0(nm,if(nm=="") "" else " = ",paste(capture.output(dput(item)),collapse=line_sep)),
                x,if(is.null(names(x))) rep("",length(x)) else names(x))),
            collapse=",\n  "),
          if(create_fun == "data.frame") ",\n  stringsAsFactors = FALSE)" else "\n)")
}
