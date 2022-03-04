#extract_c_funs("R/test.cpp")
# build_plantuml_code_from_c("R/test.cpp")
# build_plantuml_code_from_c("R/test.cpp", "stop_filter_incompatible_size")
# build_plantuml_code_from_c("R/test.cpp", "stop_filter_incompatible_type")
# build_plantuml_code_from_c("R/test.cpp", "all_lgl_columns")
# build_plantuml_code_from_c("R/test.cpp", "reduce_lgl")
# build_plantuml_code_from_c("R/test.cpp", "filter_check_size")
# build_plantuml_code_from_c("R/test.cpp", "filter_check_type")
# build_plantuml_code_from_c("R/test.cpp", "eval_filter_one")
# build_plantuml_code_from_c("R/test.cpp", "dplyr_mask_eval_all_filter")

# nocov start
protect_c_code <- function(code) {
        # remove protected quotes
        code <- gsub('\\\\"', "..", code)
        code <- gsub("\\\\'", "..", code)


        # in C, single quotes are used for single characters, so we could find '"', but
        # this sequence couldn't be found inside a double quoted string so we can safely edit it
        code <- gsub("'\"'", "'.'", code) # replace <'"'> by <'.'>
        # now we now that when we are between dbl quotes we are in a string, so we can edit those
        m <- gregexpr('".*?"', code)
        regmatches(code, m) <- lapply(regmatches(code, m), gsub, pattern = "[(){}']", replacement = ".")
        # now we can edit single quotes too
        m <- gregexpr("'.*?'", code)
        regmatches(code, m) <- lapply(regmatches(code, m), gsub, pattern = "[(){}]", replacement = ".")
        code
}


extract_c_funs <- function(path) {

        code <- paste(readLines(path), collapse = "\n")
        code1 <- protect_c_code(code)

        chars      <- strsplit(code1, split='')[[1]]
        # open_close <- ifelse(chars == '(', 1, ifelse(chars==')', -1, 0))
        open_close <- ifelse(chars == '{', 1, ifelse(chars=='}', -1, 0))
        depth      <- cumsum(open_close)
        open_close[open_close == 0] <- NA
        depth <- depth * open_close
        # find function declarations to match them with above

        m <- gregexpr("\\w+ +\\w+ *\\(.*?\\) *\\{", code1)[[1]]
        m_else_if <- gregexpr("else +if *\\(.*?\\) *\\{", code1)[[1]]
        keep_lgl <- !m %in% m_else_if
        m_ends <- as.numeric(m[keep_lgl] + attr(m, "match.length")[keep_lgl] -1)
        m <- as.numeric(m[keep_lgl])
        m_depth <- depth[m_ends]
        funs <- character(length(m))
        for (i in seq_along(m)) {
                start <- m[[i]]
                end <- which(depth == 1-m_depth[[i]])
                end <- end[end > start][[1]]
                funs[[i]] <- substr(code, start, end)
        }
        funs
        names(funs) <- gsub("^\\w+ +(\\w+) *\\(.*", "\\1", funs)
        as.list(funs)
}

update_groups <- function(groups, code, label, pattern) {
        matched <- gregexpr(pattern, code, perl = TRUE)[[1]]
        if(matched[[1]] == -1) matched <- numeric()
        for(i in seq_along(matched)){
                ind <-  matched[[i]]:(matched[[i]]+ attr(matched, "match.length")[[i]]-1)
                ind <- setdiff(ind, which(!is.na(groups)))
                groups[ind] <- label
        }
        groups
}

rleid <- function(x) {
        x <- rle(x)$lengths
        rep(seq_along(x), times=x)
}

