#' Get or set a default locale
#'
#' Gets or sets a default locale for the R session.
#' @param locale A string naming the locale. See \code{\link{SUPPORTED_LOCALES}}
#' for allowed values.
#' @return \code{set_yelp_locale} is invoked for the side-effect of setting an
#' environment variable to store the default locale. The previous value of this
#' variable is invisibly returned.
#' \code{get_yelp_locale} gets the current yelp locale from the environment,
#' defaulting to \code{"en_US"} if it has not been set.
#' @details The locale is stored in an environment variable named
#' \code{YELP_LOCALE}.
#' @seealso \code{\link{SUPPORTED_LOCALES}}
#' @examples
#' set_yelp_locale("zh_HK")
#' @export
set_yelp_locale <- function(locale = "en_US") {
  old_locale <- get_yelp_locale()
  locale <- parse_locale(locale)
  Sys.setenv(YELP_LOCALE = locale)
  invisible(old_locale)
}

#' @rdname set_yelp_locale
#' @export
get_yelp_locale <- function() {
  Sys.getenv("YELP_LOCALE", "en_US")
}
