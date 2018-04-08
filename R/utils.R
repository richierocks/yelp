# Convert NULL to empty character
null2empty <- function(x) {
  if(is.null(x)) "" else x
}

null2na <- function(x) {
  if(is.null(x)) NA_real_ else x
}

#' @importFrom purrr map_df
#' @importFrom purrr map_chr
#' @importFrom tibble data_frame
business_object_to_df_row <- function(business) {
  data_frame(
    id = business$id,
    name = business$name,
    rating = business$rating,
    review_count = business$review_count,
    price = business$price,
    image_url = business$image_url,
    is_closed = business$is_closed,
    url = business$url,
    category_aliases = list(map_chr(business$categories, function(x) x$alias)),
    category_titles = list(map_chr(business$categories, function(x) x$title)),
    latitude = business$coordinates$latitude,
    longitude = business$coordinates$longitude,
    distance_m = null2na(business$distance),
    transactions = list(as.character(business$transactions)),
    address1 = business$location$address1,
    address2 = null2empty(business$location$address2),
    address3 = null2empty(business$location$address3),
    city = null2empty(business$location$city),
    zip_code = null2empty(business$location$zip_code),
    state = null2empty(business$location$state),
    country = null2empty(business$location$country),
    display_address = list(as.character(business$location$display_address)),
    phone = business$phone,
    display_phone = business$display_phone
  )
}
