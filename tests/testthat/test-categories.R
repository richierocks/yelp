context("categories")

old_token <- set_token()
old_locale <- set_yelp_locale()

test_results_have_correct_form(
  categories("kombucha"),
  c("alias", "title", "parent_aliases", "country_whitelist", "country_blacklist"
  ),
  c("character", "character", "list", "list", "list")
)

set_yelp_locale(old_locale)
unset_token(old_token)
