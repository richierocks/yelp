old_token <- set_token()

test_results_have_correct_form(
  autocomplete("del"),
  c("id", "name"),
  c("character", "character")
)

unset_token(old_token)
