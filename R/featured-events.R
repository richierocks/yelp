#' Find featured events
#'
#' List the featured events for a location, as curated by the Yelp staff.
#' @param location A string describing the location.
#' @param latitude A number representing the latitude to search close to.
#' @param longitude A number representing the longitude to search close to.
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @references \url{https://www.yelp.com/developers/documentation/v3/event_search}
#' @importFrom purrr map_df
#' @export
featured_events <- function(location = NULL, latitude = NULL, longitude = NULL,
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  assert_has_access_token(access_token)
  location <- parse_location(location)
  check_latitude(latitude)
  check_longitude(longitude)
  results <- call_yelp_api(
    "events/featured",
    access_token,
    locale = locale, location = location,
    latitude = latitude, longitude = longitude
  )
  map_df(results$events, event_to_df_row)
}
