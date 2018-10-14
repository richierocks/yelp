context("business_lookup")

old_token <- set_token()
old_locale <- set_yelp_locale()

test_results_have_correct_form(
  business_lookup("g2IUVjeIwx5x6x9u1cLS6w"), # Empire State Building
  c("business_id", "alias", "name", "rating", "review_count", "price", "image_url",
    "is_closed", "url", "category_aliases", "category_titles", "latitude",
    "longitude", "distance_m", "transactions", "address1", "address2",
    "address3", "city", "zip_code", "state", "country", "display_address",
    "phone", "display_phone", "photos", "is_claimed", "is_permanently_closed",
    "opening_hours"),
  c("character", "character", "character", "ordered", "integer",
    "character", "character", "logical", "character", "list", "list",
    "numeric", "numeric", "numeric", "list", "character", "character",
    "character", "character", "character", "character", "character",
    "character", "character", "character", "list", "logical", "logical",
    "list")
)

test_that(
  "business lookup works with search result input", {
    n_businesses <- 2L
    search_results <- business_search("museum", "paris", locale = "fr_FR", limit = n_businesses)
    actual <- business_lookup(search_results)
    expect_s3_class(actual, "data.frame")
    expect_identical(nrow(actual), n_businesses)
  }
)

set_yelp_locale(old_locale)
unset_token(old_token)
