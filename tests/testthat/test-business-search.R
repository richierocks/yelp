old_token <- set_token()

test_that(
  "business_search() returns a data frame", {
    actual <- business_search("tapas", "Madrid, Spain")
    expect_s3_class(actual, "tbl_df")
    expect_gte(nrow(actual), 1L)
    expect_equal(
      colnames(actual),
      c("id", "name", "rating", "review_count", "price", "image_url",
        "is_closed", "url", "category_aliases", "category_titles", "latitude",
        "longitude", "distance_m", "transactions", "address1", "address2",
        "address3", "city", "zip_code", "state", "country", "display_address",
        "phone", "display_phone")
    )
    expect_equal(
      vapply(actual, class, character(1L), USE.NAMES = FALSE),
      c("character", "character", "numeric", "integer", "character",
        "character", "logical", "character", "list", "list", "numeric",
        "numeric", "numeric", "list", "character", "character", "character",
        "character", "character", "character", "character", "list", "character",
        "character")
    )
  }
)

unset_token(old_token)
