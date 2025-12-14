library(httr2)
library(rvest)
library(dplyr)

url <- "https://www.justetf.com/uk/find-etf.html"

req <- request(url) %>%
  req_headers("User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/115.0")

resp <- try(req_perform(req), silent = TRUE)

if (!inherits(resp, "try-error")) {
  html <- resp_body_html(resp)
  
  # Try to find any table
  tbls <- html_table(html)
  print(paste("Found", length(tbls), "tables"))
  
  if (length(tbls) > 0) {
    print(head(tbls[[1]]))
  } else {
    print("No tables found. Content might be dynamic.")
  }
} else {
  print("Request failed")
}
