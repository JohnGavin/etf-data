#' Get ETF Universe
#'
#' Retrieves the list of ETFs to track. Currently uses a static seed list.
#'
#' @return A tibble with columns: ticker, name, isin, currency
#' @export
#'
#' @importFrom readr read_csv
get_etf_universe <- function() {
  path <- system.file("extdata", "seed_universe.csv", package = "etfdata")
  if (path == "") {
    # Fallback for development if package not installed
    path <- "inst/extdata/seed_universe.csv"
  }
  
  if (!file.exists(path)) {
    # Try one level up if running from package root
    if (file.exists("inst/extdata/seed_universe.csv")) {
        path <- "inst/extdata/seed_universe.csv"
    } else {
        stop("Seed universe file not found at: ", path)
    }
  }
  
  readr::read_csv(path, show_col_types = FALSE)
}