context("event_search")

old_token <- set_token()

test_results_have_correct_form(
  event_search("camden, london", locale = "en_GB"),
  c("id", "name", "category", "description", "is_free", "cost",
    "cost_max", "business_id", "event_site_url", "image_url", "tickets_url",
    "interested_count", "attending_count", "time_start", "time_end",
    "is_canceled", "is_official", "address1", "address2", "address3",
    "city", "zip_code", "state", "country", "display_address", "cross_streets"
  ),
  c("character", "character", "character", "character", "logical",
    "numeric", "numeric", "character", "character", "character",
    "character", "integer", "integer", "character", "character",
    "logical", "logical", "character", "character", "character",
    "character", "character", "character", "character", "character",
    "character")
)

unset_token(old_token)
