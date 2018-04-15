
# @examples
# business_match_lookup("Walmart", "Albany", "NY", "US")
#' @export
business_match_lookup <- function(name, city, state, country, address1 = NULL,
  address2 = NULL, address3 = NULL, latitude = NULL, longitude = NULL,
  phone = NULL, postal_code = NULL, yelp_business_id = NULL,
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  assert_has_access_token(access_token)
  assert_is_a_string(name)
  assert_is_a_string(city)
  assert_is_a_string(state)
  assert_is_a_string(country)
  state <- toupper(state)
  country <- toupper(country)
  match.arg(paste(country, state, sep = "-"), ISO_3166_2_CODES)
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
  if(!is.null(postal_code)) {
    assert_is_a_string(postal_code)
  }
  if(!is.null(yelp_business_id)) {
    assert_is_a_string(yelp_business_id)
  }
  results <- call_yelp_api(
    "businesses/matches/lookup",
    access_token,
    name = name, city = city, state = state, country = country,
    address1 = address1, address2 = address2, address3 = address3,
    latitude = latitude, longitude = longitude,
    phone = phone, postal_code = postal_code,
    yelp_business_id = yelp_business_id
  )
  map_df(results$businesses, simple_business_object_to_df_row)
}

simple_business_object_to_df_row <- function(business) {
  data_frame(
    id = business$id,
    name = business$name,
    alias = business$alias,
    latitude = business$coordinates$latitude,
    longitude = business$coordinates$longitude,
    address1 = null2empty(business$location$address1),
    address2 = null2empty(business$location$address2),
    address3 = null2empty(business$location$address3),
    city = null2empty(business$location$city),
    # Calling this zip code rather than postal_code for
    # consistency with, e.g., business_search() & business_lookup()
    zip_code = null2empty(business$location$postal_code),
    state = null2empty(business$location$state),
    country = null2empty(business$location$country),
    phone = business$phone
  )
}