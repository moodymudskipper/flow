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


#### NO CONTROL FLOW ####

## empty function

test_that("flow_data works with empty fun",{
  fun <- function(x) {}
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  data <- flow_data(fun)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "standard", "return"),
      code_str = c("fun(x)", "", ""),
      label = c("", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1),
      to = c(1, 2),
      edge_label = c("", ""),
      arrow = c("->", "->"),
      stringsAsFactors = FALSE))
})


# function with one symbol

test_that("flow_data works with one symbol in body",{
  fun <- function(x) {x}
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  data <- flow_data(fun)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "standard", "return"),
      code_str = c("fun(x)", "x", ""),
      label = c("", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1),
      to = c(1, 2),
      edge_label = c("", ""),
      arrow = c("->", "->"),
      stringsAsFactors = FALSE))
})

# function with one call
test_that("flow_data works with one call in body",{
  fun <- function(x) {x + y}
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  data <- flow_data(fun)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "standard", "return"),
      code_str = c("fun(x)", "x + y", ""),
      label = c("", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1),
      to = c(1, 2),
      edge_label = c("", ""),
      arrow = c("->", "->"),
      stringsAsFactors = FALSE))
})

# function with 2 calls
test_that("flow_data works with 2 calls in body",{
  fun <- function(x) {
    x + y
    u + v
    }
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  data <- flow_data(fun)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "standard", "return"),
      code_str = c("fun(x)", "x + y;u + v", ""),
      label = c("", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1),
      to = c(1, 2),
      edge_label = c("", ""),
      arrow = c("->", "->"),
      stringsAsFactors = FALSE))
})

# function 2nd call commented (special comment)


# function with both calls commented

#### IF ####

# simple if call without else and empty body
test_that("flow_data works with simple if and empty body",{
  fun <- function(x) {
    if(x) {}
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "if", "standard", "end", "return"),
      code_str = c("fun(x)", "if (x)", "", "", ""),
      label = c("", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, -1),
      to = c(1, 2, -1, -1, 3),
      edge_label = c("", "y", "", "n", ""),
      arrow = c("->", "->", "->", "->", "->"),
      stringsAsFactors = FALSE))
})

# simple if call without else and a symbol in body
test_that("flow_data works with simple if",{
  fun <- function(x) {
    if(x) foo
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "if", "standard", "end", "return"),
      code_str = c("fun(x)", "if (x)", "foo", "", ""),
      label = c("", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, -1),
      to = c(1, 2, -1, -1, 3),
      edge_label = c("", "y", "", "n", ""),
      arrow = c("->", "->", "->", "->", "->"),
      stringsAsFactors = FALSE))
})

# simple if else call
test_that("flow_data works with simple if else",{
  fun <- function(x) {
    if(x) foo else bar
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, 3, -1, 4),
      block_type = c("header", "if", "standard", "standard", "end", "return"),
      code_str = c("fun(x)", "if (x)", "foo", "bar", "", ""),
      label = c("", "", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, 3, -1),
      to = c(1, 2, -1, 3, -1, 4),
      edge_label = c("", "y", "", "n", "", ""),
      arrow = c("->", "->", "->", "->", "->", "->"),
      stringsAsFactors = FALSE))
})
# simple if else call without else and a symbol in body
# simple if else call without else and a call in body
# simple if else call without else and 2 calls in body

# if else call returning on the left
test_that("flow_data works returning on the yes branch",{
  fun <- function(x) {
    if(x) return(foo) else bar
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
        id = c(0, 1, 2, -2, 3, -1, 4),
        block_type = c("header", "if", "standard", "return", "standard", "end", "return"),
        code_str = c("fun(x)", "if (x)", "return(foo)", "", "bar", "", ""),
        label = c("", "", "", "", "", "", ""),
        stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
      data.frame(
        from = c(0, 1, 2, 1, 3, -1),
        to = c(1, 2, -2, 3, -1, 4),
        edge_label = c("", "y", "", "n", "", ""),
        arrow = c("->", "->", "->", "->", "->", "->"),
        stringsAsFactors = FALSE))
})


# if else call stopping on the right
test_that("flow_data works stopping on the no branch",{
    fun <- function(x) {
      if(x) foo else stop(bar)
    }
    data <- flow_data(fun)
    # flow_data(fun)
    # dput2(data$nodes[1:4])
    # dput2(data$edges)
    expect_equal(
      data$nodes[1:4],
      data.frame(
        id = c(0, 1, 2, 3, -3, -1, 4),
        block_type = c("header", "if", "standard", "standard", "stop", "end", "return"),
        code_str = c("fun(x)", "if (x)", "foo", "stop(bar)", "", "", ""),
        label = c("", "", "", "", "", "", ""),
        stringsAsFactors = FALSE))
      expect_equal(
        data$edges,
        data.frame(
          from = c(0, 1, 2, 1, 3, -1),
          to = c(1, 2, -1, 3, -3, 4),
          edge_label = c("", "y", "", "n", "", ""),
          arrow = c("->", "->", "->", "->", "->", "->"),
          stringsAsFactors = FALSE))
  })
