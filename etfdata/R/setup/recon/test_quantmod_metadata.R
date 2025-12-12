# Session Log: Test quantmod Metadata
# Date: 2025-12-12
# Issue: #9

library(quantmod)

# List available fields
# yahooQF()

metrics <- c(
  "Name",
  "Currency",
  "Market Capitalization", # Proxy for AUM?
  "Volume",
  "Average Daily Volume",
  "P/E Ratio",
  "Dividend Yield"
)

message("Fetching quote for VUSA.L...")
tryCatch({
  q <- getQuote("VUSA.L", what = yahooQF(metrics))
  print(q)
}, error = function(e) {
  message("Error: ", e$message)
})
