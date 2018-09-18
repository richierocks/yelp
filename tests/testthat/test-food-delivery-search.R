context("food_delivery_search")

old_token <- set_token()

test_results_have_correct_form(
  food_delivery_search("white house"),
  c("id", "alias", "name", "rating", "review_count", "price", "image_url",
    "is_closed", "url", "category_aliases", "category_titles", "latitude",
    "longitude", "distance_m", "transactions", "address1", "address2",
    "address3", "city", "zip_code", "state", "country", "display_address",
    "phone", "display_phone"),
  c("character", "character", "character", "numeric", "integer",
    "character", "character", "logical", "character", "list", "list",
    "numeric", "numeric", "numeric", "list", "character", "character",
    "character", "character", "character", "character", "character",
    "character", "character", "character")
)

unset_token(old_token)
