# R/setup/validate_price_history.R
# Script to validate the fetch_price_history function

# Load the etfdata package (assuming it's installed or available)
devtools::load_all("finance/data/etfs/etfdata")

# Define a sample LSE ticker
sample_ticker <- "VUSA.L" # Example: Vanguard S&P 500 UCITS ETF Acc

# Fetch price history
price_history <- fetch_price_history(sample_ticker)

# Print the head of the data to verify
print(head(price_history))

# You might want to add assertions here to check data structure, column names, etc.
# For example:
# stopifnot(
#   inherits(price_history, "data.frame"),
#   "Date" %in% colnames(price_history),
#   "VUSA.L.Open" %in% colnames(price_history) # Adjust column names based on actual output
# )
