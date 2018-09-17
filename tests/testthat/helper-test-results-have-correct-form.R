test_results_have_correct_form <- function(actual, expected_column_names, expected_column_classes) {
  fn_called <- deparse(substitute(actual)[[1]])
  test_description <- sprintf("%s() returns a data frame", fn_called)
  test_that(
    test_description, {
      expect_s3_class(actual, "tbl_df")
      expect_gte(nrow(actual), 1L)
      expect_equal(colnames(actual), expected_column_names)
      expect_equal(
        vapply(actual, class, character(1L), USE.NAMES = FALSE),
        expected_column_classes
      )
    }
  )
}
