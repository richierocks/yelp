library(rvest)
library(purrr)

locales <- "https://www.yelp.com/developers/documentation/v3/supported_locales" %>%
  read_html() %>%
  html_node(css = ".table-striped") %>%
  html_nodes("pre") %>%
  map_chr(html_text)
dput(locales)


