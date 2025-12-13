# Session Log: Debug Pkgdown
# Date: 2025-12-12
# Issue: #17

library(pkgdown)
library(withr)

pkg_path <- "finance/data/etfs/etfdata"
lib_path <- file.path(getwd(), pkg_path, "local_lib")

# Ensure package is installed
library(devtools)
install(pkg_path, upgrade = "never", quick = TRUE, lib = lib_path)

cwd <- getwd()
setwd(pkg_path)

message("Building site locally...")
tryCatch({
  with_envvar(c(R_LIBS_USER = lib_path), {
    pkgdown::build_site(new_process = FALSE)
  })
}, finally = {
  setwd(cwd)
})
