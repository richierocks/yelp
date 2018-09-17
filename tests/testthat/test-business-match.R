old_token <- set_token()

test_results_have_correct_form(
  business_match("AT&T", "manhattan", "NY", "US", "Thomas Street"), # Long Lines building
  c("id", "name", "alias", "latitude", "longitude", "address1",
    "address2", "address3", "city", "zip_code", "state", "country",
    "phone"),
  c("character", "character", "character", "numeric", "numeric",
    "character", "character", "character", "character", "character",
    "character", "character", "character")
)

unset_token(old_token)
