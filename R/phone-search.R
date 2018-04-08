#' Find businesses by phone number
#'
#' Finds businesses with a particular phone number.
#' @param phone A string representing a phone number. This should include the
#' country code and consist of a plus sign followed by only digits, for example
#' "+1234567890".
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @return A data frame of business results. Note that there may be more than
#' one business returned, for example where multiple stores share a central
#' phone number.
#' @references \url{https://www.yelp.com/developers/documentation/v3/business_search_phone}
#' @examples
#' \donttest{
#' ## Marked as don't test because an access token is needed
#'   phone_search("+12127052000")
#' }
#' @importFrom httr add_headers
#' @importFrom httr GET
#' @importFrom httr stop_for_status
#' @importFrom httr content
#' @export
phone_search <- function(phone,
  access_token = Sys.getenv("YELP_ACCESS_TOKEN", NA)) {
  if(is.na(access_token)) {
    stop("No Yelp API access token was found. See ?get_access_token.")
  }
  # Match START %R% PLUS %R% dgt(1, Inf) %R% END
  assertive.strings::assert_all_are_matching_regex(phone, "^\\+\\d+$")
  response <- GET(
    "https://api.yelp.com/v3/businesses/search/phone",
    config = add_headers(Authorization = paste("bearer", access_token)),
    query = list(phone = phone)
  )
  stop_for_status(response)
  results <- content(response, as = "parsed")
  map_df(results$businesses, business_object_to_df_row)
}

