#' build nomnoml code from data
#'
#' This functions builds the nomnoml code to render from the data built by
#' `flow_data()`. It's not very useful for the average user to call it directly
#' but its arguments can be set through flow_view so their definitions are useful.
#'
#' All arguments, with the exception of `data` and `code`, are
#' nomnoml directives, enumerated at https://openbase.io/js/nomnoml/documentation .
#'
#' Some of those don't seem to do anything in the context of this package,
#' but given the sparsity of nomnoml documentation, we
#' decided to keep all of them to be safe.
#'
#' @param data A data frame built by `flow_data()`
#' @param code Whether to the code in code blocks or only the identifier, to be
#'   more compact, if `NA`, the code will be displayed only if not commented, so
#'   comments can be used as pseudocode for chosen blocks.
#' @param direction Whether to orient the chart from top to bottom or left to
#' @param ranker ranker, set to "longest-path" to have all exit points alligned
#'   at the bottom.
#' @param arrowSize Arrow size
#' @param edges Whether to keep edges `"straight"`, or have them `"rounded"`
#' @param bendSize Bend size, if `edges` is `"rounded"`
#' @param font Font
#' @param fontSize Font size
#' @param lineWidth Line Width
#' @param padding Padding
#' @param spacing Spacing between blocks
#' @param leading distance between two baselines of lines of type
#' @param stroke Stroke
#' @param fill Default filling color
#' @param title Title, no effect was observed
#' @param zoom Zoom, no effect was observed
#' @param fillArrows Whether to fill arrows, no effect was observed
#' @param acyclicer Acyclicer, no effect was observed
#' @param gutter Gutter, no effect was observed
#' @param edgeMargin Edge margin, no effect was observed
#'
#' @return
#' @export
build_nomnoml_code <- function(
  data,
  code,
  direction = c("down", "right"),
  ranker = c("network-simplex", "tight-tree", "longest-path"),
  arrowSize = 1,
  edges = c("hard", "rounded"),
  bendSize = 0.3,
  font = "Calibri",
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

  # check parameters
  direction <- match.arg(direction)
  edges  <- match.arg(edges)
  ranker <- match.arg(ranker)

  # FALSE or TRUE must become "false" or "true" for nomnoml
  fillArrows <- tolower(fillArrows)

  # extract nodes and edges
  node_data <- data$nodes
  edge_data <- data$edges

  # escape pipes characters and square brackets
  node_data$code_str <- gsub("]","\\]", node_data$code_str,fixed = TRUE)
  node_data$code_str <- gsub("[","\\[", node_data$code_str,fixed = TRUE)
  node_data$code_str <- gsub("|","\\|", node_data$code_str,fixed = TRUE)

  if(is.na(code)){
    node_data$code_str[node_data$label != ""] <- ""
  } else if(!code) {
    node_data$code_str[node_data$block_type %in% c("standard", "commented")] <- ""
  }

  # create the box column containing the nomnoml box string
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
  node_data$box  <- sub(":?\\s*;\\]$","]", node_data$box)
  # create the nomnoml code for each edge
  edge_data$order <- seq_len(nrow(edge_data))
  edge_data <- merge(edge_data,node_data[c("id","box")], by.x = "from", by.y = "id", all.x = TRUE)
  edge_data <- merge(edge_data,node_data[c("id","box")], by.x = "to", by.y = "id", all.x = TRUE)
  # To appease cmd check
  box.x <- edge_label <- arrow <- box.y <- NULL
  edge_data <- transform(edge_data, nomnoml_code = sprintf(
    "%s %s %s %s",
    box.x,
    edge_label,
    arrow,
    box.y))
  edge_data <- edge_data[order(edge_data$order),]

  # create the header
  header <- sprintf(
    "
    #.if: visual=rhomb fill=#e2efda align=center
    #.for: visual=rhomb fill=#ddebf7 align=center
    #.repeat: visual=rhomb fill=#fce4d6 align=center
    #.while: visual=rhomb fill=#fff2cc align=center
    #.standard: visual=class fill=#ededed
    #.commented: visual=class fill=#ededed
    #.header: visual=ellipse fill=#d9e1f2 align=center
    #.return: visual=end fill=#70ad47  empty
    #.stop: visual=end fill=#ed7d31  empty
    #.break: visual=receiver fill=#ffc000 empty
    #.next: visual=transceiver fill=#5b9bd5  empty
    #arrowSize: %s
    #bendSize: %s
    #direction: %s
    #gutter: %s
    #edgeMargin: %s
    #edges: %s
    #fill: %s
    #fillArrows: %s
    #font: %s
    #fontSize: %s
    #leading: %s
    #lineWidth: %s
    #padding: %s
    #spacing: %s
    #stroke: %s
    #title: %s
    #zoom: %s
    #acyclicer: %s
    #ranker: %s",
    arrowSize, bendSize, direction, gutter, edgeMargin, edges, fill, fillArrows,
    font, fontSize, leading, lineWidth, padding, spacing, stroke, title, zoom,
    acyclicer, ranker)
  header <- gsub("\\n\\s+","\n", header)

  nomnoml_code <- paste(edge_data$nomnoml_code, collapse="\n")
  # print(node_data[1:2])
  # print(edge_data)
  # cat(nomnoml_code)
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
