#' Get reviews for a business
#'
#' Get the Yelp reviews associated with a business ID.
#'
#' @param business_id A string denoting a Yelp business ID, as returned by
#' the business search API.
#' @param locale A string naming the locale. See \code{\link{SUPPORTED_LOCALES}}
#' for allowed values.
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @return A tibble with 6 columns. Each row corresponds to one review of the
#' specified business.
#' @references \url{https://www.yelp.com/developers/documentation/v3/business_reviews}
#' @examples
#' \donttest{
#' ## Marked as don't test because an access token is needed
#' # First lookup businesses
#' theaters_in_chicago <- business_search("theater", "chicago")
#' # Examine the ID column to get the business ID
#' theaters_in_chicago$id
#' reviews_of_chicago_theater <- reviews("chicago-theatre-chicago")
#' if(interactive())
#'   View(reviews_of_chicago_theater) else str(reviews_of_chicago_theater)
#' }
#' @importFrom assertive.types assert_is_a_string
#' @importFrom purrr map_df
#' @export
reviews <- function(business_id, locale = "en_US",
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  assert_has_access_token(access_token)
  assert_is_a_string(business_id)
  locale <- match.arg(locale, SUPPORTED_LOCALES)
  endpoint <- sprintf(
    "https://api.yelp.com/v3/businesses/%s/reviews",
    business_id
  )
  results <- call_yelp_api(
    endpoint,
    access_token,
    locale = locale
  )
  map_df(
    results$reviews,
    review_object_to_df_row
  )
}



