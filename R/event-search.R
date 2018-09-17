#' Search for events
#'
#' Use the Yelp event search API to find events near a given location and in
#' a given time range.
#' @param location A string describing the location.
#' @param latitude A number representing the latitude to search close to.
#' @param longitude A number representing the longitude to search close to.
#' @param radius_m A number giving the radius, in metres, of the search circle
#' around the specified location.
#' @param datetime_start A date-time object coercible to \code{POSIXct} representing
#' the earliest time for events.
#' @param datetime_end A date-time object coercible to \code{POSIXct} representing
#' the latest time for events.
#' @param is_free Logical. Set to \code{TRUE} to return only cost-free events,
#' \code{FALSE} to return only paid event, and \code{NA} for both.
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
#' @param sort_on Should the return values be sorted by \code{"popularity"} or
#' \code{"datetime_start"}?
#' @param sort_by TODO
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @importFrom purrr map_df
#' @export
event_search <- function(location = NULL, latitude = NULL, longitude = NULL,
  radius_m = 40000, datetime_start = Sys.time(),
  datetime_end = datetime_start + lubridate::ddays(7), is_free = NA,
  categories = NULL, locale = "en_US", limit = 50L, offset = 0L,
  sort_on = c("popularity", "time_start"), sort_by = c("desc", "asc"),
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  # excluded_events arg not yet supported because the syntax isn't clear.
  assert_has_access_token(access_token)
  location <- parse_location(location)
  check_latitude(latitude)
  check_longitude(longitude)
  radius_m <- parse_radius_m(radius_m)
  start_date <- to_unix_time(datetime_start)
  end_date <- to_unix_time(datetime_end)
  locale <- parse_locale(locale)
  check_limit(limit)
  check_offset(offset)
  sort_by <- match.arg(sort_by)
  sort_on <- match.arg(sort_on)
  categories <- parse_categories(categories)
  is_free <- parse_is_free(is_free)
  results <- call_yelp_api(
    "events",
    access_token,
    locale = locale, offset = offset, limit = limit,
    sort_by = sort_by, sort_on = sort_on,
    start_date = start_date, end_date = end_date,
    is_free = is_free, location = location,
    latitude = NULL, longitude = NULL, radius = radius_m
  )
  map_df(results$events, event_to_df_row)
}

#' @importFrom tibble data_frame
event_to_df_row <- function(event) {
  data_frame(
    id = event$id,
    name = event$name,
    category = event$category,
    description = event$description,
    is_free = event$is_free,
    cost = null2na(event$cost),
    cost_max = null2na(event$cost_max),
    business_id = null2empty(event$business_id),
    event_site_url = event$event_site_url,
    image_url = event$image_url,
    tickets_url = null2empty(event$tickets_url),
    interested_count = event$interested_count,
    attending_count = event$attending_count,
    # Ideally these times would be parsed, but they are local to the location
    # and the time zone isn't provide in the API response.
    time_start = null2empty(event$time_start),
    time_end = null2empty(event$time_end),
    is_canceled = event$is_canceled,
    is_official = event$is_official,
    address1 = event$location$address1,
    address2 = null2empty(event$location$address2),
    address3 = null2empty(event$location$address3),
    city = null2empty(event$location$city),
    zip_code = null2empty(event$location$zip_code),
    state = null2empty(event$location$state),
    country = null2empty(event$location$country),
    display_address = null2empty(event$location$display_address),
    cross_streets = null2empty(event$location$cross_streets)
  )
}

