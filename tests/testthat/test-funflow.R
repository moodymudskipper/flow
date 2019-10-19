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

funflow(fun_if_else)

fun_if_else <- function(x, y){
  x <- x * 2
  y <- y * 3
  if(y > x){
    print("y is big!")
  } else {
    print("y is small...")
  }
  prod <- x * y
  prod
}

funflow(fun_if_else)



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
  x <- paste0("a",x,"a")
  for(elt in x) {
    print("--------------")
    print(paste("x contains",elt))
  }
  x
}

funflow(fun_for)

fun_while <- function(x){
  x <- paste0(x)
  while(x) {
    print("--------------------")
    print(paste("x contains",elt))
  }
  x
}

funflow(fun_while)

fun_repeat <- function(x){
  x <- paste0(x)
  repeat {
    print("--------------------")
    print(paste("x contains",elt))
    if(foo) break
  }
  x
}

# issue with the last if (wrong link), these could be avoided by adding an empty elt
# at the end of all cfc calls
funflow(fun_repeat)






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

