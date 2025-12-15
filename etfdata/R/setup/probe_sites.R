library(rvest)
library(httr2)

check_site <- function(url) {
  print(paste("Checking:", url))
  tryCatch({
    req <- request(url) %>% 
      req_headers("User-Agent" = "Mozilla/5.0") %>% 
      req_timeout(10)
    
    resp <- req_perform(req)
    html <- resp_body_html(resp)
    nodes <- html_nodes(html, "table")
    print(paste("Found", length(nodes), "tables"))
    if (length(nodes) > 0) {
      print(html_table(nodes[[1]]) %>% head())
    }
  }, error = function(e) print(e))
}

check_site("https://www.dividenddata.co.uk/ex-dividend-date-search.py?m=all") # Often simple
check_site("https://www.hl.co.uk/shares/exchange-traded-funds-etfs")
