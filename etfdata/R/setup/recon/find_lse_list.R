# Session Log: Find LSE ETF List
# Date: 2025-12-12
# Issue: #7

library(httr2)
library(rvest)
library(stringr)

# URL for LSE Instrument Reports
url <- "https://www.londonstockexchange.com/reports?tab=instrument-reports"

# This page is likely React-rendered, so rvest might not see the links if they are dynamically loaded.
# However, often the "Download" links are static or accessible via a known API.

# Let's try to fetch the page and look for "xls" or "csv" links related to ETFs.
message("Fetching LSE Reports page...")

# Note: LSE might block bots. Need User-Agent.
req <- request(url) %>%
  req_headers("User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/115.0")

resp <- try(req_perform(req), silent = TRUE)

if (inherits(resp, "try-error")) {
  message("Failed to fetch page: ", resp)
} else {
  message("Status: ", resp_status(resp))
  
  html <- resp_body_html(resp)
  
  # Look for links
  links <- html %>% html_nodes("a") %>% html_attr("href")
  
  # Filter for xls/csv and "ETF" or "ETP"
  etf_links <- links[str_detect(links, "(?i)etf|etp") & str_detect(links, "(?i)xls|csv|xlsx")]
  
  if (length(etf_links) > 0) {
    message("Found potential ETF lists:")
    print(etf_links)
  } else {
    message("No direct ETF links found on this page. Might be dynamic.")
    # Try a known location for the file
    # https://docs.londonstockexchange.com/sites/default/files/reports/ETFs_ETPs.xls
    
    test_url <- "https://docs.londonstockexchange.com/sites/default/files/reports/ETFs_ETPs.xls"
    message("Testing known URL: ", test_url)
    
    req_file <- request(test_url) %>% req_method("HEAD")
    resp_file <- try(req_perform(req_file), silent = TRUE)
    
    if (!inherits(resp_file, "try-error") && resp_status(resp_file) == 200) {
      message("Confirmed: Known URL exists!")
    } else {
      message("Known URL failed.")
    }
  }
}
