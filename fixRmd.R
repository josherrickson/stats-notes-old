args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop("Error - more than one argument give")
}
file <- args[1]

library(stringr)


text <- readLines(file)

# Fix section headers
section_regexp <- "\\^#\\^"
sections <- str_detect(text, section_regexp)
text[sections] <- str_replace_all(text[sections], section_regexp, "#")
text[sections] <- str_replace_all(text[sections], "</?p>", "")

# Fix equations
display_eq_regexp <- "^$$^"
sections <- str_detect(text, fixed(display_eq_regexp))
text[sections] <- str_replace_all(text[sections], fixed(display_eq_regexp), "$$")
text[sections] <- str_replace_all(text[sections], "</?p>", "")

inline_regexp <- "^$^"
sections <- str_detect(text, fixed(inline_regexp))
text[sections] <- str_replace_all(text[sections], fixed(inline_regexp), "$")

# Fix > and <
#text <- str_replace_all(text, fixed("&gt;"), ">")
#text <- str_replace_all(text, fixed("&lt;"), "<")

# fix Rmarkdown header
text[1] <- "---"
text <- text[-(str_which(text, "^#")[1] - 1)]

# Remove "empty" code (leftover when using dd_do:quietly)
text <- text[-(str_which(text, "<pre><code></code></pre>"))]

write.table(text, file, row.names = FALSE, col.names = FALSE, quote = FALSE)
