library(testthat)
library(yelp)

if (identical(tolower(Sys.getenv("NOT_CRAN")), "true")) {
  test_check("yelp")
}

