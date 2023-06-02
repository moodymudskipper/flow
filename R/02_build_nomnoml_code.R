# # kept for convenience
# flow_code <-
#   function(x, prefix = NULL, nested_fun = NULL, swap = FALSE,
#            narrow = FALSE, code = TRUE, ...) {
#     data <- eval.parent(substitute(flow_data(
#       x, prefix, nested_fun, swap, narrow)))
#     code <- build_nomnoml_code(data, code = code, ...)
#     code
#   }


build_nomnoml_code <- function(
  data,
  code,
  direction = c("down", "right"),
  ranker = c("network-simplex", "tight-tree", "longest-path"),
  arrowSize = 1,
  edges = c("hard", "rounded"),
  bendSize = 0.3,
  font = "Courier",
  fontSize = 12,
  lineWidth = 3,
  padding = 16,
  spacing = 40,
  leading = 1.25,
  stroke = "#33322E",
  fill = "#eee8d5",
  title = "filename",
  zoom = 1,
  fillArrows = FALSE,
  acyclicer = "greedy",
  gutter = 5,
  edgeMargin = 0){

  ## check/preprocess parameters

  # check parameters
  direction <- match.arg(direction)
  edges     <- match.arg(edges)
  ranker    <- match.arg(ranker)

  # FALSE or TRUE must become "false" or "true" for nomnoml
  fillArrows <- tolower(fillArrows)

  # To appease cmd check
  box.x <- edge_label <- arrow <- box.y <- NULL

  ## escape special characters from relevant variables

  # extract nodes and edges
  node_data <- data$nodes
  edge_data <- data$edges

  # escape pipes characters and square brackets
  node_data$code_str <- escape_pipes_and_brackets(node_data$code_str)
  node_data$label    <- escape_pipes_and_brackets(node_data$label)

  ## was `code` set to `NA` ?
  if (is.na(code)) {
    ## remove the content of all blocks headed by special comments
    node_data$code_str[node_data$label != ""] <- ""
  } else {
    ## was `code` set to `FALSE` ?
    if (!code) {
      ## remove the content of all blocks except control flow headers
      node_data$code_str[node_data$block_type %in% c("standard", "commented")] <- ""
    }
  }

  ## update node data with nomnoml code for all nodes

  node_data$box <- NA
  node_data$box <- sprintf(
    "[<%s> %s: %s;%s]",
    node_data$block_type,
    node_data$id,
    node_data$label,
    node_data$code_str)

  # cleanup header block
  headers_lgl <- node_data$block_type == "header"
  node_data$box[headers_lgl]  <- sub("^\\[.*?: ;","[<header>", node_data$box[headers_lgl])
  # cleanup last chars of the box in cases where no code (no code or start/end blocks)
  node_data$box  <- sub("(:?)\\s*;\\]$","\\1]", node_data$box, perl=TRUE)

  ## merge to integrate node data into edge data

  edge_data$order <- seq_len(nrow(edge_data))
  edge_data <- merge(edge_data, node_data[c("id","box")], by.x = "from", by.y = "id", all.x = TRUE)
  edge_data <- merge(edge_data, node_data[c("id","box")], by.x = "to", by.y = "id", all.x = TRUE)

  ## build nomnoml code lines

  edge_data <- transform(edge_data, nomnoml_code = sprintf(
    "%s %s %s %s",
    box.x,
    edge_label,
    arrow,
    box.y))

  edge_data <- edge_data[order(edge_data$order),]

  ## build header and combine all into code string

  header <- paste0(
    "#.if: visual=rhomb fill=#e2efda align=center\n",
    "#.for: visual=rhomb fill=#ddebf7 align=center\n",
    "#.repeat: visual=rhomb fill=#fce4d6 align=center\n",
    "#.while: visual=rhomb fill=#fff2cc align=center\n",
    "#.standard: visual=class fill=#ededed align=left\n",
    "#.standardg: visual=class fill=#70ad47 align=left\n",
    "#.standardr: visual=class fill=#ed7d31 align=left\n",
    "#.commented: visual=class fill=#ededed\n",
    "#.header: visual=roundrect fill=#d9e1f2 align=left\n",
    "#.return: visual=end fill=#70ad47  empty\n",
    "#.stop: visual=end fill=#ed7d31  empty\n",
    "#.break: visual=receiver fill=#ffc000 empty\n",
    "#.next: visual=transceiver fill=#5b9bd5  empty\n",
    "#arrowSize: ", arrowSize, "\n",
    "#bendSize: ", bendSize, "\n",
    "#direction: ", direction, "\n",
    "#gutter: ", gutter, "\n",
    "#edgeMargin: ", edgeMargin, "\n",
    "#edges: ", edges, "\n",
    "#fill: ", fill, "\n",
    "#fillArrows: ", fillArrows, "\n",
    "#font: ", font, "\n",
    "#fontSize: ", fontSize, "\n",
    "#leading: ", leading, "\n",
    "#lineWidth: ", lineWidth, "\n",
    "#padding: ", padding, "\n",
    "#spacing: ", spacing, "\n",
    "#stroke: ", stroke, "\n",
    "#title: ", title, "\n",
    "#zoom: ", zoom, "\n",
    "#acyclicer: ", acyclicer, "\n",
    "#ranker: ", ranker, "\n"
  )

  nomnoml_code <- paste(edge_data$nomnoml_code, collapse = "\n")
  nomnoml_code <- paste0(header,"\n", nomnoml_code)

  nomnoml_code
}


# classifiers
# nomnoml::nomnoml("
# #direction: right
# [ A
# [<label> \\[default\\]] -/- [default]
# [<label> \\[<abstract> abstract\\]] -/- [<abstract> abstract]
# [<label> \\[<instance> instance\\]] -/- [<instance> instance]
# [<label> \\[<note> note\\]] -/- [<note> note]
# [<label> \\[<reference> reference\\]] -/- [<reference> reference]
# [<label> \\[<package> package\\]] -/- [<package> package]
# [<label> \\[<frame> frame\\]] -/- [<frame> frame]
# [<label> \\[<database> database\\]] -/- [<database> database]
# [<label> \\[<start> start\\]] -/- [<start> start]
# [<label> \\[<end> name9\\]] -/- [<end> name9]
# ] -/- [B
# [<label> \\[<state> state\\]] -/- [<state> state]
# [<label> \\[<choice> choice\\]] -/- [<choice> choice]
# [<label> \\[<input> input\\]] -/- [<input> input]
# [<label> \\[<sender> sender\\]] -/- [<sender> sender]
# [<label> \\[<receiver> receiver\\]] -/- [<receiver> receiver]
# [<label> \\[<transceiver> transceiver\\]] -/- [<transceiver> transceiver]
# [<label> \\[<actor> actor\\]] -/- [<actor> actor]
# [<label> \\[<usecase> usecase\\]] -/- [<usecase> usecase]
# [<label> \\[<label> label\\]] -/- [<label> label]
# [<label> \\[<hidden> hidden\\]] -/- [<hidden> hidden]
# ]")
