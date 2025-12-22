# ETF Data Sources & Lessons Learned

> **Status**: Findings from December 2025 investigation.
> **Context**: Evaluating reliable free sources for ETF historical data and metadata.

## Summary of Findings

| Source | Tool/Package | Capabilities | Reliability | Recommendation |
| :--- | :--- | :--- | :--- | :--- |
| **Yahoo Finance** | `tidyquant::tq_get` | Historical Prices | ✅ High | **Use for Prices** |
| **Yahoo Finance** | `quantmod::getQuote` | Real-time/Meta | ❌ Low (Crumb/GDPR errors) | **Avoid** |
| **Yahoo Finance** | `tidyquant::tq_fund_holdings` | Fund Composition | ✅ High | **Use for Holdings** |
| **Yahoo Finance** | `yahoofinancer` | Metadata/History | ❌ Unavailable (Broken/Removed) | **Do Not Use** |
| **Tiingo** | `riingo` | Prices + Meta | ✅ High (Requires API Key) | **Best for Production** |

## Detailed Lessons

### 1. Yahoo Finance "Crumb" Issues
Directly accessing Yahoo Finance API endpoints (e.g., via `quantmod::getQuote` or raw `httr2` requests) often fails due to strict cookie/"crumb" checks and GDPR consent screens, especially from headless environments (CI/CD, scripts).

### 2. The `tidyquant` Advantage
`tidyquant` wraps underlying calls effectively.
*   **`tq_get(get = "stock.prices")`**: Works reliably for historical OHLC data.
*   **`tq_fund_holdings()`**: Successfully scrapes ETF composition (sectors, weights) where other metadata calls fail.
*   **`tq_get(get = "key.stats")`**: **DEPRECATED**. Do not use.

### 3. Alternative: Tiingo (`riingo`)
For production-grade reliability, Tiingo is superior to Yahoo Finance scraping.
*   Requires free API key.
*   `riingo` package provides clean interface.
*   Adjusts for dividends/splits better than Yahoo.

## Migration Actions
*   Adopt `tq_fund_holdings()` for ETF composition data.
*   Stick to `tq_get()` for historical prices.
*   Avoid `yahoofinancer`.

## WebR and CORS (Browser Constraints)

WebR and Shinylive run inside the browser sandbox. Browsers block cross-site
requests by default unless the remote server explicitly allows them. This policy
is called CORS (Cross-Origin Resource Sharing). It prevents the WebR session
from calling JustETF or Yahoo Finance directly.

**Key consequence:** The website demos must use cached data generated on the
server side rather than live HTTP calls from the browser.

## Precompute Strategy (Targets)

To keep the site functional, the project precomputes:

1. The curated LSE ETF universe stored in the repo.
2. Optional JustETF screener metadata (AUM, TER, domicile, distribution).
3. Incremental Yahoo Finance price history per ticker (only missing dates are fetched).

Outputs are stored in:

- `inst/extdata/etf_universe_curated.csv`
- `inst/extdata/etf_universe.csv`
- `inst/extdata/history_cache.rds`
- `inst/extdata/history_summary.rds`
- `inst/extdata/vignette_data.rds`

These files are used by WebR and Shinylive so the site works without live
network access.

## Alternatives for Live Data (Server Side)

If you want live data outside the browser sandbox, consider:

- **Tiingo (`riingo`)**: Reliable, requires API key, best for production.
- **Stooq (`stooq` data via `quantmod`)**: Free, not as complete for LSE ETFs.
- **FT.com / Morningstar**: Rich data, but scraping is brittle and may violate
  terms of service.
- **LSE official data**: Most reliable, but often paid or locked behind a
  contractual feed.

## Interactive Brokers (`ibrokers`) Limitations

The `ibrokers` package connects to the Interactive Brokers API (TWS / IB Gateway).
It can be reliable for live data, but has key limitations for this project:

- Requires an IB account and a locally running TWS/IB Gateway session.
- Not suitable for WebR/Shinylive or CI (interactive login required).
- Rate limits and permissions vary by account and market data subscriptions.
- Not designed for redistributing cached data in a package.
