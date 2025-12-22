# _targets.R
library(targets)
library(tarchetypes)

# Set target options:
tar_option_set(
  packages = c("etfdata", "tibble", "dplyr", "purrr", "readr", "lubridate"),
  format = "rds"
)

select_universe_cols_local <- function(df) {
  cols <- intersect(c("ticker", "name", "isin", "currency"), names(df))
  if (length(cols) == 0) {
    return(df)
  }
  df[, cols, drop = FALSE]
}

read_curated_universe <- function(path = "inst/extdata/etf_universe_curated.csv") {
  if (!file.exists(path)) {
    stop("Curated universe file not found at: ", path)
  }
  readr::read_csv(path, show_col_types = FALSE)
}

update_history_cache <- function(tickers,
                                 cache_path,
                                 start_date,
                                 end_date,
                                 timeout_seconds = 10) {
  end_date <- as.Date(end_date)
  start_date <- as.Date(start_date)

  old_timeout <- getOption("timeout")
  options(timeout = timeout_seconds)
  on.exit(options(timeout = old_timeout), add = TRUE)

  history <- tibble::tibble(ticker = character(), date = as.Date(character()))
  if (file.exists(cache_path)) {
    history <- readRDS(cache_path)
    if (nrow(history) > 0) {
      history <- history %>%
        dplyr::mutate(date = as.Date(.data$date))
    } else if (!all(c("ticker", "date") %in% names(history))) {
      history <- tibble::tibble(ticker = character(), date = as.Date(character()))
    }
  } else if (!all(c("ticker", "date") %in% names(history))) {
    history <- tibble::tibble(ticker = character(), date = as.Date(character()))
  }

  tickers <- unique(na.omit(tickers))
  if (length(tickers) == 0) {
    saveRDS(history, cache_path)
    return(list(
      history = history,
      summary = tibble::tibble(
        ticker = character(),
        rows = integer(),
        rows_added = integer(),
        min_date = as.Date(character()),
        max_date = as.Date(character()),
        expected_start = as.Date(character()),
        expected_end = as.Date(character()),
        missing_start = as.Date(character()),
        missing_end = as.Date(character()),
        ok = logical()
      )
    ))
  }

  summary_list <- vector("list", length(tickers))
  history_list <- vector("list", length(tickers))

  for (i in seq_along(tickers)) {
    ticker <- tickers[[i]]
    existing <- history %>% dplyr::filter(.data$ticker == ticker)
    min_date <- if (nrow(existing) > 0) min(existing$date, na.rm = TRUE) else NA
    max_date <- if (nrow(existing) > 0) max(existing$date, na.rm = TRUE) else NA

    ranges <- list()
    if (is.na(min_date) || is.na(max_date)) {
      ranges <- list(c(start_date, end_date))
    } else {
      if (min_date > start_date) {
        ranges <- append(ranges, list(c(start_date, min_date - 1)))
      }
      if (max_date < end_date) {
        ranges <- append(ranges, list(c(max_date + 1, end_date)))
      }
    }

    new_data <- tibble::tibble()
    if (length(ranges) > 0) {
      for (range in ranges) {
        if (range[1] <= range[2]) {
          fetched <- tryCatch(
            fetch_price_history(ticker, start_date = range[1], end_date = range[2]),
            error = function(e) NULL
          )
          if (!is.null(fetched) && nrow(fetched) > 0) {
            new_data <- dplyr::bind_rows(new_data, fetched)
          }
        }
      }
    }

    combined <- dplyr::bind_rows(existing, new_data) %>%
      dplyr::distinct(.data$ticker, .data$date, .keep_all = TRUE) %>%
      dplyr::arrange(.data$date)

    min_combined <- if (nrow(combined) > 0) min(combined$date, na.rm = TRUE) else NA
    max_combined <- if (nrow(combined) > 0) max(combined$date, na.rm = TRUE) else NA
    if (is.na(min_combined) || is.na(max_combined)) {
      missing_start <- start_date
      missing_end <- end_date
      ok <- FALSE
    } else {
      missing_start <- if (min_combined > start_date) start_date else NA
      missing_end <- if (max_combined < end_date) end_date else NA
      ok <- is.na(missing_start) && is.na(missing_end)
    }

    history_list[[i]] <- combined
    summary_list[[i]] <- tibble::tibble(
      ticker = ticker,
      rows = nrow(combined),
      rows_added = nrow(new_data),
      min_date = min_combined,
      max_date = max_combined,
      expected_start = start_date,
      expected_end = end_date,
      missing_start = missing_start,
      missing_end = missing_end,
      ok = ok
    )
  }

  history <- dplyr::bind_rows(history_list)
  summary <- dplyr::bind_rows(summary_list)

  saveRDS(history, cache_path, version = 2)
  list(history = history, summary = summary)
}

# Define the pipeline
list(
  # 1. Curated universe (manual list stored in the repo)
  tar_target(
    universe_curated,
    read_curated_universe()
  ),

  # 2. Fetch full screener data (optional, for metadata enrichment)
  tar_target(
    screener_raw,
    fetch_justetf_screener(min_aum_gbp = 0, max_ter = Inf)
  ),
  
  # 3. Universe derived from curated list
  tar_target(
    universe,
    {
      screener_clean <- select_universe_cols_local(screener_raw)
      curated_clean <- select_universe_cols_local(universe_curated)
      if (nrow(screener_clean) == 0) {
        curated_clean
      } else {
        dplyr::bind_rows(curated_clean, screener_clean) %>%
          dplyr::distinct()
      }
    }
  ),
  
  # 4. Price history for all tickers (incremental update)
  tar_target(
    tickers,
    unique(na.omit(universe$ticker))
  ),

  tar_target(
    history_cache,
    update_history_cache(
      tickers = tickers,
      cache_path = "inst/extdata/history_cache.rds",
      start_date = as.Date("2000-01-01"),
      end_date = Sys.Date(),
      timeout_seconds = 10
    )
  ),

  tar_target(
    history_cache_file,
    {
      saveRDS(history_cache$history, "inst/extdata/history_cache.rds", version = 2)
      saveRDS(history_cache$summary, "inst/extdata/history_summary.rds", version = 2)
      c("inst/extdata/history_cache.rds", "inst/extdata/history_summary.rds")
    },
    format = "file"
  ),

  tar_target(
    history,
    history_cache$history
  ),

  tar_target(
    history_summary,
    history_cache$summary
  ),
  
  # 5. Save Vignette Data (Snapshot)
  tar_target(
    vignette_snapshot,
    {
      if(!dir.exists("inst/extdata")) dir.create("inst/extdata", recursive = TRUE)
      readr::write_csv(universe, "inst/extdata/etf_universe.csv")
      saveRDS(
        list(
          universe = universe,
          metadata = if (nrow(screener_raw) > 0) screener_raw else universe,
          history = history,
          history_summary = history_summary,
          generated_at = Sys.time(),
          source = if (nrow(screener_raw) > 0) "justetf+curated" else "curated"
        ),
        "inst/extdata/vignette_data.rds",
        version = 2
      )
      "inst/extdata/vignette_data.rds"
    },
    format = "file"
  )
)
