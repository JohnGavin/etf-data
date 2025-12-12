# Project Plan: European UCITS ETF Data Collection (R Package)

**Objective:** Build a robust, reproducible R package (`etfdata`) to gather, clean, and store historical and metadata for European bond and equity index ETFs (UCITS) listed on the London Stock Exchange (LSE).

## 1. Compliance & Standards
This project strictly adheres to the guidelines in `AGENTS.md`:
*   **Structure:** R Package (`etfdata`).
*   **Environment:** Nix (via `rix`).
*   **Tooling:** Tidyverse (`httr2`, `rvest`, `dplyr`, `purrr`) for data; `targets` for pipeline management.
*   **Workflow:** The 9-step mandatory workflow (Issue -> Branch -> PR -> Merge).
*   **Reproducibility:** All setup/maintenance scripts in `R/setup/`.

## 2. Technical Implementation

### Phase 1: Infrastructure & Scaffolding (✅ Completed)
*   **Initialize Package:** Created `etfdata`.
*   **Nix Setup:** Generated `default.nix` with `httr2`, `quantmod`, `targets`.
*   **Git:** Initialized and pushed.

### Phase 2: Source Reconnaissance (🔄 In Progress)
*   **History Data (Volume & Price):**
    *   ✅ **Yahoo Finance (`quantmod`)**: Confirmed working for LSE ETFs (e.g., `VUSA.L`). Volume is included.
*   **Universe Definition (✅ Seed List / ⏳ Expansion):**
    *   Created seed list.
    *   Future: Investigate scraping or FMP API for full list.
*   **Metadata (AUM, Fees):**
    *   **Strategy:** Yahoo Finance `quoteSummary` API via `httr2` (or `yahoofinancer` package).
    *   **Endpoint:** `v10/finance/quoteSummary/{symbol}?modules=summaryDetail,fundProfile`.
    *   **Fallback:** Financial Modeling Prep (`fmpcloudr`) if free tier suffices.

### Phase 3: The `targets` Pipeline
*   **Architecture:**
    *   `_targets.R` at package root.
    *   **Target 1 (Universe):** `fetch_etf_universe()` -> Returns dataframe of ISINs/Tickers.
    *   **Target 2 (Metadata):** `fetch_etf_metadata(universe)` -> Adds AUM, Fees (Yahoo/FMP).
    *   **Target 3 (History):** `fetch_price_history(universe)` -> Daily OHLCV (via `quantmod`).
    *   **Target 4 (Storage):** Save to Parquet/RDS in `inst/extdata`.

### Phase 4: Data Validation & Documentation
*   **Validation:** `testthat` tests for data schema (cols, types) and consistency (High >= Low).
*   **Documentation:** `pkgdown` site to document functions and datasets.
*   **Vignettes:** Quarto vignette showing analysis of the captured data.

## 3. Immediate Next Steps (9-Step Workflow)

1.  **Create Issue:** "Implement ETF Metadata Retrieval (AUM/Fees)".
2.  **Branch:** `usethis::pr_init("feat-metadata-retrieval")`.
3.  **Action:**
    *   Write `R/setup/recon/test_metadata_sources.R` to validate Yahoo API for AUM.
    *   Implement `fetch_etf_metadata(ticker)` using `httr2`.
    *   Test with `seed_universe.csv`.
4.  **Check:** Verify data quality (check for NAs).
5.  **Push:** Push to Cachix and GitHub.