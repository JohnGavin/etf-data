# Session Log: Test JustETF History
# Date: 2025-12-12
# Issue: #9

library(httr2)
library(jsonlite)

# VUSA ISIN
isin <- "IE00B3XXRP09"

# Candidate URL patterns based on search results
# 1. Quote/Chart API
# Pattern often seen: /api/etfs/{isin}/performance-chart
url <- paste0("https://www.justetf.com/api/etfs/", isin, "/performance-chart")

message("Testing JustETF Chart API: ", url)

req <- request(url) %>%
  req_url_query(
    locale = "en",
    currency = "GBP",
    valuesType = "MARKET_VALUE" # Guessing parameter
  ) %>%
  req_headers(
    "User-Agent" = "Mozilla/5.0",
    "Accept" = "application/json"
  )

resp <- try(req_perform(req), silent = TRUE)

if (inherits(resp, "try-error")) {
  message("Failed to fetch: ", resp)
} else {
  message("Status: ", resp_status(resp))
  if (resp_status(resp) == 200) {
    str(resp_body_json(resp))
  }
}
