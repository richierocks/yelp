#' Look up an event by Yelp ID
#'
#' Use the ID from a business search to return only details for that business.
#' @param yelp_event_id A string denoting a Yelp event ID, as returned by
#' \code{\link{event_search}}.
#' @param locale A string naming the locale. See \code{\link{SUPPORTED_LOCALES}}
#' for allowed values.
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @return A data frame with 1 row and 26 columns.
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
event_lookup <- function(yelp_event_id, locale = get_yelp_locale(), access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  assert_has_access_token(access_token)
  assert_is_a_string(yelp_event_id)
  locale <- parse_locale(locale)
  results <- call_yelp_api(
    paste0("events/", yelp_event_id),
    access_token,
    locale = locale
  )
  if(is_empty(results)) return(data_frame())
  event_to_df_row(results)
}