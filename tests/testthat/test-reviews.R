context("reviews")

old_token <- set_token()
old_locale <- set_yelp_locale()

test_results_have_correct_form(
  reviews("jgMc8tzS-D2ryIDDzNpgDA"), # Richard Rodgers theatre
  c("review_id", "rating", "text", "time_created", "url", "user_image_url",
    "user_name"),
  c("character", "ordered", "character", "character", "character",
    "character", "character")
)

set_yelp_locale(old_locale)
unset_token(old_token)
