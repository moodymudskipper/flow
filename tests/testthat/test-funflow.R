fun_if_no_else <- function(x, y){
  x <- x * 2
  y <- y * 3
  if(y > x){
    print("y is big!")
  }
  prod <- x * y
  prod
}

funflow(fun_if_no_else)

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
    print("--------------------")
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


mermaid_str <- "graph TB"

for(i in seq_len(nrow(nodes))){
  id        <- nodes$id[[i]]
  construct <- nodes$construct[[i]]
  label     <- nodes$label[[i]]
  mermaid_str <- paste0(
    mermaid_str,"\n",
    switch(construct,
           header = sprintf("%s(%s)", id, label),
           none = sprintf("%s[%s]", id, label),
           'if' = sprintf("%s{%s}", id, label),
           'for' = sprintf("%s{%s}", id, label),
           'while' = sprintf("%s{%s}", id, label),
           'repeat' = sprintf("%s{%s}", id, label))
  )
}


mermaid(mermaid_str)

