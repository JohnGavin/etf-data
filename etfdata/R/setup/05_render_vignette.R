# Session Log: Render Vignette (Nix Compatible)
# Date: 2025-12-12
# Issue: #11

library(quarto)
library(withr)

pkg_path <- "finance/data/etfs/etfdata"
vignette_path <- "vignettes/analysis.qmd"
lib_path <- file.path(getwd(), pkg_path, "local_lib")

# Render
cwd <- getwd()
setwd(pkg_path)

message("Rendering vignette using lib: ", lib_path)
tryCatch({
  with_envvar(c(R_LIBS_USER = lib_path), {
    quarto_render(vignette_path)
  })
}, finally = {
  setwd(cwd)
})