# _targets.R
library(targets)
library(tarchetypes)

# Set target options:
tar_option_set(
  packages = c("etfdata", "tibble", "dplyr", "purrr", "lubridate"),
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
  # Using JustETF scraping
  tar_target(
    metadata,
    fetch_justetf_metadata(universe$isin),
    pattern = map(universe)
  ),
  
  # 3. Fetch History (Map over Tickers)
  # Using Yahoo Finance
  tar_target(
    history,
    fetch_price_history(universe$ticker),
    pattern = map(universe)
  )
)