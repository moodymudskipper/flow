build_nomnoml_code <- function(
  data,
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
  node_data$code_str <- gsub("([][]|])","\\\\\\1", node_data$code_str)

  # create the box column containing the nomnoml box string
  node_data$box <- NA
  node_data <- within(node_data,{
    ind <- block_type == "header"
    box[ind] <- sprintf("[<usecase>%s:;%s]", id[ind], code_str[ind])

    ind <- block_type == "none"
    box[ind] <- sprintf("[<abstract>%s:;%s]", id[ind], gsub("\\n",";",code_str[ind]))

    ind <- block_type == "commented"
    box[ind] <- sprintf("[<abstract>%s:;%s]", id[ind], gsub("\\n",";",code_str[ind]))

    ind <- block_type == "if"
    box[ind] <- sprintf("[<choice>%s:;%s]", id[ind], gsub("\\n",";",code_str[ind]))

    ind <- block_type == "for"
    box[ind] <- sprintf("[<choice>%s:;%s]", id[ind], gsub("\\n",";",code_str[ind]))

    ind <- block_type == "while"
    box[ind] <- sprintf("[<choice>%s:;%s]", id[ind], gsub("\\n",";",code_str[ind]))

    ind <- block_type == "repeat"
    box[ind] <- sprintf("[<choice>%s:;%s]", id[ind], gsub("\\n",";",code_str[ind]))

    ind <- block_type == "end"
    box[ind] <- sprintf("[<end>%s]",  id[ind], code_str[ind])
    rm(ind)
  })

  # create the nomnoml code for each edge
  edge_data <- transform(edge_data, nomnoml_code = sprintf(
    "%s %s %s %s", node_data$box[from], edge_label, arrow, node_data$box[to]))

  # create the header
  header <- sprintf(
    "
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
