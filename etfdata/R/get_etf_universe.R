#' Get ETF Universe
#'
#' Retrieves the list of ETFs to track. Prefers the curated universe file
#' when available, then falls back to the cached snapshot or seed list.
#'
#' @param n Integer. Maximum number of ETFs to return. Default is 20. Set to Inf for all.
#' @param live Logical. If TRUE, attempts to fetch the latest universe from an external source.
#' @param file Character. Path to a local CSV file to read the universe from. Overrides `live` and default cache.
#'
#' @return A tibble with columns: ticker, name, isin, currency
#' @export
#'
#' @examples
#' \dontrun{
#'   get_etf_universe() # Returns top 20
#'   get_etf_universe(n = 5)
#'   get_etf_universe(n = Inf) # Returns all
#'   get_etf_universe(file = "my_etfs.csv")
#' }
#'
#' @importFrom readr read_csv
#' @importFrom utils head
get_etf_universe <- function(n = 20, live = FALSE, file = NULL) {
  
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
    live_res <- try(fetch_justetf_screener(min_aum_gbp = 0, max_ter = Inf), silent = TRUE)
    if (!inherits(live_res, "try-error") && nrow(live_res) > 0) {
      return(select_universe_cols(live_res, n))
    }
    warning("Live universe fetch failed. Returning cached snapshot.")
  }

  curated_path <- system.file("extdata", "etf_universe_curated.csv", package = "etfdata")
  if (curated_path == "") {
    curated_path <- "inst/extdata/etf_universe_curated.csv"
  }

  if (file.exists(curated_path)) {
    res <- readr::read_csv(curated_path, show_col_types = FALSE)
    if (is.finite(n) && n < nrow(res)) {
      return(head(res, n))
    }
    return(res)
  }

  full_path <- system.file("extdata", "etf_universe.csv", package = "etfdata")
  if (full_path == "") {
    full_path <- "inst/extdata/etf_universe.csv"
  }

  if (file.exists(full_path)) {
    res <- readr::read_csv(full_path, show_col_types = FALSE)
    if (is.finite(n) && n < nrow(res)) {
      return(head(res, n))
    }
    return(res)
  }

  seed_path <- system.file("extdata", "seed_universe.csv", package = "etfdata")
  if (seed_path == "") {
    seed_path <- "inst/extdata/seed_universe.csv"
  }

  if (!file.exists(seed_path)) {
    stop("Seed universe file not found at: ", seed_path)
  }

  res <- readr::read_csv(seed_path, show_col_types = FALSE)
  if (is.finite(n) && n < nrow(res)) {
    return(head(res, n))
  }
  res
}

select_universe_cols <- function(df, n) {
  keep <- intersect(c("ticker", "name", "isin", "currency"), names(df))
  if (length(keep) > 0) {
    df <- df[, keep, drop = FALSE]
  }

  if (is.finite(n) && n < nrow(df)) {
    return(utils::head(df, n))
  }
  df
}
