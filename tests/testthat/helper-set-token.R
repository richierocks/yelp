set_token <- function() {
  old_token <- Sys.getenv("YELP_ACCESS_TOKEN", NA)
  message('old token = ', old_token)
  message(' path = ', test_path("sample_yelp_access_token.rds"))
  if(is.na(old_token)) {
    Sys.setenv(
      YELP_ACCESS_TOKEN = readRDS(test_path("sample_yelp_access_token.rds"))
    )
  }
  invisible(old_token)
}

unset_token <- function(token) {
  if(nzchar(token)) {
    Sys.setenv(YELP_ACCESS_TOKEN = token)
  }
}