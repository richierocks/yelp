# Convert NULL to empty character
null2empty <- function(x) {
  if(is.null(x)) "" else x
}

null2na <- function(x) {
  if(is.null(x)) NA_real_ else x
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

#' @importFrom purrr map_chr
#' @importFrom tibble data_frame
business_object_to_df_row <- function(business) {
  data_frame(
    id = business$id,
    name = business$name,
    rating = business$rating,
    review_count = business$review_count,
    price = business$price,
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
}

#' @importFrom tibble data_frame
review_object_to_df_row <- function(review) {
  data_frame(
    rating = review$rating,
    text = review$text,
    time_created = review$time_created,
    url = review$url,
    user_image_url = n2e(review$user$image_url),
    user_name = review$user$name
  )
}