# if else call stopping on the left AND returning on the right
test_that("flow_data works stopping on the yes branch and returning on the right branch",{
  fun <- function(x) {
    if(x) stop(foo) else return(bar)
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -2, 3, -3, 4),
      block_type = c("header", "if", "standard", "stop", "standard", "return", "return"),
      code_str = c("fun(x)", "if (x)", "stop(foo)", "", "return(bar)", "", ""),
      label = c("", "", "", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, 3),
      to = c(1, 2, -2, 3, -3),
      edge_label = c("", "y", "", "n", ""),
      arrow = c("->", "->", "->", "->", "->"),
      stringsAsFactors = FALSE))
})

# simple if call with a nested if else call
test_that("flow_data works with nested if calls",{
  fun <- function(x) {
    if(x) if(y) foo else bar
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, 3, 4, -2, -1, 5),
      block_type = c("header", "if", "if", "standard", "standard", "end", "end", "return"
      ),
      code_str = c("fun(x)", "if (x)", "if (y)", "foo", "bar", "", "", ""),
      label = c("", "", "", "", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 3, 2, 4, -2, 1, -1),
      to = c(1, 2, 3, -2, 4, -2, -1, -1, 5),
      edge_label = c("", "y", "y", "", "n", "", "", "n", ""),
      arrow = c("->", "->", "->", "->", "->", "->", "->", "->", "->"),
      stringsAsFactors = FALSE))
})

#### FOR ####
# empty for loop
test_that("flow_data works with an empty  for loop",{
  fun <- function(x) {
    for(x in foo) {}
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "for", "standard", "start", "return"),
      code_str = c("fun(x)", "for (x in foo)", "", "", ""),
      label = c("", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, -1),
      to = c(1, 2, -1, -1, 3),
      edge_label = c("", "", "", "next", ""),
      arrow = c("->", "->", "->", "<-", "->"),
      stringsAsFactors = FALSE))
})

# simple for loop
test_that("flow_data works with simple for loop",{
  fun <- function(x) {
    for(x in foo) x
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "for", "standard", "start", "return"),
      code_str = c("fun(x)", "for (x in foo)", "x", "", ""),
      label = c("", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 1, -1),
      to = c(1, 2, -1, -1, 3),
      edge_label = c("", "", "", "next", ""),
      arrow = c("->", "->", "->", "<-", "->"),
      stringsAsFactors = FALSE))
})

# if else call with for loops on each side
test_that("flow_data works with simple for loop",{
  fun <- function(x) {
    if(foo)
      for(x in bar) baz
    else
      for(x in qux) quux
  }
  data <- flow_data(fun)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, 3, -2, 4, 5, -4, -1, 6),
      block_type = c("header", "if", "for", "standard", "start", "for", "standard", "start",
                     "end", "return"),
      code_str = c("fun(x)", "if (foo)", "for (x in bar)", "baz", "", "for (x in qux)",
                   "quux", "", "", ""),
      label = c("", "", "", "", "", "", "", "", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 3, 2, -2, 1, 4, 5, 4, -4, -1),
      to = c(1, 2, 3, -2, -2, -1, 4, 5, -4, -4, -1, 6),
      edge_label = c("", "y", "", "", "next", "", "n", "", "", "next", "", ""),
      arrow = c("->", "->", "->", "->", "<-", "->", "->", "->", "->", "<-",
                "->", "->"),
      stringsAsFactors = FALSE))
})


test_that("sub_fun_id works",{
  fun <- function(x) {
    x <- x*2
    fun1 <- function(y) y
    fun2 <- function(z) z
    x
  }
  expect_message(flow_data(fun))
  data <- flow_data(fun, sub_fun_id = 2)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "standard", "return"),
      code_str = c("fun(z)", "z", ""),
      label = c("", "", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1),
      to = c(1, 2),
      edge_label = c("", ""),
      arrow = c("->", "->"),
      stringsAsFactors = FALSE))
})

test_that("package works on calls",{
  call <- quote({
    x <- x*2
    y <- x
  })
  data <- flow_data(call)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(1, 2),
      block_type = c("standard", "return"),
      code_str = c("x <- x * 2;y <- x", ""),
      label = c("", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = 1,
      to = 2,
      edge_label = "",
      arrow = "->",
      stringsAsFactors = FALSE))
})

