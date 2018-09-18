#' Describe category alias
#'
#' Provides detailed information about a category alias.
#' @param alias An alias for a search category, chosen from
#' \code{SUPPORTED_CATEGORY_ALIASES}.
#' @param locale A string naming the locale. See \code{\link{SUPPORTED_LOCALES}}
#' for allowed values.
#' @return A data frame with 1 row and 5 columns.
#' @references \url{https://www.yelp.com/developers/documentation/v3/category}
#' @examples
#' \donttest{
#' ## Marked as don't test because an access token is needed
#' categories("barcrawl")
#' categories("drug")
#' }
#' @importFrom purrr map_df
#' @export
categories <- function(alias, locale = get_yelp_locale(),
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  assert_has_access_token(access_token)
  locale <- parse_locale(locale)
  alias <- match.arg(alias, SUPPORTED_CATEGORY_ALIASES)
  results <- call_yelp_api(
    paste0("categories/", alias),
    access_token,
    locale = locale
  )
  category_object_to_df_row(results$category)
}

category_object_to_df_row <- function(category) {
  data_frame(
    alias = category$alias,
    title = category$title,
    parent_aliases = list(as.character(category$parent_aliases)),
    country_whitelist = list(as.character(category$country_whitelist)),
    country_blacklist = list(as.character(category$country_blacklist))
  )
}
