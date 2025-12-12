# Session Log: Find iShares ETF List
# Date: 2025-12-12
# Issue: #7

library(httr2)
library(rvest)
library(stringr)

url <- "https://www.ishares.com/uk/professional/en/products/etf-investments"

message("Fetching iShares product page...")
req <- request(url) %>%
  req_headers("User-Agent" = "Mozilla/5.0")

resp <- try(req_perform(req), silent = TRUE)

if (inherits(resp, "try-error")) {
  message("Failed to fetch iShares page")
} else {
  html <- resp_body_html(resp)
  
  # Look for links containing "xls" or "csv"
  links <- html %>% html_nodes("a") %>% html_attr("href")
  download_links <- links[str_detect(links, "(?i)xls|csv") & str_detect(links, "(?i)product")]
  
  if (length(download_links) > 0) {
    message("Found iShares download links:")
    print(download_links)
  } else {
    message("No direct download links found. Trying search...")
    # Try constructing the URL
    # https://www.ishares.com/uk/professional/en/literature/product-screener/ishares-product-screener-en-gb.xlsx
    
    known_url <- "https://www.ishares.com/uk/professional/en/literature/product-screener/ishares-product-screener-en-gb.xlsx"
    message("Testing known URL: ", known_url)
    
    req_file <- request(known_url) %>% req_method("HEAD") %>% req_headers("User-Agent" = "Mozilla/5.0")
    resp_file <- try(req_perform(req_file), silent = TRUE)
    
    if (!inherits(resp_file, "try-error") && resp_status(resp_file) == 200) {
      message("Confirmed: Known URL exists!")
    } else {
      message("Known URL failed.")
    }
  }
}
