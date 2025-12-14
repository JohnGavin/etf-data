library(httr2)
library(rvest)
library(dplyr)

url <- "https://finance.yahoo.com/screener/predefined/top_rated_etfs"

req <- request(url) %>%
  req_headers("User-Agent" = "Mozilla/5.0")

resp <- try(req_perform(req), silent = TRUE)

if (!inherits(resp, "try-error")) {
  html <- resp_body_html(resp)
  tbls <- html_table(html)
  print(paste("Found", length(tbls), "tables"))
  if (length(tbls) > 0) {
    print(head(tbls[[1]]))
  }
}
