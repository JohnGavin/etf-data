# Session Log: Test JustETF Scraping
# Date: 2025-12-12
# Issue: #9

library(rvest)
library(httr2)

isin <- "IE00B3XXRP09" # VUSA
url <- paste0("https://www.justetf.com/uk/etf-profile.html?isin=", isin)

message("Fetching JustETF profile for ", isin, "...")

req <- request(url) %>%
  req_headers("User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/115.0")

resp <- try(req_perform(req), silent = TRUE)

if (inherits(resp, "try-error")) {
  message("Failed to fetch: ", resp)
} else {
  message("Status: ", resp_status(resp))
  html <- resp_body_html(resp)
  
  # Try to find AUM (Fund size)
  # Look for "Fund size" label
  # Structure is often tables or divs
  
  # Extract all text to check visibility
  text <- html %>% html_text()
  if (grepl("Fund size", text)) {
    message("Found 'Fund size' on page!")
    
    # Try to extract exact value
    # Often in a table row: <td>Label</td><td>Value</td>
    # or val labels
    
    # Example selector (needs inspection, but guessing generic)
    val <- html %>% 
      html_elements("div.val") %>% 
      html_text(trim = TRUE)
      
    # Print a sample of content to help debug
    print(head(val, 10))
    
    # Try table approach
    tables <- html %>% html_table()
    print(tables)
    
  } else {
    message("'Fund size' not found in text. Dynamic rendering?")
  }
}