test_that("package works on paths",{
  tmp <- tempfile(fileext=".R")
  write("x <- x*2\ny <- x", tmp)
  data <- flow_data(tmp)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(1, 2),
      block_type = c("standard", "return"),
      code_str = c("x <- x * 2;y <- x", ""),
      label = c("", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = 1,
      to = 2,
      edge_label = "",
      arrow = "->",
      stringsAsFactors = FALSE))
})

test_that("flow_data fails if incorrect input", {
  expect_error(flow_data(1), "must be a function")
})

test_that("flow_data works with prefixed comments",{
  fun <- function(x) {
    ## comment
    x}
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  data <- flow_data(fun, prefix = "##")
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "standard", "return"),
      code_str = c("fun(x)", "x", ""),
      label = c("", "comment", ""),
      stringsAsFactors = FALSE))
  expect_equal(
    data$edges,
    data.frame(
      from = c(0, 1),
      to = c(1, 2),
      edge_label = c("", ""),
      arrow = c("->", "->"),
      stringsAsFactors = FALSE))
})



test_that("package works with range arg",{
  fun <- function(x){
    ## section 1
    x <- x*2
    ## section 2
    x <- x*2
    ## section 3
    x <- x*2
    ## section 4
    x <- x*2
  }
  data <- flow_data(fun, prefix = "##", range = 1:3)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equivalent(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, 3, 5),
      block_type = c("header", "standard", "standard", "standard", "header"),
      code_str = c("fun(x)", "x <- x * 2", "x <- x * 2", "x <- x * 2", "..."),
      label = c("", "section 1", "section 2", "section 3", ""),
      stringsAsFactors = FALSE))
  expect_equivalent(
    data$edges,
    data.frame(
      from = c(0, 1, 2, 3),
      to = c(1, 2, 3, 5),
      edge_label = c("", "", "", ""),
      arrow = c("->", "->", "->", "--:>"),
      stringsAsFactors = FALSE))

  data <- flow_data(fun, prefix = "##", range = 2:3)
  # flow_data(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equivalent(
    data$nodes[1:4],
    data.frame(
      id = c(0, 2, 3, 5),
      block_type = c("header", "standard", "standard", "header"),
      code_str = c(". . .", "x <- x * 2", "x <- x * 2", "..."),
      label = c("", "section 2", "section 3", ""),
      stringsAsFactors = FALSE))
  expect_equivalent(
    data$edges,
    data.frame(
      from = c(0, 2, 3),
      to = c(2, 3, 5),
      edge_label = c("", "", ""),
      arrow = c("--:>", "->", "--:>"),
      stringsAsFactors = FALSE))

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

})

test_that("flow_code works",{
  fun <- function(x){
    x
  }
  expect_equal(
    flow_code(fun),
    paste0("\n#.if: visual=rhomb fill=#e2efda align=center\n#.for: visual=rhomb",
           " fill=#ddebf7 align=center\n#.repeat: visual=rhomb fill=#fce4d6",
           " align=center\n#.while: visual=rhomb fill=#fff2cc align=center\n#.",
           "standard: visual=class fill=#ededed\n#.commented: visual=class",
           " fill=#ededed\n#.header: visual=ellipse fill=#d9e1f2",
           " align=center\n#.return: visual=end fill=#70ad47  ",
           "empty\n#.stop: visual=end fill=#ed7d31  empty\n",
           "#.break: visual=receiver fill=#ffc000 empty\n",
           "#.next: visual=transceiver fill=#5b9bd5  empty\n",
           "#arrowSize: 1\n",
           "#bendSize: 0.3\n",
           "#direction: down\n#gutter: 5\n",
           "#edgeMargin: 0\n",
           "#edges: hard\n#fill: #eee8d5\n#fillArrows: false\n#font: Calibri\n",
           "#fontSize: 12\n#leading: 1.25\n#lineWidth: 3\n#padding: 16\n",
           "#spacing: 40\n#stroke: #33322E\n#title: filename\n#zoom: 1\n",
           "#acyclicer: greedy\n#ranker: network-simplex\n",
           "[<header>fun(x)]  -> [<standard> 1: ;x]\n[<standard> 1: ;x]  -> [<return> 2]")
  )
})

# have tests with break and next
# have tests with repeat an while
# have tests with code = NA and code = FALSE
# have test where if call and yes is dead end (add_data_from_if_block 118:119)
# have tests for other flow funs

#.break: visual=receiver fill=#ffc000 empty
#.next: visual=transceiver fill=#5b9bd5  empty


# detach("package:funflow")
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
