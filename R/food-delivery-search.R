#' Find food delivery services
#'
#' Find services that deliver food to a specified location in the USA.
#' @param location A string describing the building or other precise location.
#' If this is not provided, then \code{latitude} and \code{longitude} are compulsory.
#' @param latitude A number representing the latitude to search close to.
#' @param longitude A number representing the longitude to search close to.
#' @references \url{https://www.yelp.com/developers/documentation/v3/transaction_search}
#' @examples
#' \donttest{
#' ## Marked as don't test because an access token is needed
#' lunchtime <- food_delivery_search("empire state building")
#' if(interactive()) View(lunchtime) else str(lunchtime)
#' }
#' @importFrom purrr map_df
#' @export
food_delivery_search <- function(location, latitude = NULL, longitude = NULL,
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  assert_has_access_token(access_token)
  if(!is.null(location)) {
    location <- parse_location(location)
  } else {
    check_latitude(latitude, null_is_ok = FALSE)
    check_longitude(longitude, null_is_ok = FALSE)
  }
  results <- call_yelp_api(
    "transactions/delivery/search",
    access_token,
    location = location, latitude = latitude, longitude = longitude
  )
  map_df(results$businesses, business_object_to_df_row)
}
