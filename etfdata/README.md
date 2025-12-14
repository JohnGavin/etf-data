# etfdata

<!-- badges: start -->
<!-- badges: end -->

The goal of `etfdata` is to provide tools to fetch, clean, and store historical and metadata for European bond and equity index ETFs (UCITS) listed on the London Stock Exchange.

## Installation

You can install the development version of etfdata from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("JohnGavin/etf-data/etfdata")
```

## Example

This example demonstrates how to retrieve the ETF universe, fetch metadata (including AUM), filter for the largest funds, and visualize their price history.

``` r
library(etfdata)
library(dplyr)
library(ggplot2)

# 1. Get the universe of ETFs
universe <- get_etf_universe()

# 2. Fetch metadata (AUM, TER, etc.) for the first few ETFs to identify top funds
# (In a real scenario, you might fetch metadata for the whole universe)
sample_isins <- head(universe$isin, 5)
metadata <- fetch_etf_metadata(sample_isins) # Vectorized fetch not yet implemented, loop or map needed in practice
# For demonstration, we'll assume we identified top tickers
top_tickers <- c("VUSA.L", "CSP1.L", "INRG.L", "EQQQ.L")

# 3. Fetch Price History for Top 4
history <- fetch_price_history(top_tickers)

# 4. Plot the performance
history %>%
  ggplot(aes(x = date, y = close, color = ticker)) +
  geom_line() +
  facet_wrap(~ticker, scales = "free_y") +
  labs(
    title = "Price History of Top ETFs",
    x = "Date",
    y = "Close Price (GBP)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
```
