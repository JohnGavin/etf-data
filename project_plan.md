
Objective is to gather information on 
European bond and equity index ETFs (UCITS).
Restricted to those listed on the London Stock Exchange, 
in any currency.

# Sources
+ etfatlas.com
+ ft.com 
+ morningstar.com

# Method
+ API ideally 
+ Else consider the pros and cons of web scraping
	+ focus on the maintainability/stability of web scraping code, 
		+ especially for reproducability.

# Historical data to look for
## Timeseries
+ price and volume traded
	+ daily (2 years), weekly (10 years), monthly (40 years)
## Lower frequency data
+ AUM
	+ quartely (3 years)
+ Annual fee
+ average B/O spread or other liquidity measures.
