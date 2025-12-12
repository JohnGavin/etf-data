# Session Log: Run Targets Pipeline (Nix Compatible)
# Date: 2025-12-12
# Issue: #9

library(devtools)
library(targets)
library(fs)

# Path to package
pkg_path <- "finance/data/etfs/etfdata"
lib_path <- file.path(getwd(), pkg_path, "local_lib")

# Create local library
dir_create(lib_path)

# Update libPaths
.libPaths(c(lib_path, .libPaths()))

message("Installing etfdata to local library: ", lib_path)
install(pkg_path, upgrade = "never", quick = TRUE, lib = lib_path)

# Run targets
# We must change directory to where _targets.R is
cwd <- getwd()
setwd(pkg_path)

message("Running targets pipeline...")
tryCatch({
  # Explicitly set env var for the callr process used by targets
  withr::with_envvar(c(R_LIBS_USER = lib_path), {
    tar_make()
  })
}, finally = {
  setwd(cwd)
})