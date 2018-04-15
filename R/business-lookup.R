#' Look up a business by Yelp ID
#'
#' @param id A string describing the Yelp ID of a business, as returned by
#' \code{\link{business_search}}.
#'
#' @return A data frame of detailed business information. In addition to the
#' fields provided by the business search, you also get opening hours,
#' URLs of up to 3 photos, whether or not the business has been claimed by
#' its owner, and whether or not the business has been permanently closed.
#' @examples
#' business_lookup("jDPKMwOtvPA0lkqRwRvSJQ")
#' @importFrom assertive.types assert_is_a_string
#' @export
business_lookup <- function(id, locale = "en_US",
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  assert_has_access_token(access_token)
  assert_is_a_string(id)
  locale <- parse_locale(locale)
  results <- call_yelp_api(
    paste0("businesses/", id),
    access_token,
    locale = locale
  )
  business_object_to_df_row(results, detailed = TRUE)
}
