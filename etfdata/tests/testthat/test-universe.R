test_that("get_etf_universe returns expected structure", {
  # This relies on the seed file existing in inst/extdata
  skip_if_not(file.exists(system.file("extdata", "seed_universe.csv", package = "etfdata")))
  
  uni <- get_etf_universe()
  
  expect_s3_class(uni, "tbl_df")
  expect_true(all(c("ticker", "name", "isin", "currency") %in% colnames(uni)))
  
  # Snapshot the first few rows to ensure data stability
  expect_snapshot(head(uni))
})
