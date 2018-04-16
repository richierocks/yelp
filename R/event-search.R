#' @export
event_search <- function(location = NULL, latitude = NULL, longitude = NULL,
  radius_m = 40000, start_date = Sys.time(), end_date = Sys.time() + lubridate::ddays(7),
  is_free = NA, categories = NULL, locale = "en_US", limit = 50L, offset = 0L,
  sort_by = c("desc", "asc"), sort_on = c("popularity", "time_start"),
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  # excluded_events arg not yet supported because the syntax isn't clear.
  assert_has_access_token(access_token)
  location <- parse_location(location)
  check_latitude(latitude)
  check_longitude(longitude)
  radius_m <- parse_radius_m(radius_m)
  start_date <- to_unix_time(start_date)
  end_date <- to_unix_time(end_date)
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
    is_free = is_free, location = location, radius = radius_m
  )
  map_df(results$events, event_to_df_row)
}

#' importFrom magrittr %$%
#' importFrom tibble data_frame
event_to_df_row <- function(event) {
  event %$%
    data_frame(
      id = id,
      name = name,
      category = category,
      description = description,
      is_free = is_free,
      cost = null2na(cost),
      cost_max = null2na(cost_max),
      business_id = null2empty(business_id),
      event_site_url = event_site_url,
      image_url = image_url,
      tickets_url = null2empty(tickets_url),
      interested_count = interested_count,
      attending_count = attending_count,
      # Ideally these times would be parsed, but they are local to the location
      # and the time zone isn't provide in the API response.
      time_start = null2empty(time_start),
      time_end = null2empty(time_end),
      is_canceled = is_canceled,
      is_official = is_official,
      address1 = location$address1,
      address2 = null2empty(location$address2),
      address3 = null2empty(location$address3),
      city = null2empty(location$city),
      zip_code = null2empty(location$zip_code),
      state = null2empty(location$state),
      country = null2empty(location$country),
      display_address = null2empty(location$display_address),
      cross_streets = null2empty(location$cross_streets)
    )
}

