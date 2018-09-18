#' Set a default locale
#'
#' Sets a default locale for the R session.
#' @param locale A string naming the locale. See \code{\link{SUPPORTED_LOCALES}}
#' for allowed values.
#' @return Invoked for the side-effect of setting an environment variable to
#' store the default locale. The previous value of this variable is invisibly
#' returned.
#' @examples
#' set_yelp_locale("zh_HK")
#' @export
set_yelp_locale <- function(locale) {
  old_locale <- Sys.getenv("YELP_LOCALE")
  on.exit(invisible(old_locale))
  locale <- parse_locale(locale)
  Sys.setenv(YELP_LOCALE = locale)
}
