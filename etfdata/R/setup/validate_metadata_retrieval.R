# R/setup/validate_metadata_retrieval.R
# Script to validate the fetch_etf_metadata function using Yahoo Finance API

# Load the etfdata package
devtools::load_all("finance/data/etfs/etfdata")

# Define a sample LSE ticker (Yahoo Finance symbol)
# VUSA.L is a common symbol for Vanguard S&P 500 UCITS ETF Acc on LSE
sample_symbol <- "VUSA.L" 

# Fetch metadata
etf_metadata <- fetch_etf_metadata(sample_symbol)

# Print the resulting tibble to verify
print(etf_metadata)

# Add basic assertions for data structure
# stopifnot(
#   inherits(etf_metadata, "data.frame"),
#   "symbol" %in% colnames(etf_metadata),
#   "market_cap" %in% colnames(etf_metadata),
#   "total_assets_aum" %in% colnames(etf_metadata),
#   "expense_ratio" %in% colnames(etf_metadata),
#   "currency" %in% colnames(etf_metadata)
# )
