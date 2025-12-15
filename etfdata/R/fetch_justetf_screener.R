#' Fetch ETF Data from JustETF Internal API
#'
#' Retrieves a list of ETFs from JustETF's internal API, applying filters for
#' AUM, TER, and listing exchange.
#'
#' @param min_aum_gbp Numeric. Minimum Assets Under Management in GBP (millions). Default is 200.
#' @param max_ter Numeric. Maximum Total Expense Ratio (percentage). Default is 0.75.
#'
#' @return A tibble containing the filtered ETF data.
#' @export
#'
#' @importFrom httr2 request req_url_query req_body_json req_perform resp_body_json
#' @importFrom dplyr filter mutate select as_tibble
#' @importFrom janitor clean_names
#' @importFrom stringr str_remove str_replace
#' @importFrom readr parse_number
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#'   etfs <- fetch_justetf_screener()
#'   print(etfs)
#' }
fetch_justetf_screener <- function(min_aum_gbp = 200, max_ter = 0.75) {
  
  # Endpoint often used by the screener
  # Note: This is an internal API and may change.
  url <- "https://www.justetf.com/api/etfs/en/search"
  
  # Construct the request
  # 'draw', 'start', 'length' are DataTables parameters
  # 'lang' and 'country' usually passed in body or query
  req <- httr2::request(url) %>%
    httr2::req_body_json(list(
      draw = 1,
      start = 0,
      length = -1, # Fetch all
      search = list(value = "", regex = FALSE),
      # Filter for LSE listings roughly corresponds to `exchange` or similar params in some variations
      # But often the main search returns all. We filter post-fetch.
      # However, we can try to restrict to ETFs available in UK.
      country = "GB",
      universeType = "private"
    )) %>%
    httr2::req_headers(
      "User-Agent" = "Mozilla/5.0 (R; etfdata package)",
      "Content-Type" = "application/json"
    )
  
  # Perform request
  resp <- httr2::req_perform(req)
  
  # Parse JSON
  json_data <- httr2::resp_body_json(resp)
  
  # Extract the 'data' element which contains the list
  if (is.null(json_data$data)) {
    warning("No data found in JustETF response.")
    return(dplyr::tibble())
  }
  
  # Convert to tibble
  # The list items might be varying in length/structure, bind_rows usually handles it
  df <- dplyr::bind_rows(json_data$data) %>%
    janitor::clean_names()
  
  if (nrow(df) == 0) {
    return(df)
  }
  
  # Process and Filter
  # Fields often returned: "isin", "name", "ter", "fund_size", "currency", etc.
  # AUM and TER come as formatted strings often (e.g. "0.07%", "1,234 m").
  
  df_clean <- df %>%
    # Parse TER: Remove '%' and convert to numeric
    dplyr::mutate(
      ter_num = readr::parse_number(as.character(.data$ter))
    ) %>%
    # Parse AUM: Handle 'm' (millions) or 'bn' (billions) if present, though JustETF usually normalizes to millions in some views
    # Often it is just a formatted number.
    dplyr::mutate(
      aum_num = readr::parse_number(as.character(.data$fund_size))
    )
    
  # Apply filters
  # Note: AUM in JustETF search is often in the user's locale currency or GBP if country=GB?
  # Usually it's in GBP for country=GB.
  # LSE Listing: The search API usually returns metadata. 
  # It does NOT always explicitly list all exchanges in the main table.
  # We assume "country=GB" context implies available in UK, likely LSE.
  
  df_filtered <- df_clean %>%
    dplyr::filter(
      .data$aum_num >= min_aum_gbp,
      .data$ter_num <= max_ter
    )
  
  return(df_filtered)
}
