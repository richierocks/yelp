#' Call the Yelp api
#'
#' @param endpoint A string describing the URL to access.
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @return A list. The exact contents depend upon the endpoint.
#' @importFrom httr add_headers
#' @importFrom httr GET
#' @importFrom httr stop_for_status
#' @importFrom httr content
#' @noRd
call_yelp_api <- function(endpoint, access_token, ...) {
  query <- list(...)
  response <- GET(
    paste0("https://api.yelp.com/v3/", endpoint),
    config = add_headers(Authorization = paste("bearer", access_token)),
    query = query
  )
  stop_for_status(response)
  content(response, as = "parsed")
}


# Convert NULL to empty character
null2empty <- function(x) {
  if(is.null(x)) "" else x
}

null2na <- function(x) {
  if(is.null(x)) NA_real_ else x
}

number2weekday <- function(x) {
  switch(
    as.character(x),
    "0" = "Monday", "1" = "Tuesday",
    "2" = "Wednesday", "3" = "Thursday",
    "4" = "Friday", "5" = "Saturday",
    "6" = "Sunday"
  )
}


