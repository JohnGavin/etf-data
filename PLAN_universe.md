# Plan: ETF Universe Discovery (Revised)

**Objective:** Create a master list of European UCITS ETFs.

## Challenges
*   LSE website download link is dynamic/hidden.
*   `tidyquant` is US-centric.
*   Issuer scraping is brittle.

## Strategy: Seed List & Expansion
1.  **Seed List (Immediate):** Create a static CSV (`inst/extdata/seed_universe.csv`) with top 50 liquid LSE ETFs (manual/known list).
2.  **Expansion (Future):**
    *   Use the "Seed List" to test data fetching.
    *   Later, investigate `justetf.com` scraping using `chromote` (headless browser) if needed.

## Implementation Steps
1.  Create `inst/extdata/seed_universe.csv`.
    *   Columns: `ticker`, `name`, `isin`, `currency`.
    *   Example: `VUSA.L`, `Vanguard S&P 500 UCITS ETF`, `IE00B3XXRP09`, `GBP`.
2.  Implement `get_etf_universe()` function in `R/get_etf_universe.R`.
    *   Reads the CSV.
    *   Returns a tibble.
3.  Export `etf_universe` as a package dataset.