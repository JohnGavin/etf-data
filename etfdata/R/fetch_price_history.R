#' Fetch Price History from Yahoo Finance
#'
#' Retrieves daily OHLCV data for a given ticker using quantmod/Yahoo.
#'
#' @param ticker Character string. The ticker symbol (e.g., "VUSA.L").
#' @param start_date Date or character. Start date (default "2020-01-01").
#' @param end_date Date or character. End date (default Sys.Date()).
#'
#' @return A tibble with Date, Open, High, Low, Close, Volume, Adjusted columns.
#' @export
#'
#' @examples
#' \dontrun{
#'   fetch_price_history("VUSA.L")
#' }
#'
#' @importFrom quantmod getSymbols
#' @importFrom tibble as_tibble rownames_to_column
#' @importFrom dplyr rename mutate select
#' @importFrom lubridate ymd
#' @importFrom magrittr %>%
#' @importFrom stats runif
fetch_price_history <- function(ticker, start_date = "2020-01-01", end_date = Sys.Date()) {
  # quantmod::getSymbols loads data into an environment by default.
  # We use auto.assign = FALSE to get the object directly.
  
  # Polite delay
  Sys.sleep(runif(1, 0.5, 1.5))
  
  tryCatch({
    xts_data <- quantmod::getSymbols(
      ticker, 
      src = "yahoo", 
      auto.assign = FALSE, 
      from = start_date, 
      to = end_date,
      warnings = FALSE
    )
    
    # Convert xts to tibble
    df <- as.data.frame(xts_data) %>%
      tibble::rownames_to_column(var = "date") %>%
      tibble::as_tibble()
    
    # Clean names (remove Ticker. prefix)
    # Using [.] to avoid backslash hell
    names(df) <- gsub(paste0("^", ticker, "[.]"), "", names(df))
    
    # Standardize
    df %>%
      dplyr::mutate(date = lubridate::ymd(date)) %>%
      dplyr::rename(
        open = Open,
        high = High,
        low = Low,
        close = Close,
        volume = Volume,
        adjusted = Adjusted
      ) %>%
      dplyr::mutate(ticker = ticker) %>%
      dplyr::select(ticker, date, dplyr::everything())
      
  }, error = function(e) {
    warning("Failed to fetch history for ", ticker, ": ", e$message)
    return(NULL)
  })
}
