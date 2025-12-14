test_that("parse_aum works correctly", {
  # Test with single input
  input <- "GBP 100,642 m"
  result <- parse_aum(input)
  
  expect_equal(as.character(result$currency), "GBP")
  expect_equal(result$aum_amount, 100642)
  expect_equal(as.character(result$aum_units), "m")
  expect_equal(result$aum_units_amount, 1e6)
  
  # Snapshot test for structure and content
  expect_snapshot(result)
  
  # Test with vector input
  input_vec <- c("GBP 100,642 m", "USD 50.5 bn", "EUR 500")
  result_vec <- parse_aum(input_vec)
  expect_snapshot(result_vec)
})