make_groups <- function(code) {
        code1 <- protect_c_code(code)
        groups <- rep_len(NA, nchar(code))
        groups <- update_groups(groups, code1, "curly", "\\s*\\{(?>[^{}]|(?R))*\\} *\\n*")
        groups <- update_groups(groups, code1, "parens", "\\s*\\((?>[^()]|(?R))*\\)\\s*")
        #groups <- update_groups(groups, code1, "fun", "\\n\\s*\\w+\\s+\\w+\\s*\\(")
        groups <- update_groups(groups, code1, "if", "\\s*\\n\\s*if\\s*")
        groups <- update_groups(groups, code1, "elseif", "(\\}|\\n)\\s*else\\s*if\\s*")
        groups <- update_groups(groups, code1, "else", "(\\}|\\n)\\s*else\\s*")
        groups <- update_groups(groups, code1, "for", "\\s*\\n\\s*for\\s*")
        groups <- update_groups(groups, code1, "while", "\\s*\\n\\s*while\\s*")

        # matching from control flow to first ";"
        # done in the end it will not override parentheses etc
        groups <- update_groups(groups, code1, "cf_body", "\\s*\\n\\s*if\\s*[^{]+;\\s*")
        groups <- update_groups(groups, code1, "cf_body", "(\\}|\\n)\\s*else\\s*if\\s*[^{]+;\\s*")
        groups <- update_groups(groups, code1, "cf_body", "(\\}|\\n)\\s*else\\s*[^{]+;\\s*")
        groups <- update_groups(groups, code1, "cf_body", "\\s*\\n\\s*for\\s*[^{]+;\\s*")
        groups <- update_groups(groups, code1, "cf_body", "\\s*\\n\\s*while\\s*[^{]+;\\s*")

        groups
        # set parens following NA as NA as they are part of normal code
        groups <- Reduce(function(x,y) if(is.na(x) && y %in% "parens") NA else y, groups, accumulate = TRUE)

        groups[is.na(groups)] <- "standard"
        # higher level grouping
        groups1 <- Reduce(function(x,y) if(y %in% c("parens", "curly", "cf_body")) x else y, groups, accumulate = TRUE)
        df <- data.frame(
                group = groups1,
                subgroup = groups,
                chr = strsplit(code, "")[[1]],
                id_group = rleid(groups1),
                id_subgroup = rleid(groups),
                stringsAsFactors = FALSE)
        # combine text by subgroup
        df <- aggregate(chr ~ id_group + id_subgroup + group + subgroup, data = df, FUN = function(x) paste(x, collapse =""))
        df <- df[order(df[[1]], df[[2]]),]
        # remove brackets from curly
        tmp <- df$chr[df$subgroup == "curly"]
        tmp <- trimws(tmp)
        tmp <- substr(tmp, 2, nchar(tmp)-1)
        df$chr[df$subgroup == "curly"] <- tmp
        # remove empty blocks
        #print(grepl("^\\s*$", df$chr))
        df <- df[!grepl("^\\s*$", df$chr),]
        # nest by group
        df <- aggregate(chr ~ id_group + group, data = df, FUN = list)
        df <- df[order(df[[1]]),]
        # we might need one more layer to nest the "if" "else" and "else if"
        # because we need a way to place the "endif"
        # another way is to place the endif every time and to remove it when it's
        # followed by an else
        df
}

build_plantuml_code_from_c <- function(x, fun = NULL, out = NULL) {
        x_is_path <- grepl("\\.c(pp)?$", x )
        if(x_is_path) {
                funs <- extract_c_funs(x)
                if(is.null(fun)) {
                        message("choose a function to draw among: ", toString(names(funs)))
                        return(invisible(funs))
                }
                x <- funs[[fun]]
        }
        header <- trimws(sub("^([^{]+)\\{.*", "\\1", x), whitespace = "[\t\r\n]")
        header <- paste0("title ", header, "\nstart\n")
        body <- regmatches(x, regexpr("\\{(?>[^{}]|(?R))*\\}\\s*", x, perl = TRUE))
        code <- substr(body,2, nchar(body)-1)

        #df <- make_groups(body)
        plantuml_code <- build_plantuml_code_from_c0(code)
        plantuml_code <- gsub("endif\\nelse", "else", plantuml_code)
        plantuml_code <- gsub("\\\\nreturn", ";\n#70ad47:return", plantuml_code)
        plantuml_code <- gsub("^:return", "#70ad47:return", plantuml_code)
        plantuml_code <- gsub("#70ad47:return(.*?)\\n", "#70ad47:return\\1\nstop\n", plantuml_code)
        plantuml_code <- gsub("#70ad47:return(.*?)[^\n]$", "#70ad47:return\\1;\nstop", plantuml_code)
        #print(plantuml_code)
        plantuml_code <- paste(header, plantuml_skinparam, plantuml_code)
        plant_uml_object <- gfn("plantuml", "plantuml")(plantuml_code)
        plot(plant_uml_object, vector = FALSE)

        ## is `out` NULL ?
        if(is.null(out)) {
                ## plot the object and return NULL
                plot(plant_uml_object)
                return(invisible(NULL))
        }

        ## flag if out is a temp file shorthand
        is_tmp <- out %in% c("html", "htm", "png", "pdf", "jpg", "jpeg")

        ## is it ?
        if (is_tmp) {
                ## set out to a temp file with the right extension
                out <- tempfile("flow_", fileext = paste0(".", out))
        }

        ## plot the object
        plot(plant_uml_object, file = out)

        ## was the out argument a temp file shorthand ?
        if (is_tmp) {
                ## print location of output and open it
                message(sprintf("The diagram was saved to '%s'", gsub("\\\\","/", out)))
                browseURL(out)
        }
        ## return the path to the output invisibly
        invisible(out)
}



