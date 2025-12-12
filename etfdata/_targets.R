# _targets.R
library(targets)
library(tarchetypes)

# Set target options:
tar_option_set(
  packages = c("etfdata", "tibble", "dplyr", "purrr"),
  format = "rds"
)

# Define the pipeline
list(
  # 1. Get Universe (Seed List)
  tar_target(
    universe,
    get_etf_universe()
  ),
  
  # 2. Fetch Metadata (Map over ISINs)
  # We use dynamic branching to fetch metadata for each ETF individually
  tar_target(
    metadata,
    fetch_etf_metadata(universe$isin),
    pattern = map(universe)
  ),
  
  # 3. Fetch History (Map over Tickers)
  # Dynamic branching for history
  tar_target(
    history,
    fetch_price_history(universe$ticker),
    pattern = map(universe)
  )
)
