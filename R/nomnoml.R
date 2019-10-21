build_nomnoml_code <- function(
  data,
  code,
  arrowSize = 1,
  bendSize = 0.3,
  direction = c("down", "right"),
  gutter = 5,
  edgeMargin = 0,
  edges = c("hard", "rounded"),
  fill = "#eee8d5",
  fillArrows = FALSE,
  font = "Calibri",
  fontSize = 12,
  leading = 1.25,
  lineWidth = 3,
  padding = 16,
  spacing = 40,
  stroke = "#33322E",
  title = "filename",
  zoom = 1,
  acyclicer = "greedy",
  ranker = c("network-simplex", "tight-tree", "longest-path")){

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
    node_data$code_str[node_data$block_type %in% c("none", "commented")] <- ""
  }

  # create the box column containing the nomnoml box string
  node_data$box <- NA
  node_data$box <- sprintf(
    "[<%s> %s: %s;%s]",
    node_data$block_type,
    node_data$id,
    node_data$label,
    node_data$code_str)
  # cleanup last chars of the box in cases where no code (e.g. start and end)
  node_data$box  <- gsub(":?\\s*;\\]$","]", node_data$box)
  # create the nomnoml code for each edge
  edge_data <- transform(edge_data, nomnoml_code = sprintf(
    "%s %s %s %s", node_data$box[from], edge_label, arrow, node_data$box[to]))

  # create the header
  header <- sprintf(
    "
    #.if: visual=rhomb fill=#e2efda align=center
    #.for: visual=rhomb fill=#ddebf7 align=center
    #.repeat: visual=rhomb fill=#fce4d6 align=center
    #.while: visual=rhomb fill=#fff2cc align=center
    #.none: visual=class fill=#ededed
    #.commented: visual=class fill=#ededed
    #.header: visual=ellipse fill=#d9e1f2 align=center
    #.return: visual=end fill=#70ad47  empty
    #.stop: visual=end fill=#ed7d31  empty
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
  nomnoml_code <- paste0(header,"\n", nomnoml_code)
  #cat(nomnoml_code)
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
