#' Fetch ETF Data from JustETF
#'
#' Retrieves a list of ETFs from JustETF, applying optional filters for
#' AUM and TER. The function first tries the legacy JSON API, then falls back
#' to the JustETF search table endpoint if needed.
#'
#' @param min_aum_gbp Numeric. Minimum Assets Under Management in GBP (millions). Default is 0.
#' @param max_ter Numeric. Maximum Total Expense Ratio (percentage). Default is Inf.
#' @param page_size Integer. Number of rows per page when paging the table endpoint.
#' @param max_pages Integer. Maximum number of pages to fetch when paging. Default Inf.
#' @param source Character. Data source preference: "auto", "api", or "wicket".
#' @param quiet Logical. If TRUE, suppresses warnings when endpoints fail.
#'
#' @return A tibble containing the filtered ETF data.
#' @export
#'
#' @importFrom httr2 request req_method req_body_json req_body_raw req_headers req_perform
#'   resp_body_json resp_body_string resp_status
#' @importFrom dplyr filter mutate select
#' @importFrom janitor clean_names
#' @importFrom stringr str_match str_starts
#' @importFrom readr parse_number
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#'   etfs <- fetch_justetf_screener()
#'   print(etfs)
#' }
fetch_justetf_screener <- function(min_aum_gbp = 0,
                                   max_ter = Inf,
                                   page_size = 500,
                                   max_pages = Inf,
                                   source = c("auto", "api", "wicket"),
                                   quiet = FALSE) {
  source <- match.arg(source)

  df <- dplyr::tibble()
  if (source != "wicket") {
    df <- try_justetf_api(quiet = quiet)
  }
  if (nrow(df) == 0 && source != "api") {
    df <- try_justetf_wicket(
      page_size = page_size,
      max_pages = max_pages,
      quiet = quiet
    )
  }

  if (nrow(df) == 0) {
    if (!quiet) {
      warning("No data returned from JustETF endpoints.")
    }
    return(dplyr::tibble())
  }

  df <- normalize_justetf_df(df)
  if (!any(c("isin", "ticker", "name") %in% names(df))) {
    if (!quiet) {
      warning("JustETF response missing expected columns.")
    }
    return(dplyr::tibble())
  }
  df <- apply_screener_filters(df, min_aum_gbp, max_ter)
  df
}

try_justetf_api <- function(quiet = FALSE) {
  url <- "https://www.justetf.com/api/etfs/en/search"
  req <- httr2::request(url) %>%
    httr2::req_body_json(list(
      draw = 1,
      start = 0,
      length = -1,
      search = list(value = "", regex = FALSE),
      country = "GB",
      universeType = "private"
    )) %>%
    httr2::req_headers(
      "User-Agent" = "Mozilla/5.0 (R; etfdata package)",
      "Content-Type" = "application/json"
    )

  resp <- try(httr2::req_perform(req), silent = TRUE)
  if (inherits(resp, "try-error")) {
    if (!quiet) {
      warning("JustETF API request failed.")
    }
    return(dplyr::tibble())
  }

  if (httr2::resp_status(resp) != 200) {
    if (!quiet) {
      warning("JustETF API status ", httr2::resp_status(resp))
    }
    return(dplyr::tibble())
  }

  json_data <- httr2::resp_body_json(resp)
  parse_justetf_json(json_data)
}

try_justetf_wicket <- function(page_size = 500, max_pages = Inf, quiet = FALSE) {
  search_url <- "https://www.justetf.com/uk/search.html?search=ETFS"
  search_req <- httr2::request(search_url) %>%
    httr2::req_headers(
      "User-Agent" = "Mozilla/5.0 (R; etfdata package)",
      "Accept" = "text/html"
    )
  search_resp <- try(httr2::req_perform(search_req), silent = TRUE)
  if (inherits(search_resp, "try-error")) {
    if (!quiet) {
      warning("JustETF search page request failed.")
    }
    return(dplyr::tibble())
  }

  search_html <- httr2::resp_body_string(search_resp)
  callback_url <- extract_wicket_callback(search_html)
  if (is.na(callback_url)) {
    if (!quiet) {
      warning("JustETF search callback URL not found.")
    }
    return(dplyr::tibble())
  }

  first <- fetch_wicket_page(
    callback_url = callback_url,
    search_url = search_url,
    start = 0,
    length = page_size,
    draw = 1,
    quiet = quiet
  )

  df <- first$data
  total <- first$total
  if (is.na(total) || nrow(df) == 0) {
    return(df)
  }

  if (nrow(df) >= total) {
    return(df)
  }

  page_count <- ceiling(total / page_size)
  if (is.finite(max_pages)) {
    page_count <- min(page_count, max_pages)
  }

  if (page_count <= 1) {
    return(df)
  }

  pages <- vector("list", page_count)
  pages[[1]] <- df
  if (page_count > 1) {
    for (i in 2:page_count) {
      Sys.sleep(0.5)
      page <- fetch_wicket_page(
        callback_url = callback_url,
        search_url = search_url,
        start = (i - 1) * page_size,
        length = page_size,
        draw = i,
        quiet = quiet
      )
      pages[[i]] <- page$data
    }
  }

  dplyr::bind_rows(pages)
}

