#' Fetch ETF Metadata from Yahoo Finance API
#'
#' Fetches metadata (AUM, TER, etc.) for a given ETF ticker from the Yahoo Finance API.
#'
#' @param symbol Character string. The Yahoo Finance ticker symbol of the ETF (e.g., "VUSA.L").
#'
#' @return A tibble with metadata columns. Returns an empty tibble with the symbol if fetching fails.
#' @export
#'
#' @examples
#' \dontrun{
#'   fetch_etf_metadata("VUSA.L")
#' }
#'
#' @importFrom httr2 request req_url_query req_perform resp_body_json resp_status
#' @importFrom dplyr tibble
#' @importFrom purrr map_dfr
#' @importFrom rlang .data
fetch_etf_metadata <- function(symbol) {
  if (length(symbol) > 1) {
    return(purrr::map_dfr(symbol, fetch_etf_metadata))
  }

  base_url <- "https://query1.finance.yahoo.com/v10/finance/quoteSummary/"
  url <- paste0(base_url, symbol)

  req <- request(url) %>%
    req_url_query(modules = "summaryDetail,fundProfile") %>%
    httr2::req_headers("User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")

  # Print the URL for debugging
  print(req$url)

  resp <- try(req_perform(req), silent = TRUE)

  if (inherits(resp, "try-error")) {
    warning("Failed to fetch metadata for ", symbol, ". Error: ", attr(resp, "condition")$message)
    return(dplyr::tibble(symbol = symbol))
  }
  
  if (resp_status(resp) != 200) {
    warning("HTTP error ", resp_status(resp), " for ", symbol)
    return(dplyr::tibble(symbol = symbol))
  }

  body <- resp_body_json(resp)

  # Extract summaryDetail
  summary_detail <- body$quoteSummary$result[[1]]$summaryDetail
  market_cap <- summary_detail$marketCap$raw
  total_expenses <- summary_detail$totalExpenseRatio$raw # This might be TER, need to confirm
  currency <- summary_detail$currency

  # Extract fundProfile
  fund_profile <- body$quoteSummary$result[[1]]$fundProfile
  fund_aum <- fund_profile$totalAssets$raw

  dplyr::tibble(
    symbol = symbol,
    market_cap = market_cap,
    total_assets_aum = fund_aum,
    expense_ratio = total_expenses,
    currency = currency
  )
}
