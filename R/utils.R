#' Call the Yelp api
#'
#' @param endpoint A string describing the URL to access.
#' @param access_token A string giving an access token to authenticate the API
#' call. See \code{\link{get_access_token}}.
#' @return A list. The exact contents depend upon the endpoint.
#' @importFrom httr add_headers
#' @importFrom httr GET
#' @importFrom httr stop_for_status
#' @importFrom httr content
#' @noRd
call_yelp_api <- function(endpoint, access_token, ...) {
  query <- list(...)
  response <- GET(
    paste0("https://api.yelp.com/v3/", endpoint),
    config = add_headers(Authorization = paste("bearer", access_token)),
    query = query
  )
  handle_id_migration(response)
  stop_for_status(response)
  content(response, as = "parsed")
}

#' Deal with ID migration
#'
#' If duplicate businesses are merged, one ID redirects to the other.
#' This manifests as an HTTP 301 code.
#' @param response The result of a GET() call to the Yelp API.
#' @references \url{https://www.yelp.com/developers/documentation/v3/business_reviews#response-business-migrated}
#' @importFrom httr status_code
#' @importFrom httr content
#' @importFrom magrittr %$%
handle_id_migration <- function(response) {
  if(status_code(response) == 301) {
    contents <- content(response, as = "parsed")
    msg <- paste0(
      contents$error$description,
      "\nNew ID: ",
      contents$error$new_business_id
    )
    stop(msg, call. = FALSE)
  }
}

# Fixup responses ---------------------------------------------------------

# Convert NULL to empty character
null2empty <- function(x) {
  if(is.null(x)) "" else x
}

null2na <- function(x) {
  if(is.null(x)) NA_real_ else x
}

number2weekday <- function(x) {
  switch(
    as.character(x),
    "0" = , "7" = "Monday",
    "1" = "Tuesday",
    "2" = "Wednesday",
    "3" = "Thursday",
    "4" = "Friday",
    "5" = "Saturday",
    "6" = "Sunday"
  )
}

# Fixup dates -------------------------------------------------------------

to_unix_time <- function(x) {
  as.integer(as.POSIXct(x))
}

# Fix up ratings

to_stars <- function(x) {
  ordered(x, levels = seq.int(0, 5, 0.5))
}

# Check inputs ------------------------------------------------------------

#' @importFrom assertive.numbers assert_all_are_in_closed_range
#' @noRd
check_latitude <- function(latitude, null_is_ok = TRUE) {
  if(is.null(latitude) && null_is_ok) {
    return()
  }
  assert_all_are_in_closed_range(latitude, -90, 90)
}

#' @importFrom assertive.numbers assert_all_are_whole_numbers
#' @importFrom assertive.numbers assert_all_are_in_closed_range
#' @noRd
check_limit <- function(limit) {
  assert_all_are_whole_numbers(limit, tol = 0)
  assert_all_are_in_closed_range(limit, 0, 50)
}

#' @importFrom assertive.numbers assert_all_are_in_closed_range
#' @noRd
check_longitude <- function(longitude, null_is_ok = TRUE) {
  if(is.null(longitude) && null_is_ok) {
    return()
  }
  assert_all_are_in_closed_range(longitude, -180, 180)
}

#' @importFrom assertive.numbers assert_all_are_whole_numbers
#' @importFrom assertive.numbers assert_all_are_non_negative
#' @noRd
check_offset <- function(offset) {
  assert_all_are_whole_numbers(offset, tol = 0)
  assert_all_are_non_negative(offset)
}

#' @importFrom assertive.types assert_is_a_string
#' @importFrom assertive.strings assert_all_are_matching_regex
#' @noRd
check_phone <- function(phone) {
  assert_is_a_string(phone)
  # Match START %R% PLUS %R% dgt(1, Inf) %R% END
  assert_all_are_matching_regex(phone, "^\\+\\d+$")
}


# Test types --------------------------------------------------------------

#' Is the input a Yelp business?
#'
#' @param x An R variable.
#' @return \code{TRUE} if the result is a data frame with a character column
#' named \code{business_id}.
is_yelp_business <- function(x) {
  is.data.frame(x) &&
    "business_id" %in% colnames(x) &&
    class(x$business_id) == "character" &&
    all(nchar(x$business_id) == 22L)
}

is_yelp_event <- function(x) {
  is.data.frame(x) &&
    "event_id" %in% colnames(x) &&
    class(x$event_id) == "character"
  # Character length is variable; don't check it
}


# Improve inputs ----------------------------------------------------------

parse_attributes <- function(attributes) {
  if(is.null(attributes)) {
    return()
  }
  attributes <- match.arg(
    attributes, SUPPORTED_BUSINESS_ATTRIBUTES, several.ok = TRUE
  )
  paste0(attributes, collapse = ",")
}

parse_categories <- function(categories) {
  if(is.null(categories)) {
    return()
  }
  categories <- match.arg(
    categories, SUPPORTED_CATEGORY_ALIASES, several.ok = TRUE
  )
  paste0(categories, collapse = ",")
}

#' @importFrom assertive.types assert_is_a_string
#' @importFrom magrittr %>%
#' @importFrom stats setNames
#' @noRd
parse_country_state <- function(country, state) {
  assert_is_a_string(country)
  country <- toupper(country)
  assert_is_a_string(state)
  state <- toupper(state)
  # Need to check in form "country-state", but return individual components
  country_state <- match_arg(paste(country, state, sep = "-"), ISO_3166_2_CODES)
  strsplit(country_state, split = "-")[[1]] %>%
    setNames(c("country", "state")) %>%
    as.list()
}

#' importFrom assertive.types assert_is_a_bool
#' @noRd
parse_is_free <- function(is_free) {
  assert_is_a_bool(is_free)
  if(is.na(is_free)) {
    return()
  }
}

parse_locale <- function(locale) {
  match_arg(locale, SUPPORTED_LOCALES)
}

parse_location <- function(location) {
  if(is.null(location)) {
    return()
  }
  paste0(location, collapse = ", ")
}

#' @importFrom assertive.sets assert_is_subset
#' @noRd
parse_price <- function(price) {
  assert_is_subset(price, 1:4)
  paste0(price, collapse = ",")
}

#' @importFrom assertive.numbers assert_all_are_in_closed_range
#' @noRd
parse_radius_m <- function(radius_m) {
  radius_m <- as.integer(radius_m)
  assert_all_are_in_closed_range(radius_m, 0, 40000)
}


# better error for match.arg ----------------------------------------------

#' @importFrom utils adist
find_nearest_string <- function(x, choices) {
  scores <- adist(x, choices, ignore.case = TRUE, partial = TRUE)
  choices[which.min(scores)]
}

get_arg_default <- function(xname) {
  # Adapted from match.arg()
  parent_fn_index <- sys.parent(2)
  formal_args <- formals(sys.function(parent_fn_index))
  eval(formal_args[[xname]], sys.frame(parent_fn_index))
}

#' @importFrom assertive.base get_name_in_parent
match_arg <- function(x, choices = NULL) {
  xname <- get_name_in_parent(x)
  if(is.null(choices)) {
    choices <- get_arg_default(xname)
  }
  tryCatch(
    match.arg(x, choices),
    error = function(e) {
      stop(
        sprintf('%s\nDid you mean `%s = "%s"`?',
          e$message,
          xname,
          find_nearest_string(x, choices)
        ),
        call. = FALSE
      )
    }
  )
}

