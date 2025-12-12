test_that("get_etf_universe returns a tibble with expected columns", {
  universe <- get_etf_universe()
  expect_s3_class(universe, "tbl_df")
  expect_named(universe, c("ticker", "name", "isin", "currency"))
  expect_true(nrow(universe) > 0)
})
