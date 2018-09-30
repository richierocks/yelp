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
#' @return A data frame with 6 columns. Each row corresponds to one review of the
#' specified business.
#' @references \url{https://www.yelp.com/developers/documentation/v3/business_reviews}
#' @examples
#' \donttest{
#' ## Marked as don't test because an access token is needed
#' # First lookup businesses
#' theaters_in_chicago <- business_search("theater", "chicago")
#' # Get the reviews using the business ID
#' reviews_of_chicago_theater_id <- reviews(theaters_in_chicago$id[1L])
#' # ...or the alias
#' reviews_of_chicago_theater_alias <- reviews(theaters_in_chicago$alias[1L])
#' identical(
#'   reviews_of_chicago_theater_id,
#'   reviews_of_chicago_theater_alias
#' )
#' if(interactive())
#'   View(reviews_of_chicago_theater_id) else str(reviews_of_chicago_theater_id)
#' }
#' @importFrom assertive.types assert_is_a_string
#' @importFrom purrr map_df
#' @export
reviews <- function(business, locale = get_yelp_locale(),
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  assert_has_access_token(access_token)
  if(is_yelp_business(business)) {
    business <- business$business_id
  }
  if(length(business) > 1L) {
    return(map_dfr(business, reviews, .id = "business_id"))
  }
  assert_is_a_string(business)
  locale <- parse_locale(locale)
  endpoint <- sprintf(
    "businesses/%s/reviews",
    business
  )
  results <- call_yelp_api(
    endpoint,
    access_token,
    locale = locale
  )
  map_df(results$reviews, review_object_to_df_row)
}

#' @param review A list, as returned by the review search API.
#' @importFrom tibble data_frame
#' @noRd
review_object_to_df_row <- function(review) {
  data_frame(
    review_id = review$id,
    rating = to_stars(review$rating),
    text = review$text,
    time_created = review$time_created,
    url = review$url,
    user_image_url = null2empty(review$user$image_url),
    user_name = review$user$name
  )
}



