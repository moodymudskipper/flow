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


# function 2nd call commented (special comment)


# function with both calls commented


  # data <- flow_view(fun, prefix = "##", range = 2:4)
  # # flow_data(fun)
  # # dput2(data$nodes[1:4])
  # # dput2(data$edges)
  # expect_equal(
  #   data$nodes[1:4],
  #   data.frame(
  #     id = c(1, 2),
  #     block_type = c("standard", "return"),
  #     code_str = c("x <- x * 2;y <- x", ""),
  #     label = c("", ""),
  #     stringsAsFactors = FALSE))
  # expect_equal(
  #   data$edges,
  #   data.frame(
  #     from = 1,
  #     to = 2,
  #     edge_label = "",
  #     arrow = "->",
  #     stringsAsFactors = FALSE))


# have tests with break and next
# have tests with repeat an while
# have tests with code = NA and code = FALSE
# have test where if call and yes is dead end (add_data_from_if_block 118:119)
# have tests for other flow funs

#.break: visual=receiver fill=#ffc000 empty
#.next: visual=transceiver fill=#5b9bd5  empty

# covr::report()

#
# fun_if <- function(x){
#   ## com1
#   x <- 1
#   ## com2
#   x <- 2
#   x <- 2
#   if(x == 3) {
#     ## com3
#     x <- 3
#   }
#   x <- "foo"
#   ## com4
#   x <- 4
# }
#
# flow_data(fun_if)
#
#
# fun_if_else <- function(x){
#   ## com1
#   x <- 1
#   ## com2
#   x <- 2
#   x <- 2
#   if(x == 3) {
#     ## com3
#     x <- 3
#   } else {
#     x <- "bar"
#   }
#   x <- "foo"
#   ## com4
#   x <- 4
# }
#
# flow_data(fun_if_else, prefix = "##")
#
# fun_if_else_stop <- function(x){
#   if(TRUE) {
#     foo
#   } else {
#     stop("!!!!!")
#   }
#
#   if(TRUE) {
#     foo
#     return(bar)
#   } else {
#     baz
#   }
#   qux
# }
#
# flow_data(fun_if_else_stop)
#
#
#
# area <- function(radius, angle, check = TRUE){
#   if(check){
#     if(angle < 0 || angle > 2*pi){
#       stop("incorrect angle value")
#     } else {
#       print("good angle value")
#     }
#   }
#   radius_squared <- r^2
#   angle * radius_squared
# }
#
# flow_view(area)
#
# fun_for <- function(x){
#   for(elt in x) {
#     foo
#   }
# }
#
#
# flow_view(fun_for)
#
# fun_while <- function(x){
#   while(x) {
#     foo
#   }
# }
#
# flow_view(fun_while)
#
# fun_repeat <- function(x){
#   repeat {
#     foo
#   }
# }
#
# # issue with the last if (wrong link), these could be avoided by adding an empty elt
# # at the end of all cfc calls
# flow_view(fun_repeat)
#
#
#
#
#
#
# # modify function so that control flow constructs use `{...}` AND keep comments in srcref
#
# # I would like to modify an input function, so that the expressions always calls
# # `` `{`()``, and doing so, keep the comments at the right place. Here is an example :
#
# input_fun <- function(){
#
#   if(TRUE)
#     foo
#   else
#     ## bar_com1
#     ## bar_com2
#     bar({
#       x({y})
#     }) %in% z
#
#   ## if
#   if(
#     FALSE) {
#     this
#     ## baz_com
#     baz
#     that
#   }
#
#   repeat
#     while(condition)
#       ## qux_com
#       qux
# }
#
# flow_view(input_fun, prefix = "##")
#
#
#
# fun <- function(x){
#
#   ## comment 1
#   x <- x * 2
#
#   ## comment 2
#   if(x > 3)
#     print("big x!")
#   x
# }
#
# flow_view(fun, prefix = "##")
