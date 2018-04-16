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


# Fixup responses ---------------------------------------------------------

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

# Fixup dates -------------------------------------------------------------

to_unix_time <- function(x) {
  as.integer(as.POSIXct(x))
}

# Check inputs ------------------------------------------------------------

#' @importFrom assertive.numbers assert_all_are_in_closed_range
check_latitude <- function(latitude, null_is_ok = TRUE) {
  if(is.null(latitude) && null_is_ok) {
    return()
  }
  assert_all_are_in_closed_range(latitude, -90, 90)
}

#' @importFrom assertive.numbers assert_all_are_whole_numbers
#' @importFrom assertive.numbers assert_all_are_in_closed_range
check_limit <- function(limit) {
  assert_all_are_whole_numbers(limit, tol = 0)
  assert_all_are_in_closed_range(limit, 0, 50)
}

#' @importFrom assertive.numbers assert_all_are_in_closed_range
check_longitude <- function(longitude, null_is_ok = TRUE) {
  if(is.null(longitude) && null_is_ok) {
    return()
  }
  assert_all_are_in_closed_range(longitude, -180, 180)
}

#' @importFrom assertive.numbers assert_all_are_whole_numbers
#' @importFrom assertive.numbers assert_all_are_non_negative
check_offset <- function(offset) {
  assert_all_are_whole_numbers(offset, tol = 0)
  assert_all_are_non_negative(offset)
}

#' @importFrom assertive.types assert_is_a_string
#' @importFrom assertive.strings assert_all_are_matching_regex
check_phone <- function(phone) {
  assert_is_a_string(phone)
  # Match START %R% PLUS %R% dgt(1, Inf) %R% END
  assert_all_are_matching_regex(phone, "^\\+\\d+$")
}

# Improve inputs ----------------------------------------------------------

parse_attributes <- function(attributes) {
  if(is.null(attributes)) {
    return()
  }
  attributes <- match.arg(
    attributes, SUPPORTED_BUSINESS_ATTRIBUTES, several.ok = TRUE
  )
  paste0(attributes, collapse = ",")
}

parse_categories <- function(categories) {
  if(is.null(categories)) {
    return()
  }
  categories <- match.arg(
    categories, SUPPORTED_CATEGORY_ALIASES, several.ok = TRUE
  )
  paste0(categories, collapse = ",")
}

#' importFrom assertive.types assert_is_a_bool
parse_is_free <- function(is_free) {
  assert_is_a_bool(is_free)
  if(is.na(is_free)) {
    return()
  }
}

parse_locale <- function(locale) {
  match.arg(locale, SUPPORTED_LOCALES)
}

parse_location <- function(location) {
  if(is.null(location)) {
    return()
  }
  paste0(location, collapse = ", ")
}

#' @importFrom assertive.sets assert_is_subset
parse_price <- function(price) {
  assert_is_subset(price, 1:4)
  paste0(price, collapse = ",")
}

#' @importFrom assertive.numbers assert_all_are_in_closed_range
parse_radius_m <- function(radius_m) {
  radius_m <- as.integer(radius_m)
  assert_all_are_in_closed_range(radius_m, 0, 40000)
}
