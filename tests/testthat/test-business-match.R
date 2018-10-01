context("business_match")

old_token <- set_token()
old_locale <- set_yelp_locale()

test_results_have_correct_form(
  business_match("AT&T", "manhattan", "NY", "US", "Thomas Street"), # Long Lines building
  c("business_id", "alias", "name", "latitude", "longitude", "address1",
    "address2", "address3", "city", "zip_code", "state", "country",
    "phone"),
  c("character", "character", "character", "numeric", "numeric",
    "character", "character", "character", "character", "character",
    "character", "character", "character")
)

set_yelp_locale(old_locale)
unset_token(old_token)
