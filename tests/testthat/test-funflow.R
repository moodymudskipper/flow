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

test_that("view_flow works with empty fun",{
  fun <- function(x) {}
  # view_flow(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  data <- view_flow(fun,output = "data")
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "none", "end"),
      code_str = c("fun", "", ""),
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

test_that("view_flow works with one symbol in body",{
  fun <- function(x) {x}
  # view_flow(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  data <- view_flow(fun,output = "data")
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "none", "end"),
      code_str = c("fun", "x", ""),
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
test_that("view_flow works with one call in body",{
  fun <- function(x) {x + y}
  # view_flow(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  data <- view_flow(fun,output = "data")
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "none", "end"),
      code_str = c("fun", "x + y", ""),
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
test_that("view_flow works with 2 calls in body",{
  fun <- function(x) {
    x + y
    u + v
    }
  # view_flow(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  data <- view_flow(fun,output = "data")
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2),
      block_type = c("header", "none", "end"),
      code_str = c("fun", "x + y;u + v", ""),
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
test_that("view_flow works with simple if and empty body",{
  fun <- function(x) {
    if(x) {}
  }
  data <- view_flow(fun,output = "data")
  # view_flow(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "if", "none", "end", "end"),
      code_str = c("fun", "if (x)", "", "", ""),
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
test_that("view_flow works with simple if",{
  fun <- function(x) {
    if(x) foo
  }
  data <- view_flow(fun,output = "data")
  # view_flow(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "if", "none", "end", "end"),
      code_str = c("fun", "if (x)", "foo", "", ""),
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
test_that("view_flow works with simple if else",{
  fun <- function(x) {
    if(x) foo else bar
  }
  data <- view_flow(fun,output = "data")
  # view_flow(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, 3, -1, 4),
      block_type = c("header", "if", "none", "none", "end", "end"),
      code_str = c("fun", "if (x)", "foo", "bar", "", ""),
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
test_that("view_flow works returning on the yes branch",{
  fun <- function(x) {
    if(x) return(foo) else bar
  }
  data <- view_flow(fun,output = "data")
  # view_flow(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
        id = c(0, 1, 2, -2, 3, -1, 4),
        block_type = c("header", "if", "none", "return", "none", "end", "end"),
        code_str = c("fun", "if (x)", "return(foo)", "", "bar", "", ""),
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
test_that("view_flow works stopping on the no branch",{
    fun <- function(x) {
      if(x) foo else stop(bar)
    }
    data <- view_flow(fun,output = "data")
    # view_flow(fun)
    # dput2(data$nodes[1:4])
    # dput2(data$edges)
    expect_equal(
      data$nodes[1:4],
      data.frame(
        id = c(0, 1, 2, 3, -3, -1, 4),
        block_type = c("header", "if", "none", "none", "stop", "end", "end"),
        code_str = c("fun", "if (x)", "foo", "stop(bar)", "", "", ""),
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
test_that("view_flow works stopping on the yes branch and returning on the right branch",{
  fun <- function(x) {
    if(x) stop(foo) else return(bar)
  }
  data <- view_flow(fun,output = "data")
  # view_flow(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -2, 3, -3, 4),
      block_type = c("header", "if", "none", "stop", "none", "return", "end"),
      code_str = c("fun", "if (x)", "stop(foo)", "", "return(bar)", "", ""),
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
test_that("view_flow works with nested if calls",{
  fun <- function(x) {
    if(x) if(y) foo else bar
  }
  data <- view_flow(fun,output = "data")
  # view_flow(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -2, 3, -3, 4),
      block_type = c("header", "if", "none", "stop", "none", "return", "end"),
      code_str = c("fun", "if (x)", "stop(foo)", "", "return(bar)", "", ""),
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

#### FOR ####
# empty for loop
test_that("view_flow works with an empty  for loop",{
  fun <- function(x) {
    for(x in foo) {}
  }
  data <- view_flow(fun,output = "data")
  # view_flow(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "for", "none", "start", "end"),
      code_str = c("fun", "for (x in foo)", "", "", ""),
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
test_that("view_flow works with simple for loop",{
  fun <- function(x) {
    for(x in foo) x
  }
  data <- view_flow(fun,output = "data")
  # view_flow(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "for", "none", "start", "end"),
      code_str = c("fun", "for (x in foo)", "x", "", ""),
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
test_that("view_flow works with simple for loop",{
  fun <- function(x) {
    if(foo)
      for(x in bar) baz
    else
      for(x in qux) quux
  }
  data <- view_flow(fun,output = "data")
  # view_flow(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "for", "none", "start", "end"),
      code_str = c("fun", "for (x in foo)", "x", "", ""),
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

# -------------
test_that("-------",{
  fun <- function(x) {
    if(foo) {
      if(bar) baz
    }
    for(x in qux) quux
  }
  data <- view_flow(fun,output = "data")
  # view_flow(fun)
  # dput2(data$nodes[1:4])
  # dput2(data$edges)
  expect_equal(
    data$nodes[1:4],
    data.frame(
      id = c(0, 1, 2, -1, 3),
      block_type = c("header", "for", "none", "start", "end"),
      code_str = c("fun", "for (x in foo)", "x", "", ""),
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

# simple while loop
# if else call with while loops on each side
# simple repeat loop
# if else call with repeat loops on each side



fun_if <- function(x){
  ## com1
  x <- 1
  ## com2
  x <- 2
  x <- 2
  if(x == 3) {
    ## com3
    x <- 3
  }
  x <- "foo"
  ## com4
  x <- 4
}

view_flow(fun_if)


fun_if_else <- function(x){
  ## com1
  x <- 1
  ## com2
  x <- 2
  x <- 2
  if(x == 3) {
    ## com3
    x <- 3
  } else {
    x <- "bar"
  }
  x <- "foo"
  ## com4
  x <- 4
}

view_flow(fun_if_else, prefix = "##")

fun_if_else_stop <- function(x){
  if(TRUE) {
    foo
  } else {
    stop("!!!!!")
  }

  if(TRUE) {
    foo
    return(bar)
  } else {
    baz
  }
  qux
}

view_flow(fun_if_else_stop)



area <- function(radius, angle, check = TRUE){
  radius_squared <- r^2
  if(check){
    if(angle < 0 || angle > 2*pi){
      stop("incorrect angle value")
    } else {
      print("good angle value")
    }
  }
  area <- angle * radius_squared
  area
}

funflow(area)

fun_for <- function(x){
  for(elt in x) {
    foo
  }
}


view_flow(fun_for)

fun_while <- function(x){
  while(x) {
    foo
  }
}

view_flow(fun_while)

fun_repeat <- function(x){
  repeat {
    foo
  }
}

# issue with the last if (wrong link), these could be avoided by adding an empty elt
# at the end of all cfc calls
view_flow(fun_repeat)






# modify function so that control flow constructs use `{...}` AND keep comments in srcref

# I would like to modify an input function, so that the expressions always calls
# `` `{`()``, and doing so, keep the comments at the right place. Here is an example :

input_fun <- function(){

  if(TRUE)
    foo
  else
    ## bar_com1
    ## bar_com2
    bar({
      x({y})
    }) %in% z

  ## if
  if(
    FALSE) {
    this
    ## baz_com
    baz
    that
  }

  repeat
    while(condition)
      ## qux_com
      qux
}

