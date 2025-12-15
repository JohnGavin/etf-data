#' Parse AUM Text
#'
#' Converts an AUM (Assets Under Management) string (e.g., "GBP 100,642 m") into structured components.
#'
#' @param aum_text Character vector. The AUM string(s) to parse.
#'
#' @return A tibble with columns: currency (factor), aum_amount (numeric), aum_units (factor), aum_units_amount (numeric).
#' @export
#'
#' @importFrom stringr str_match str_remove_all
#' @importFrom dplyr mutate case_when
#' @importFrom tibble tibble
#' @importFrom rlang .data
#' @examples
#' parse_aum("GBP 100,642 m")
parse_aum <- function(aum_text) {
  # Regex to capture: (Currency) (Amount) (Unit)
  # Amount might have commas. Unit is optional (m, bn, etc)
  pattern <- "^([A-Z]{3})\\s+([0-9.,]+)\\s?([a-zA-Z]+)?$"
  
  matches <- stringr::str_match(aum_text, pattern)
  
  df <- tibble::tibble(
    currency = factor(matches[, 2]),
    raw_amount = matches[, 3],
    aum_units = factor(matches[, 4])
  )
  
  df <- df %>%
    dplyr::mutate(
      aum_amount = as.numeric(stringr::str_remove_all(.data$raw_amount, ",")),
      aum_units_amount = dplyr::case_when(
        .data$aum_units == "m" ~ 1e6,
        .data$aum_units == "bn" ~ 1e9,
        TRUE ~ 1
      ),
      total_amount = .data$aum_amount * .data$aum_units_amount
    ) %>%
    dplyr::select(-.data$raw_amount)
  
  return(df)
}
