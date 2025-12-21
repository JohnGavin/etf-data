# etfdata

<!-- badges: start  -->
<!-- badges: end -->

The goal of `etfdata` is to provide tools to fetch, clean, and store historical and metadata for European bond and equity index ETFs (UCITS) listed on the London Stock Exchange

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
metadata <- fetch_etf_metadata(sample_isins) 

# Join metadata to the universe subset
detailed_universe <- universe %>%
  filter(isin %in% sample_isins) %>%
  left_join(metadata, by = "isin")

print(detailed_universe)

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

## JustETF Screener

You can also fetch a live list of ETFs directly from the JustETF screener API, allowing you to filter by AUM (Assets Under Management) and TER (Total Expense Ratio).

```r
# Fetch ETFs with > £200m AUM and < 0.75% TER
screener_data <- fetch_justetf_screener(min_aum_gbp = 200, max_ter = 0.75)

print(head(screener_data))
```

## Reproducibility with Nix

This project is reproducible using [Nix](https://nixos.org/).

### Installation
We recommend the [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer):
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh
```

### Running
From the project root (`etf-data`), drop into a reproducible R environment with all dependencies:
```bash
nix-shell default.nix
```
Install the package into your user library inside the nix shell (once per shell):
```bash
R CMD INSTALL --library=$HOME/.Rlibs_etf etfdata
```
Then run the examples (e.g. print the universe):
```bash
Rscript -e "library(etfdata); packageVersion('etfdata'); str(get_etf_universe())"
```

Expected output:
```
[1] ‘0.0.0.9000’
tibble [20 × 4] (S3: tbl_df/tbl/data.frame)
 $ ticker  : chr [1:20] "VUSA.L" "CSPX.L" "INRG.L" "EQQQ.L" ...
 $ name    : chr [1:20] "Vanguard S&P 500 UCITS ETF" "iShares Core S&P 500 UCITS ETF" ...
 $ isin    : chr [1:20] "IE00B3XXRP09" "IE00B5BMR087" "IE00B1XNHC34" "IE0032077012" ...
 $ currency: chr [1:20] "GBP" "GBP" "GBP" "GBP" ...
```
