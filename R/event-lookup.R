#' Look up an event by Yelp ID
#'
#' Use the ID from a business search to return only details for that business.
#' @param event_id A string denoting a Yelp event ID, as returned by
#' \code{\link{event_search}}.
#' @param locale A string naming the locale. See \code{\link{SUPPORTED_LOCALES}}
#' for allowed values.
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @return A data frame with 1 row and 28 columns.
#' @examples
#' \donttest{
#' ## Marked as don't test because an access token is needed
#' # First search for events
#' events_in_kansas_city <- event_search("kansas city")
#' # Use the returned ID to lookup a specific event
#' the_main_event <- event_lookup(events_in_kansas_city$id[1L])
#' if(interactive()) View(the_main_event) else str(the_main_event)
#' }
#' @importFrom purrr is_empty
#' @export
event_lookup <- function(events, locale = get_yelp_locale(),
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  if(is_yelp_event(events)) {
    events <- events$event_id
  }
  if(length(events) > 1L) {
    return(map_df(events, event_lookup, .id = "event_id"))
  }
  assert_has_access_token(access_token)
  assert_is_a_string(events)
  locale <- parse_locale(locale)
  results <- call_yelp_api(
    paste0("events/", events),
    access_token,
    locale = locale
  )
  if(is_empty(results)) return(data_frame())
  event_to_df_row(results)
}