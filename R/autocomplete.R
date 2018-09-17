#' Get autocompletion suggestions
#'
#' Get term, business, and category autocompletion suggestions.
#' @param text A string to find completions for.
#' @param latitude A number representing the latitude to search close to.
#' Required if you want business results, but can be \code{NULL} otherwise.
#' @param longitude A number representing the longitude to search close to.
#' Required if you want business results, but can be \code{NULL} otherwise.
#' @param locale A string naming the locale. See \code{\link{SUPPORTED_LOCALES}}
#' for allowed values.
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @return A list of three elements.
#' \describe{
#' \item{terms}{A character vector of completion of the text itself}
#' \item{businesses}{A data frame of business name matches.}
#' \item{categories}{A data frame of category matches.}
#' }
#' @references \url{https://www.yelp.com/developers/documentation/v3/autocomplete}
#' @examples
#' \donttest{
#' ## Marked as don't test because an access token is needed
#' (sleep_in_seattle <- autocomplete(
#'   "sleep", latitude = 47.6, longitude = -122.33
#' ))
#' }
#' @export
autocomplete <- function(text, latitude = NULL, longitude = NULL,
  locale = "en_US", access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  assert_has_access_token(access_token)
  check_latitude(latitude)
  check_longitude(longitude)
  locale <- parse_locale(locale)
  results <- call_yelp_api(
    "autocomplete",
    access_token,
    text = text, latitude = latitude,
    longitude = longitude, locale = locale
  )
  flatten_completions(results)
}


flatten_completions <- function(completion) {
  list(
    terms = map_chr(completion$terms, function(x) x$text),
    businesses = data_frame(
      id = map_chr(completion$businesses, function(x) x$id),
      name = map_chr(completion$businesses, function(x) x$name)
    ),
    categories = data_frame(
      alias = map_chr(completion$categories, function(x) x$alias),
      title = map_chr(completion$categories, function(x) x$title)
    )
  )
}
