#' Find businesses by phone number
#'
#' Finds businesses with a particular phone number.
#' @param phone A string representing a phone number. This should include the
#' country code and consist of a plus sign followed by only digits, for example
#' "+1234567890".
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @return A data frame with 24 columns. Each row corresponds to one business.
#'
#' Note that there may be more than one business returned, for example where
#' multiple stores share a central phone number.
#' @references \url{https://www.yelp.com/developers/documentation/v3/business_search_phone}
#' @examples
#' \donttest{
#' ## Marked as don't test because an access token is needed
#' call_me <- phone_search("+12127052000")
#' if(interactive()) View(call_me) else str(call_me)
#' }
#' @importFrom purrr map_df
#' @export
phone_search <- function(phone,
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  assert_has_access_token(access_token)
  check_phone(phone)
  results <- call_yelp_api(
    "businesses/search/phone",
    access_token,
    phone = phone
  )
  map_df(results$businesses, business_object_to_df_row)
}

