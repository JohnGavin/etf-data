# Session Log: Fix Dependencies
# Date: 2025-12-12
# Issue: #9

library(desc)

pkg_path <- "finance/data/etfs/etfdata"
desc_path <- file.path(pkg_path, "DESCRIPTION")

d <- description$new(desc_path)

deps <- c(
  "dplyr", "httr2", "lubridate", "magrittr", "purrr", 
  "quantmod", "readr", "rvest", "stringr", "tibble"
)

for (pkg in deps) {
  d$set_dep(pkg, type = "Imports")
}

d$write(desc_path)

message("Added dependencies to DESCRIPTION.")
