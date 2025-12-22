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

Example output (cached snapshot):

```
# A tibble: 5 x 6
  ticker name                                  isin         currency aum_text     ter_text
  <chr>  <chr>                                 <chr>        <chr>    <chr>        <chr>
1 VUSA.L Vanguard S&P 500 UCITS ETF            IE00B3XXRP09 GBP      GBP 36,957 m 0.07% p.a.
2 CSPX.L iShares Core S&P 500 UCITS ETF        IE00B5BMR087 GBP      GBP 98,470 m 0.07% p.a.
3 INRG.L iShares Global Clean Energy UCITS ETF IE00B1XNHC34 GBP      GBP 1,889 m  0.65% p.a.
4 EQQQ.L Invesco EQQQ Nasdaq-100 UCITS ETF     IE0032077012 GBP      GBP 8,283 m  0.30% p.a.
5 VWRL.L Vanguard FTSE All-World UCITS ETF     IE00B3RBWM25 GBP      GBP 16,116 m 0.19% p.a.
```

![VUSA.L Close Price (Cached Snapshot)](man/figures/README-example.png)

## JustETF Screener

You can also fetch a live list of ETFs directly from the JustETF screener API, allowing you to filter by AUM (Assets Under Management) and TER (Total Expense Ratio).

```r
# Fetch ETFs with > £200m AUM and < 0.75% TER
screener_data <- fetch_justetf_screener(min_aum_gbp = 200, max_ter = 0.75)

print(head(screener_data))
```

Example output (cached snapshot):

```

## WebR, CORS, and Cached Data

Browser builds cannot call JustETF or Yahoo Finance directly because the browser enforces cross-site request restrictions (CORS). To keep the WebR and Shinylive demos working, the project precomputes a full LSE ETF snapshot in CI using `targets` and stores it in:

- `inst/extdata/etf_universe_curated.csv` (manual universe list; edit to add/remove ETFs)
- `inst/extdata/etf_universe.csv`
- `inst/extdata/history_cache.rds`
- `inst/extdata/history_summary.rds`
- `inst/extdata/vignette_data.rds`

See `docs/wiki/ETF_Data_Sources.md` for the rationale, refresh steps, and alternative data sources. The cached data coverage summary is in the vignette `vignettes/data_snapshot.qmd` (published as `articles/data_snapshot.html`).

To refresh the snapshot locally (only missing dates/tickers are downloaded):

```r
setwd("etfdata")
targets::tar_make()
```
# A tibble: 6 x 6
  isin         aum_text     ter_text   ticker name                         currency
  <chr>        <chr>        <chr>      <chr>  <chr>                        <chr>
1 IE00B3XXRP09 GBP 36,957 m 0.07% p.a. VUSA.L Vanguard S&P 500 UCITS ETF   GBP
2 IE00B5BMR087 GBP 98,470 m 0.07% p.a. CSPX.L iShares Core S&P 500 UCITS ETF GBP
3 IE00B1XNHC34 GBP 1,889 m  0.65% p.a. INRG.L iShares Global Clean Energy UCITS ETF GBP
4 IE0032077012 GBP 8,283 m  0.30% p.a. EQQQ.L Invesco EQQQ Nasdaq-100 UCITS ETF GBP
5 IE00B3RBWM25 GBP 16,116 m 0.19% p.a. VWRL.L Vanguard FTSE All-World UCITS ETF GBP
6 IE0005042456 GBP 13,494 m 0.07% p.a. ISF.L  iShares Core FTSE 100 UCITS ETF GBP
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
Then run the examples (e.g. print the universe). Use one of the following options:

Option A: Load the package directly from source (no install step needed):
```bash
Rscript --vanilla -e 'devtools::load_all("etfdata"); packageVersion("etfdata"); str(get_etf_universe())'
```

Option B: Use your custom library path explicitly:
```bash
R_LIBS_USER=$HOME/.Rlibs_etf Rscript --vanilla -e 'library(etfdata); packageVersion("etfdata"); str(get_etf_universe())'
```

Note: `devtools` is included in the Nix development shell for convenience, but it is not a runtime dependency of the `etfdata` package.

Expected output:
```
[1] ‘0.0.0.9000’
tibble [20 × 4] (S3: tbl_df/tbl/data.frame)
 $ ticker  : chr [1:20] "VUSA.L" "CSPX.L" "INRG.L" "EQQQ.L" ...
 $ name    : chr [1:20] "Vanguard S&P 500 UCITS ETF" "iShares Core S&P 500 UCITS ETF" ...
 $ isin    : chr [1:20] "IE00B3XXRP09" "IE00B5BMR087" "IE00B1XNHC34" "IE0032077012" ...
 $ currency: chr [1:20] "GBP" "GBP" "GBP" "GBP" ...
```
