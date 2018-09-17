old_token <- set_token()

test_results_have_correct_form(
  reviews("jgMc8tzS-D2ryIDDzNpgDA"), # Richard Rodgers theatre
  c("id", "rating", "text", "time_created", "url", "user_image_url",
    "user_name"),
  c("character", "integer", "character", "character", "character",
    "character", "character")
)

unset_token(old_token)
