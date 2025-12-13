# Deploy Site Helper Script
# Usage: Rscript deploy_site.R

# Set up local library for CI
lib_dir <- "local_lib_ci"
if (!dir.exists(lib_dir)) dir.create(lib_dir)
.libPaths(c(lib_dir, .libPaths()))

message("Installing etfdata...")
# Install from current directory (.) assuming script is run from package root
# Or if run from repo root, path is "etfdata"
pkg_path <- if (dir.exists("etfdata")) "etfdata" else "."

# Fix: remove lib arg, use .libPaths
devtools::install(pkg_path, upgrade = "never", quick = TRUE)

message("Building site...")
pkgdown::build_site(pkg_path, new_process = FALSE)