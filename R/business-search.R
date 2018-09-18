#' Search for businesses
#'
#' Use the Yelp business search API to find businesses close to a give location.
#' @param term A string denoting the search term.
#' @param location A string describing the location. If this is not provided,
#' then \code{latitude} and \code{longitude} are compulsory.
#' @param latitude A number representing the latitude to search close to.
#' @param longitude A number representing the longitude to search close to.
#' @param radius_m A number giving the radius, in metres, of the search circle
#' around the specified location.
#' @param categories A character vector of search categories to filter on,
#' or \code{NULL} to return everything. See \code{\link{SUPPORTED_CATEGORY_ALIASES}}
#' for allowed values.
#' @param locale A string naming the locale. See \code{\link{SUPPORTED_LOCALES}}
#' for allowed values.
#' @param limit An integer giving the maximum number of businesses to return.
#' Maximum 50.
#' @param offset An integer giving the number of businesses to skip before
#' returning. Allows you to return more than 50 businesses (split between
#' multiple searches).
#' @param sort_by A string naming the metric to order results by.
#' @param price A vector of integers in 1 (cheap) to 4 (expensive) denoting
#' price brackets.
#' @param open_now A logical value of whether or not to only return businesses
#' that are currently open.
#' @param open_at A time when to check if businesses are open.
#' @param attributes A character vector of business attributes to filter on.
#' See \code{\link{SUPPORTED_BUSINESS_ATTRIBUTES}}.
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @return A data frame with 24 columns. Each row corresponds to one business.
#' @references \url{https://www.yelp.com/developers/documentation/v3/business_search}
#' @examples
#' \donttest{
#' ## Marked as don't test because an access token is needed
#' delis_in_queens <- business_search("deli", "Queens, New York")
#' if(interactive()) View(delis_in_queens) else str(delis_in_queens)
#' }
#' @importFrom assertive.types assert_is_a_bool
#' @importFrom purrr map_df
#' @export
business_search <- function(term, location, latitude = NULL, longitude = NULL, radius_m = 40000,
  categories = NULL, locale = "en_US", limit = 20, offset = 0,
  sort_by = c("best_match", "rating", "review_count", "distance"),
  price = 1:4, open_now = FALSE, open_at = NULL,
  attributes = NULL,
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  assert_has_access_token(access_token)
  if(!is.null(location)) {
    location <- parse_location(location)
  } else {
    check_latitude(latitude, null_is_ok = FALSE)
    check_longitude(longitude, null_is_ok = FALSE)
  }
  radius_m <- parse_radius_m(radius_m)
  categories <- parse_categories(categories)
  locale <- parse_locale(locale)
  check_limit(limit)
  sort_by <- match.arg(sort_by)
  price <- parse_price(price)
  if(!is.null(open_at)) {
    open_now <- NULL
    open_at <- to_unix_time(open_at)
  } else {
    assert_is_a_bool(open_now)
  }
  attributes <- parse_attributes(attributes)
  results <- call_yelp_api(
    "businesses/search",
    access_token,
    term = term, location = location,
    latitude = latitude, longitude = longitude,
    radius = radius_m, categories = categories,
    locale = locale, limit = limit,
    offset = offset, sort_by = sort_by,
    price = price, open_now = open_now,
    open_at = open_at, attributes = attributes
  )
  map_df(results$businesses, business_object_to_df_row)
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
    alias = business$alias,
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
