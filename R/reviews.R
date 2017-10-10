#' Get reviews for a business
#'
#' @param business_id A string denoting a Yelp business ID, as returned by
#' the business search API.
#' @param locale A string naming the locale. See \code{\link{SUPPORTED_LOCALES}}
#' for allowed values.
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @return A tibble with 6 columns. Each row corresponds to one review of the
#' specified business.
#' @examples
#'
#' \donttest{
#' ## Marked as don't test because an access token is needed
#' # First lookup businesses
#' theaters_in_chicago <- business_search("theater", "chicago")
#' # Examine the ID column to get the business ID
#' theaters_in_chicago$id
#' reviews_of_chicago_theater <- reviews("chicago-theatre-chicago")
#' if(interactive())
#'   View(reviews_of_chicago_theater) else reviews_of_chicago_theater
#' }
#' @importFrom assertive.types assert_is_a_string
#' @importFrom httr add_headers
#' @importFrom httr GET
#' @importFrom httr stop_for_status
#' @importFrom httr content
#' @importFrom purrr map_df
#' @importFrom tibble data_frame
#' @export
reviews <- function(business_id, locale = "en_US",
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  if(is.na(access_token)) {
    stop("No Yelp API access token was found. See ?get_access_token.")
  }
  assert_is_a_string(business_id)
  locale <- match.arg(locale, SUPPORTED_LOCALES)
  endpoint <- sprintf(
    "https://api.yelp.com/v3/businesses/%s/reviews",
    business_id
  )
  response <- GET(
    endpoint,
    config = add_headers(Authorization = paste("bearer", access_token)),
    query = list(locale = locale)
  )
  stop_for_status(response)
  results <- content(response, as = "parsed")
  map_df(
    results$reviews,
    function(review) {
      data_frame(
        rating = review$rating,
        text = review$text,
        time_created = review$time_created,
        url = review$url,
        user_image_url = n2e(review$user$image_url),
        user_name = review$user$name
      )
    }
  )
}



