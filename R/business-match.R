#' Match a business
#'
#' Find a business, when you have precise info like name and address.
#'
#' @param name A string giving the name of the business.
#' @param city A string giving the city where the business is located.
#' @param state A string giving the ISO 3166-2 state code where the business is
#' located. See \code{\link{ISO_3166_2_CODES}}.
#' @param country A string giving the ISO 3166-2 country code where the business
#' is located. See \code{\link{ISO_3166_2_CODES}}.
#' @param address1 A string giving the address where the business is located.
#' Optional, but strongly recommended, especially when using
#' \code{match_threshold = "default"}.
#' @param address2 A string giving the address where the business is located.
#' @param address3 A string giving the address where the business is located.
#' @param latitude A number representing the latitude to search close to.
#' @param longitude A number representing the longitude to search close to.
#' @param phone A string representing a phone number. This should include the
#' country code and consist of a plus sign followed by only digits, for example
#' "+1234567890".
#' @param zip_code A string giving the zip or postal code where the business is
#' located.
#' @param yelp_business_id A string describing the Yelp ID of a business, as returned by
#' \code{\link{business_search}}.
#' @param match_threshold By default, matches are filtered rather strictly.
#' If you don't get any results, try setting this to \code{"none"}.
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @return A data frame with 13 columns. Each row corresponds to one business.
#' @references \url{https://www.yelp.com/developers/documentation/v3/business_match}
#' @examples
#' \donttest{
#' ## Marked as don't test because an access token is needed
#' walmart <- business_match("Walmart", "Albany", "NY", "US", "Washington Ave")
#' if(interactive()) View(walmart) else str(walmart)
#' }
#' @importFrom assertive.types assert_is_a_string
#' @export
business_match <- function(name, city, state, country, address1 = NULL,
  address2 = NULL, address3 = NULL, latitude = NULL, longitude = NULL,
  phone = NULL, zip_code = NULL, yelp_business_id = NULL,
  match_threshold = c("default", "none"),
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  assert_has_access_token(access_token)
  assert_is_a_string(name)
  assert_is_a_string(city)
  country_state <- parse_country_state(country, state)
  country <- country_state$country
  state <- country_state$state
  if(!is.null(address1)) {
    assert_is_a_string(address1)
  }
  if(!is.null(address2)) {
    assert_is_a_string(address2)
  }
  if(!is.null(address3)) {
    assert_is_a_string(address3)
  }
  if(!is.null(latitude)) {
    assert_all_are_in_closed_range(latitude, -90, 90)
  }
  if(!is.null(longitude)) {
    assert_all_are_in_closed_range(longitude, -180, 180)
  }
  if(!is.null(phone)) {
    assert_is_a_string(phone)
  }
  if(!is.null(zip_code)) {
    assert_is_a_string(zip_code)
  }
  if(!is.null(yelp_business_id)) {
    assert_is_a_string(yelp_business_id)
  }
  match_threshold <- match_arg(match_threshold)
  results <- call_yelp_api(
    "businesses/matches",
    access_token,
    name = name, city = city, state = state, country = country,
    address1 = address1, address2 = address2, address3 = address3,
    latitude = latitude, longitude = longitude,
    phone = phone, zip_code = zip_code,
    yelp_business_id = yelp_business_id, match_threshold = match_threshold
  )
  map_df(results$businesses, simple_business_object_to_df_row)
}

simple_business_object_to_df_row <- function(business) {
  data_frame(
    business_id = business$id,
    alias = business$alias,
    name = business$name,
    latitude = business$coordinates$latitude,
    longitude = business$coordinates$longitude,
    address1 = null2empty(business$location$address1),
    address2 = null2empty(business$location$address2),
    address3 = null2empty(business$location$address3),
    city = null2empty(business$location$city),
    zip_code = null2empty(business$location$zip_code),
    state = null2empty(business$location$state),
    country = null2empty(business$location$country),
    phone = business$phone
  )
}
