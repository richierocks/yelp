context("food_delivery_search")

old_token <- set_token()
old_locale <- set_yelp_locale()

test_results_have_correct_form(
  food_delivery_search("white house"),
  c("business_id", "alias", "name", "rating", "review_count", "price", "image_url",
    "is_closed", "url", "category_aliases", "category_titles", "latitude",
    "longitude", "distance_m", "transactions", "address1", "address2",
    "address3", "city", "zip_code", "state", "country", "display_address",
    "phone", "display_phone"),
  c("character", "character", "character", "ordered", "integer",
    "character", "character", "logical", "character", "list", "list",
    "numeric", "numeric", "numeric", "list", "character", "character",
    "character", "character", "character", "character", "character",
    "character", "character", "character")
)

set_yelp_locale(old_locale)
unset_token(old_token)
