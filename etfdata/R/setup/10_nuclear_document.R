# Session Log: Nuclear Document
# Date: 2025-12-12
# Issue: #9

library(devtools)
library(fs)

pkg_path <- "finance/data/etfs/etfdata"

# Delete artifacts
if (file_exists(file.path(pkg_path, "NAMESPACE"))) file_delete(file.path(pkg_path, "NAMESPACE"))
dir_delete(file.path(pkg_path, "man"))
dir_create(file.path(pkg_path, "man"))

message("Running document...")
devtools::document(pkg_path)
