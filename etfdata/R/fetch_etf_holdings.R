#' Fetch ETF Holdings from Yahoo Finance
#'
#' Retrieves historical fund holdings (composition) for a given ETF ticker using tidyquant.
#' This includes top holdings, sector weights, and asset allocation data.
#'
#' @param symbol Character string. The ticker symbol of the ETF (e.g., "SPY").
#'
#' @return A tibble containing holding details. Returns NULL or empty tibble on failure.
#' @export
#'
#' @examples
#' \dontrun{
#'   fetch_etf_holdings("SPY")
#' }
#'
#' @importFrom logger log_info log_warn log_error
fetch_etf_holdings <- function(symbol) {
  if (!requireNamespace("tidyquant", quietly = TRUE)) {
    warning("Package 'tidyquant' is required for fetch_etf_holdings. Please install it.")
    return(tibble::tibble())
  }

  logger::log_info("Fetching holdings for ETF: {symbol}")
  
  tryCatch({
    holdings <- tidyquant::tq_fund_holdings(symbol)
    
    if (nrow(holdings) > 0) {
      logger::log_info("Successfully fetched {nrow(holdings)} holdings for {symbol}")
      return(holdings)
    } else {
      logger::log_warn("No holdings data returned for {symbol}")
      return(tibble::tibble())
    }
  }, error = function(e) {
    logger::log_error("Failed to fetch holdings for {symbol}: {e$message}")
    return(tibble::tibble())
  })
}