fetch_wicket_page <- function(callback_url,
                              search_url,
                              start,
                              length,
                              draw,
                              quiet = FALSE) {
  body <- list(
    draw = draw,
    start = start,
    length = length,
    "search[value]" = "",
    "search[regex]" = "false",
    "order[0][column]" = "0",
    "order[0][dir]" = "asc"
  )
  body_string <- encode_form_body(body)

  req <- httr2::request(callback_url) %>%
    httr2::req_method("POST") %>%
    httr2::req_body_raw(
      body_string,
      type = "application/x-www-form-urlencoded"
    ) %>%
    httr2::req_headers(
      "User-Agent" = "Mozilla/5.0 (R; etfdata package)",
      "X-Requested-With" = "XMLHttpRequest",
      "Content-Type" = "application/x-www-form-urlencoded; charset=UTF-8",
      "Referer" = search_url
    )

  resp <- try(httr2::req_perform(req), silent = TRUE)
  if (inherits(resp, "try-error")) {
    if (!quiet) {
      warning("JustETF table request failed.")
    }
    return(list(data = dplyr::tibble(), total = NA_integer_))
  }

  text <- httr2::resp_body_string(resp)
  parsed <- parse_justetf_text(text)
  parsed
}

encode_form_body <- function(body) {
  keys <- names(body)
  if (is.null(keys)) {
    return("")
  }

  key_enc <- vapply(
    keys,
    function(key) utils::URLencode(key, reserved = TRUE),
    character(1)
  )
  val_enc <- vapply(
    body,
    function(value) {
      if (is.null(value) || length(value) == 0) {
        return("")
      }
      utils::URLencode(as.character(value), reserved = TRUE)
    },
    character(1)
  )

  paste0(key_enc, "=", val_enc, collapse = "&")
}

extract_wicket_callback <- function(html) {
  match <- stringr::str_match(html, "fetchCallbackUrl\\s*=\\s*['\\\"]([^'\\\"]+)['\\\"]")
  if (is.na(match[, 2])) {
    return(NA_character_)
  }

  url <- match[, 2]
  if (stringr::str_starts(url, "http")) {
    return(url)
  }
  paste0("https://www.justetf.com", url)
}

parse_justetf_json <- function(json_data) {
  if (!is.list(json_data) || is.null(json_data$data)) {
    return(dplyr::tibble())
  }

  if (is.data.frame(json_data$data)) {
    return(tibble::as_tibble(json_data$data, .name_repair = "unique"))
  }

  data <- dplyr::bind_rows(json_data$data)
  tibble::as_tibble(data, .name_repair = "unique")
}

parse_justetf_text <- function(text) {
  parsed <- try(jsonlite::fromJSON(text), silent = TRUE)
  if (!inherits(parsed, "try-error")) {
    data <- parse_justetf_json(parsed)
    total <- parsed$recordsTotal
    if (is.null(total)) {
      total <- nrow(data)
    }
    return(list(data = data, total = total))
  }

  html <- try(rvest::read_html(text), silent = TRUE)
  if (inherits(html, "try-error")) {
    return(list(data = dplyr::tibble(), total = NA_integer_))
  }

  tables <- rvest::html_table(html, fill = TRUE)
  if (length(tables) == 0) {
    return(list(data = dplyr::tibble(), total = NA_integer_))
  }

  data <- tibble::as_tibble(tables[[1]], .name_repair = "unique")
  list(data = data, total = nrow(data))
}

normalize_justetf_df <- function(df) {
  df <- janitor::clean_names(df)

  df <- assign_candidate(df, "isin", c("isin", "isin_code"))
  df <- assign_candidate(df, "ticker", c("ticker", "symbol", "exchange_ticker", "fund_ticker"))
  df <- assign_candidate(df, "name", c("name", "fund_name", "fund"))
  df <- assign_candidate(df, "currency", c("currency", "fund_currency", "fund_currency_code"))
  df <- assign_candidate(df, "aum_text", c("aum_text", "fund_size", "aum"))
  df <- assign_candidate(df, "ter_text", c("ter_text", "ter", "total_expense_ratio"))
  df <- assign_candidate(df, "replication", c("replication", "replication_method"))
  df <- assign_candidate(df, "distribution", c("distribution", "distribution_policy", "dist_policy"))
  df <- assign_candidate(df, "domicile", c("domicile", "fund_domicile", "fund_domicile_country"))

  if (!"aum_num" %in% names(df) && "aum_text" %in% names(df)) {
    df <- df %>% dplyr::mutate(aum_num = readr::parse_number(as.character(.data$aum_text)))
  }

  if (!"ter_num" %in% names(df) && "ter_text" %in% names(df)) {
    df <- df %>% dplyr::mutate(ter_num = readr::parse_number(as.character(.data$ter_text)))
  }

  df
}

assign_candidate <- function(df, target, candidates) {
  if (target %in% names(df)) {
    return(df)
  }

  src <- intersect(candidates, names(df))
  if (length(src) == 0) {
    return(df)
  }

  df[[target]] <- df[[src[1]]]
  df
}

apply_screener_filters <- function(df, min_aum_gbp, max_ter) {
  if (is.null(min_aum_gbp) || is.na(min_aum_gbp)) {
    min_aum_gbp <- 0
  }
  if (is.null(max_ter) || is.na(max_ter)) {
    max_ter <- Inf
  }

  if (!"aum_num" %in% names(df)) {
    df$aum_num <- NA_real_
  }
  if (!"ter_num" %in% names(df)) {
    df$ter_num <- NA_real_
  }

  df %>%
    dplyr::filter(
      is.na(.data$aum_num) | .data$aum_num >= min_aum_gbp,
      is.na(.data$ter_num) | .data$ter_num <= max_ter
    )
}
