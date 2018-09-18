#' Find featured events
#'
#' List the featured events for a location, as curated by the Yelp staff.
#' @param location A string describing the location.
#' @param latitude A number representing the latitude to search close to.
#' @param longitude A number representing the longitude to search close to.
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @return A data frame with 26 columns. Each row corresponds to one event.
#' @references \url{https://www.yelp.com/developers/documentation/v3/event_search}
#' @examples
#' \donttest{
#' ## Marked as don't test because an access token is needed
#' the_only_show_in_town <- featured_events("broadway, manhattan, new york")
#' if(interactive()) View(the_only_show_in_town) else str(the_only_show_in_town)
#' }
#' @importFrom purrr map_df
#' @export
featured_events <- function(location = NULL, latitude = NULL, longitude = NULL,
  locale = "en_US", access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  assert_has_access_token(access_token)
  location <- parse_location(location)
  check_latitude(latitude)
  check_longitude(longitude)
  locale <- parse_locale(locale)
  results <- call_yelp_api(
    "events/featured",
    access_token,
    locale = locale, location = location,
    latitude = latitude, longitude = longitude
  )
  # It appears that unlike the events endpoint, there is only ever
  #  a single featured event
  event_to_df_row(results)
}
