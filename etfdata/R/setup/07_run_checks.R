# Session Log: Run Checks and Pipeline
# Date: 2025-12-12
# Issue: General Maintenance

library(devtools)
library(targets)
library(fs)
library(withr)

pkg_path <- "finance/data/etfs/etfdata"
lib_path <- file.path(getwd(), pkg_path, "local_lib")

# Ensure local lib exists and is used
dir_create(lib_path)
.libPaths(c(lib_path, .libPaths()))

message("\n=== 1. Documenting Package ===")
devtools::document(pkg_path)

message("\n=== 2. Running Tests ===")
devtools::test(pkg_path)

message("\n=== 3. Running R CMD Check ===")
# error_on = "never" allows the script to continue even if there are notes
devtools::check(pkg_path, document = FALSE, error_on = "never")

message("\n=== 4. Running Targets Pipeline ===")
cwd <- getwd()
setwd(pkg_path)
tryCatch({
  # Install package first to ensure targets can load it
  install(upgrade = "never", quick = TRUE, lib = lib_path)
  
  with_envvar(c(R_LIBS_USER = lib_path), {
    tar_make()
  })
}, finally = {
  setwd(cwd)
})

