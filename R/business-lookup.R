#' Look up a business by Yelp ID
#'
#' Use the ID from a business search to get more details on that business.
#'
#' @param businesses A character vector describing the Yelp IDs of businesses,
#' as returned by \code{\link{business_search}},  or the data frame returned by
#' that API endpoint.
#' @param locale A string naming the locale. See \code{\link{SUPPORTED_LOCALES}}
#' for allowed values.
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @return A data frame with 28 columns. Each row corresponds to one business.
#' In addition to the fields provided by the business search, you also get
#' opening hours, URLs of up to 3 photos, whether or not the business has been
#' claimed by its owner, and whether or not the business has been permanently
#' closed.
#' @details If you pass multiple business IDs (either with a character vector
#' with length greater than one or a data frame with multiple rows), this will
#' result in multiple calls to the API, which you need to bear in mind if your
#' usage is limited.
#' @examples
#' \donttest{
#' ## Marked as don't test because an access token is needed
#' ghostbusters <- business_lookup("jDPKMwOtvPA0lkqRwRvSJQ")
#' if(interactive()) View(ghostbusters) else str(ghostbusters)
#' }
#' @importFrom assertive.types assert_is_a_string
#' @export
business_lookup <- function(businesses, locale = get_yelp_locale(),
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  if(is_yelp_business(businesses)) {
    business <- businesses$business_id
  }
  if(length(businesses) > 1L) {
    return(map_dfr(businesses, business_lookup, .id = "business_id"))
  }
  assert_has_access_token(access_token)
  assert_is_a_string(businesses)
  locale <- parse_locale(locale)
  results <- call_yelp_api(
    paste0("businesses/", businesses),
    access_token,
    locale = locale
  )
  business_object_to_df_row(results, detailed = TRUE)
}
