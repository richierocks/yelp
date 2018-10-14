context("event_lookup")

old_token <- set_token()
old_locale <- set_yelp_locale()

an_event_id <- event_search("los angeles")$event_id[1L]

test_results_have_correct_form(
  event_lookup(an_event_id),
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

test_that(
  "event lookup works with search result input", {
    n_events <- 2L
    search_results <- event_search("tokyo", locale = "ja_JP", limit = n_events)
    actual <- event_lookup(search_results)
    expect_s3_class(actual, "data.frame")
    expect_identical(nrow(actual), n_events)
  }
)

set_yelp_locale(old_locale)
unset_token(old_token)
