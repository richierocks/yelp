# Convert NULL to empty character
n2e <- function(x) {
  if(is.null(x)) "" else x
}
