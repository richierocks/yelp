old_token <- set_token()

test_that(
  "autocomplete() returns a list with 3 terms", {
  actual <- autocomplete("del")
  expect_type(actual, "list")
  expect_length(actual, 3)
  expect_equal(names(actual), c("terms", "businesses", "categories"))
  expect_equal(colnames(actual$businesses), c("id", "name"))
  expect_equal(
    vapply(actual$businesses, class, character(1L), USE.NAMES = FALSE),
    c("character", "character")
  )
  expect_equal(colnames(actual$categories), c("alias", "title"))
  expect_equal(
    vapply(actual$categories, class, character(1L), USE.NAMES = FALSE),
    c("character", "character")
  )
})

unset_token(old_token)
