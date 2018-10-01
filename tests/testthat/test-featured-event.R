# Keeping this test for now, but it's flaky because the featured events are
# curated, and it's unclear if there will always be a featured event for any
# given location

context("featured_event")

old_token <- set_token()
old_locale <- set_yelp_locale()

test_results_have_correct_form(
  featured_event("new york"),
  c("event_id", "name", "category", "description", "is_free", "cost",
    "cost_max", "business_id", "event_site_url", "image_url", "tickets_url",
    "interested_count", "attending_count", "time_start", "time_end",
    "is_canceled", "is_official", "latitude", "longitude", "address1",
    "address2", "address3", "city", "zip_code", "state", "country",
    "display_address", "cross_streets"
  ),
  c("character", "character", "character", "character", "logical",
    "numeric", "numeric", "character", "character", "character",
    "character", "integer", "integer", "character", "character",
    "logical", "logical", "numeric", "numeric", "character",
    "character", "character", "character", "character", "character",
    "character", "character", "character"
  )
)

set_yelp_locale(old_locale)
unset_token(old_token)
