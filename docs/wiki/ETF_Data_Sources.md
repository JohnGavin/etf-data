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
