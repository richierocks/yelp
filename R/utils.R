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

assert_has_access_token <- function(access_token) {
  if(is.na(access_token)) {
    stop("No Yelp API access token was found. See ?get_access_token.")
  }
  invisible(access_token)
}

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

#' @param business A list.
#' @param detailed Logical. Use FALSE for the business search and food
#' delivery search, and TRUE for business lookup.
#' @importFrom purrr map_chr
#' @importFrom tibble data_frame
#' @noRd
business_object_to_df_row <- function(business, detailed = FALSE) {
  business_data <- data_frame(
    id = business$id,
    name = business$name,
    rating = business$rating,
    review_count = business$review_count,
    price = null2empty(business$price),
    image_url = business$image_url,
    is_closed = business$is_closed,
    url = business$url,
    category_aliases = list(map_chr(business$categories, function(x) x$alias)),
    category_titles = list(map_chr(business$categories, function(x) x$title)),
    latitude = business$coordinates$latitude,
    longitude = business$coordinates$longitude,
    distance_m = null2na(business$distance),
    transactions = list(as.character(business$transactions)),
    address1 = business$location$address1,
    address2 = null2empty(business$location$address2),
    address3 = null2empty(business$location$address3),
    city = null2empty(business$location$city),
    zip_code = null2empty(business$location$zip_code),
    state = null2empty(business$location$state),
    country = null2empty(business$location$country),
    display_address = list(as.character(business$location$display_address)),
    phone = business$phone,
    display_phone = business$display_phone
  )
  if(detailed) { # extra info, as returned by business_lookup()
    business_data$photos <- list(business$photos)
    business_data$is_claimed <- business$is_claimed
    business_data$is_permanently_closed <- business$is_closed
    business_data$opening_hours <- list(map_df(
      # Unclear if there is a situation where there may be more than
      # 1 hours element
      business$hours[[1]]$open,
      function(open) {
        data_frame(
          start_day = number2weekday(open$day),
          start_time = open$start,
          end_day = number2weekday(open$day + open$is_overnight),
          end_time = open$end
        )
      }
    ))
  }
  business_data
}


