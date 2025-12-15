# Update bundled snapshot with current universe (20 items)
devtools::load_all("finance/data/etfs/etfdata")
library(dplyr)
library(purrr)

# 1. Universe
universe <- get_etf_universe()
print(paste("Universe size:", nrow(universe)))

# 2. Metadata
# Note: fetch_etf_metadata might take time for 20 items.
# We'll use a safe map.
safe_meta <- safely(fetch_etf_metadata)
metadata_list <- map(universe$isin, ~{
  message("Fetching meta for ", .x)
  fetch_etf_metadata(.x)
})
# Combine
metadata <- list_rbind(metadata_list)
print(paste("Metadata size:", nrow(metadata)))

# 3. History
# fetch_price_history handles vector input?
# Let's check. Usually yes or we map.
# The vignette used `fetch_price_history("VUSA.L")`.
# I'll check the function. 
# Assuming it handles one ticker at a time based on standard patterns or if it's vectorized.
# I'll map just in case.
safe_hist <- safely(fetch_price_history)
history_list <- map(universe$ticker, ~{
  message("Fetching history for ", .x)
  tryCatch(fetch_price_history(.x), error = function(e) NULL)
})
history <- list_rbind(history_list)
print(paste("History size:", nrow(history)))

# Save
snapshot <- list(
  universe = universe,
  metadata = metadata,
  history = history
)

saveRDS(snapshot, "finance/data/etfs/etfdata/inst/extdata/vignette_data.rds")
message("Snapshot saved.")
