context("business_lookup")

old_token <- set_token()

test_results_have_correct_form(
  business_lookup("g2IUVjeIwx5x6x9u1cLS6w"), # Empire State Building
  c("id", "alias", "name", "rating", "review_count", "price", "image_url",
    "is_closed", "url", "category_aliases", "category_titles", "latitude",
    "longitude", "distance_m", "transactions", "address1", "address2",
    "address3", "city", "zip_code", "state", "country", "display_address",
    "phone", "display_phone", "photos", "is_claimed", "is_permanently_closed",
    "opening_hours"),
  c("character", "character", "character", "numeric", "integer",
    "character", "character", "logical", "character", "list", "list",
    "numeric", "numeric", "numeric", "list", "character", "character",
    "character", "character", "character", "character", "character",
    "character", "character", "character", "list", "logical", "logical",
    "list")
)

unset_token(old_token)
