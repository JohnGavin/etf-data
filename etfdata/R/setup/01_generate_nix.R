# Session Log: Generate Nix Environment
# Date: 2025-12-12
# Issue: #5

library(rix)

# Define path
pkg_path <- "finance/data/etfs/etfdata"

# Define packages
r_pkgs <- c(
  # Core Data Fetching
  "httr2", "rvest", "jsonlite", "xml2", "curl",
  # Financial Data Specific
  "quantmod", "tidyquant",
  # Tidyverse & Data Manipulation
  "dplyr", "tibble", "readr", "janitor", "tidyr", "stringr", "purrr", "lubridate",
  # Excel Reading
  "readxl",
  # Pipeline
  "targets", "tarchetypes",
  # Documentation
  "pkgdown", "quarto", "visNetwork", # Added quarto R package and visNetwork
  # Development
  "devtools", "usethis", "testthat", "lintr", "languageserver", "yahoofinancer"
)

# System packages
system_pkgs <- c("quarto", "git", "pandoc")

# Generate nix files
rix(
  r_ver = "4.5.2",
  r_pkgs = r_pkgs,
  system_pkgs = system_pkgs,
  ide = "none",
  project_path = pkg_path,
  overwrite = TRUE,
  print = TRUE
)

message("Nix files generated in ", pkg_path)
