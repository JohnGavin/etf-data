test_that("fetch_etf_metadata returns expected fields", {
  # Skip on CRAN to avoid network calls
  skip_on_cran()
  
  # VUSA
  meta <- fetch_justetf_metadata("IE00B3XXRP09")
  
  expect_s3_class(meta, "tbl_df")
  expect_equal(meta$isin, "IE00B3XXRP09")
  expect_true(!is.na(meta$aum_text))
  expect_true(grepl("%", meta$ter_text))
})
