# Session Log: Test Metadata Sources (Yahoo Finance)
# Date: 2025-12-12
# Issue: #9

library(httr2)
library(jsonlite)
library(purrr)

test_yahoo_metadata <- function(symbol) {
  # Endpoint for quoteSummary
  # Modules of interest:
  # - summaryDetail: volume, marketCap, trailingPE
  # - fundProfile: expenseRatio, categoryName, family
  # - price: regularMarketPrice, currency
  
  url <- paste0("https://query2.finance.yahoo.com/v10/finance/quoteSummary/", symbol)
  
  message("Fetching metadata for ", symbol, "...")
  
  req <- request(url) %>%
    req_url_query(
      modules = "summaryDetail,fundProfile,price,assetProfile"
    ) %>%
    req_headers(
      "User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/115.0"
    )
  
  resp <- try(req_perform(req), silent = TRUE)
  
  if (inherits(resp, "try-error")) {
    message("Failed to fetch: ", resp)
    return(NULL)
  }
  
  if (resp_status(resp) == 200) {
    body <- resp_body_json(resp)
    result <- body$quoteSummary$result[[1]]
    
    if (is.null(result)) {
      message("No result in response")
      return(NULL)
    }
    
    # Extract key metrics
    meta <- list(
      ticker = symbol,
      name = result$price$longName %||% NA,
      currency = result$price$currency %||% NA,
      aum = result$summaryDetail$totalAssets$raw %||% NA, # AUM often here
      expense_ratio = result$fundProfile$feesExpensesInvestment$annualReportExpenseRatio$raw %||% NA,
      category = result$fundProfile$categoryName %||% NA,
      asset_class = result$fundProfile$family %||% NA # Sometimes here
    )
    
    # Check assetProfile if fundProfile missing
    if (is.null(meta$expense_ratio)) {
        # Sometimes fees are elsewhere?
        # Check output structure if needed
    }
    
    print(str(meta))
    return(meta)
  } else {
    message("Request failed: ", resp_status(resp))
    return(NULL)
  }
}

# Test with VUSA.L
test_yahoo_metadata("VUSA.L")
