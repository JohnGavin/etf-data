# Session Log: Test tidyquant Universe
# Date: 2025-12-12
# Issue: #7

library(tidyquant)

message("Checking tidyquant exchange options...")
print(tq_exchange_options())

message("Attempting to fetch LSE symbols (if supported)...")
# "LSE" isn't standard in tq_exchange, but maybe "LONDON"?
# tq_exchange only supports US exchanges usually (NYSE, NASDAQ, AMEX).

# Let's check tq_index options
print(tq_index_options())

# If tidyquant is US-centric, we might need another source.
# Try to get *any* list from quantmod? No, quantmod is a wrapper.

message("Checking if we can find a workaround...")
