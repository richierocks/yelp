library(httr)
#' Get or store an access token
#'
#' \code{get_access_token} gets an access token for the API. To obtain the
#' client ID and client secret, you need to create a Yelp app. This is free, and
#' takes about 10 minutes. Go to
#' \url{https://www.yelp.com/developers/documentation/v3/authentication} for
#' instructions.
#' \code{store_access_token} stores the access token as an environment variable.
#' @param client_id A string giving the Client ID.
#' @param client_Secret A string giving the client secret.
#' @return A string giving the access token.
#' @references \url{https://www.yelp.com/developers/documentation/v3/authentication}
#' @examples
#' \dontrun{
#' (access_token <- get_access_token())
#' store_access_token(access_token)
#' }
#' @importFrom httr POST
#' @importFrom httr stop_for_status
#' @importFrom httr content
#' @export
get_access_token <- function(client_id, client_secret) {
  if(client_id == "") {
    stop("You need to provide a client ID.")
  }
  if(client_secret == "") {
    stop("You need to provide a client secret.")
  }
  response <- POST(
    "https://api.yelp.com/oauth2/token",
    query = list(
      grant_type = "client_credentials",
      client_id = client_id,
      client_secret = client_secret
    ),
    encode = "json"
  )
  stop_for_status(response)
  token <- content(response, as = "parsed")
  token$access_token
}

#' @rdname get_access_token
#' @export
store_access_token <- function(access_token) {
  Sys.setenv(YELP_ACCESS_TOKEN = access_token)
}
