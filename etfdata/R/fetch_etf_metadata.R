#' Fetch ETF Metadata from JustETF
#'
#' Scrapes metadata (AUM, TER, etc.) for a given ETF ISIN from JustETF.
#'
#' @param isin Character string. The ISIN of the ETF (e.g., "IE00B3XXRP09").
#'
#' @return A tibble with metadata columns.
#' @export
#'
#' @importFrom httr2 request req_headers req_perform resp_body_html resp_status
#' @importFrom rvest html_table
#' @importFrom dplyr filter select pull bind_rows
#' @importFrom tibble tibble
#' @importFrom stringr str_detect
#' @importFrom purrr map_dfr
#' @importFrom stats runif
fetch_etf_metadata <- function(isin) {
  url <- paste0("https://www.justetf.com/uk/etf-profile.html?isin=", isin)
  
  # Polite delay
  Sys.sleep(runif(1, 1, 2))
  
  req <- request(url) %>%
    req_headers("User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/115.0")
  
  resp <- try(req_perform(req), silent = TRUE)
  
  if (inherits(resp, "try-error")) {
    warning("Failed to fetch metadata for ", isin)
    return(tibble(isin = isin))
  }
  
  if (resp_status(resp) != 200) {
    warning("HTTP error ", resp_status(resp), " for ", isin)
    return(tibble(isin = isin))
  }
  
  html <- resp_body_html(resp)
  tables <- html_table(html)
  
  # Helper to extract value from key-value tables (X1, X2)
  get_val <- function(key_pattern) {
    # Search all tables for the key
    for (tbl in tables) {
      if (ncol(tbl) >= 2) {
        # Check if first col contains key
        match <- tbl[str_detect(tbl[[1]], key_pattern), ]
        if (nrow(match) > 0) {
          return(match[[2]][1])
        }
      }
    }
    return(NA_character_)
  }
  
  # Extract fields
  aum_raw <- get_val("Fund size")
  ter_raw <- get_val("Total expense ratio")
  replication <- get_val("Replication")
  dist_policy <- get_val("Distribution policy")
  domicile <- get_val("Fund domicile")
  
  tibble(
    isin = isin,
    aum_text = aum_raw,
    ter_text = ter_raw,
    replication = replication,
    distribution = dist_policy,
    domicile = domicile,
    source_url = url
  )
}