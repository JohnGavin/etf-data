test_that("fetch_justetf_screener returns a valid tibble", {
  skip_on_cran()
  skip("API endpoint returned 404")
  
  # This test hits an external API, so it might fail if the API changes or is down.
  # Ideally, we would use vcr/httptest2 to record cassettes.
  
  etfs <- fetch_justetf_screener(min_aum_gbp = 1000, max_ter = 0.1)
  
  expect_s3_class(etfs, "tbl_df")
  
  # If data returned, check columns
  if (nrow(etfs) > 0) {
    expect_true("isin" %in% colnames(etfs))
    expect_true("name" %in% colnames(etfs))
    expect_true("ter_num" %in% colnames(etfs))
    expect_true("aum_num" %in% colnames(etfs))
    
    expect_true(all(etfs$aum_num >= 1000))
    expect_true(all(etfs$ter_num <= 0.1))
  }
})
