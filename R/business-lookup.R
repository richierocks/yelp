#' Look up a business by Yelp ID
#'
#' @param yelp_business_id A string describing the Yelp ID of a business, as returned by
#' \code{\link{business_search}}.
#' @param locale A string naming the locale. See \code{\link{SUPPORTED_LOCALES}}
#' for allowed values.
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @return A data frame with 28 columns. Each row corresponds to one business.
#' In addition to the fields provided by the business search, you also get
#' opening hours, URLs of up to 3 photos, whether or not the business has been
#' claimed by its owner, and whether or not the business has been permanently
#' closed.
#' @examples
#' \donttest{
#' ## Marked as don't test because an access token is needed
#' ghostbusters <- business_lookup("jDPKMwOtvPA0lkqRwRvSJQ")
#' if(interactive()) View(ghostbusters) else str(ghostbusters)
#' }
#' @importFrom assertive.types assert_is_a_string
#' @export
business_lookup <- function(yelp_business_id, locale = Sys.getenv("YELP_LOCALE", "en_US"),
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  assert_has_access_token(access_token)
  assert_is_a_string(yelp_business_id)
  locale <- parse_locale(locale)
  results <- call_yelp_api(
    paste0("businesses/", yelp_business_id),
    access_token,
    locale = locale
  )
  business_object_to_df_row(results, detailed = TRUE)
}