build_plantuml_code_from_c0 <- function(code) {
        df <- make_groups(code)
        chrs <- mapply(function(x, y) {
                chars <- c("\\[","\\]","~","\\.","\\*","_","\\-",'"', "<", ">", "&", "\\\\", ";")
                if(x == "standard") {
                        code <- c_clean_block(y)
                        code <- to_unicode(trimws(code ,whitespace = "[\t\r\n]"), chars)
                        code <- gsub("\n", "\\\\n", code)
                        res <- sprintf(":%s;",  code)
                        return(res)
                }
                if(x == "for") {
                        code <- gsub("\n", "\\\\n", to_unicode(trimws(y[[2]], whitespace = "[\t\r\n]"), chars))
                        header <- sprintf("#ddebf7:while (for %s)", code)
                        code <- y[[3]]
                        # code <- trimws(y[[3]])
                        # code <- substr(code ,2, nchar(code)-1)
                        body <- build_plantuml_code_from_c0(code)
                        res <- c(header, body, "endwhile")
                        return(res)
                }
                if(x == "while") {
                        code <- gsub("\n", "\\\\n", to_unicode(trimws(y[[2]], whitespace = "[\t\r\n]"), chars))
                        header <- sprintf("#fff2cc:while (while %s)", code)
                        code <- y[[3]]
                        # code <- trimws(y[[3]])
                        # code <- substr(code ,2, nchar(code)-1)
                        body <- build_plantuml_code_from_c0(code)
                        res <- c(header, body, "endwhile")
                        return(res)
                }
                if(x == "if") {
                        code <- gsub("\n", "\\\\n", to_unicode(trimws(y[[2]], whitespace = "[\t\r\n]"), chars))
                        header <- sprintf("#e2efda:if (if %s) then (y)", code)
                        code <- y[[3]]
                        # code <- trimws(y[[3]])
                        # code <- substr(code ,2, nchar(code)-1)
                        body <- build_plantuml_code_from_c0(code)
                        res <- c(header, body, "endif")
                        return(res)
                }
                if(x == "elseif") {
                        code <- gsub("\n", "\\\\n", to_unicode(trimws(y[[2]], whitespace = "[\t\r\n]"), chars))
                        header <- sprintf("elseif %s then (y)", code)
                        code <- y[[3]]
                        # code <- trimws(y[[3]])
                        # code <- substr(code ,2, nchar(code)-1)
                        body <- build_plantuml_code_from_c0(code)
                        res <- c(header, body, "endif")
                        return(res)
                }
                if(x == "else") {
                        header <- sprintf("else (n)", code)
                        code <- y[[2]]
                        # code <- trimws(y[[2]])
                        # code <- substr(code ,2, nchar(code)-1)
                        body <- build_plantuml_code_from_c0(code)
                        res <- c(header, body, "endif")
                        return(res)
                }


        }, df$group, df$chr)
        paste(unlist(chrs), collapse= "\n")
}

c_clean_block <- function(x) {
        # trim
        x <- sub("^(\\s*\\n)+", "", x)
        x <- sub("\\s+$", "", x)
        if(x == "") return("")
        # align
        x_split <- strsplit(x, "\n")[[1]]
        while(all(grepl("^ ", x_split)|x_split == "")) {
                x_split <- substr(x_split, 2, nchar(x_split))
        }
        paste(x_split, collapse = "\n")
}
# nocov end



