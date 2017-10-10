library(jsonlite)
library(purrr)

categories <- read_json("https://www.yelp.com/developers/documentation/v3/all_category_list/categories.json")
category_aliases <- map_chr(categories, function(x) x$alias)
dput(category_aliases)
