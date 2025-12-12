# Session Log: Test Data Sources
# Date: 2025-12-12
# Issue: #5

library(quantmod)
library(httr2)
library(jsonlite)
library(tibble)

# 1. Test quantmod / Yahoo Finance
message("\n--- Testing quantmod (Yahoo Finance) ---")
test_yahoo <- function(symbol) {
  tryCatch({
    data <- getSymbols(symbol, src = "yahoo", auto.assign = FALSE, from = "2023-01-01", to = "2023-01-10")
    message("Successfully fetched ", symbol)
    print(head(data))
    return(TRUE)
  }, error = function(e) {
    message("Failed to fetch ", symbol, ": ", e$message)
    return(FALSE)
  })
}

# Test VUSA.L (Vanguard S&P 500 UCITS ETF)
test_yahoo("VUSA.L")

# 2. Test FT.com Internal API
message("\n--- Testing FT.com Internal API ---")
test_ft <- function(symbol) {
  url <- "https://markets.ft.com/data/equities/ajax/get-historical-prices"
  
  tryCatch({
    req <- request(url) %>%
      req_url_query(
        startDate = "2023/01/01",
        endDate = "2023/01/10",
        symbol = symbol
      ) %>%
      req_headers(
        "User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/115.0",
        "Referer" = "https://markets.ft.com/data/etfs/tearsheet/historical?s=VUSA:LSE:GBP"
      )
    
    resp <- req_perform(req)
    
    if (resp_status(resp) == 200) {
      body <- resp_body_json(resp)
      if (!is.null(body$html)) {
         # The API returns HTML table inside JSON 'html' field usually
         message("FT API returned HTML content (length: ", nchar(body$html), ")")
         # We would need to parse this HTML
         return(TRUE)
      } else {
         message("FT API returned JSON but unexpected structure")
         print(names(body))
         return(FALSE)
      }
    } else {
      message("FT API Request failed: ", resp_status(resp))
      return(FALSE)
    }
  }, error = function(e) {
    message("FT API Error: ", e$message)
    return(FALSE)
  })
}

# Test VUSA:LSE:GBP
test_ft("VUSA:LSE:GBP")
