#' Get ETF Universe
#'
#' Retrieves the list of ETFs to track.
#'
#' @param n Integer. Maximum number of ETFs to return. Default is Inf (all).
#' @param live Logical. If TRUE, attempts to fetch the latest universe from an external source (not yet implemented, returns cached data with warning).
#' @param file Character. Path to a local CSV file to read the universe from. Overrides `live` and default cache.
#'
#' @return A tibble with columns: ticker, name, isin, currency
#' @export
#'
#' @examples
#' \dontrun{
#'   get_etf_universe(n = 5)
#'   get_etf_universe(file = "my_etfs.csv")
#' }
#'
#' @importFrom readr read_csv
#' @importFrom utils head
get_etf_universe <- function(n = Inf, live = FALSE, file = NULL) {
  
  if (!is.null(file)) {
    if (file.exists(file)) {
      res <- readr::read_csv(file, show_col_types = FALSE)
      if (is.finite(n) && n < nrow(res)) {
        return(head(res, n))
      }
      return(res)
    } else {
      stop("File not found: ", file)
    }
  }

  if (live) {
    warning("Live scraping of full ETF universe is not currently supported due to anti-scraping measures. Returning cached snapshot.")
  }

  path <- system.file("extdata", "seed_universe.csv", package = "etfdata")
  if (path == "") {
    path <- "inst/extdata/seed_universe.csv"
  }
  
  if (!file.exists(path)) {
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