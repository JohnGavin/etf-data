#' Get ETF Universe
#'
#' Retrieves the list of ETFs to track. 
#' 
#' Currently uses a bundled snapshot of European UCITS ETFs for reproducibility and offline access.
#' Future versions may implement dynamic scraping or API fetching.
#'
#' @param n Integer. Maximum number of ETFs to return. Default is Inf (all).
#'
#' @return A tibble with columns: ticker, name, isin, currency
#' @export
#'
#' @examples
#' \dontrun{
#'   get_etf_universe(n = 5)
#' }
#'
#' @importFrom readr read_csv
#' @importFrom utils head
get_etf_universe <- function(n = Inf) {
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
  
  res <- readr::read_csv(path, show_col_types = FALSE)
  
  if (is.finite(n) && n < nrow(res)) {
    return(head(res, n))
  }
  
  res
}