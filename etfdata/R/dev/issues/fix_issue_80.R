# Issue: #80
# Topic: Precompute LSE ETF data for WebR + document CORS
# Date: 2025-12-21

# Planned / executed commands (fill as run):
# Rscript --vanilla -e 'setwd("etfdata"); devtools::document()'
# R CMD INSTALL --library=$HOME/.Rlibs_etf etfdata
# R_LIBS_USER=$HOME/.Rlibs_etf Rscript --vanilla -e 'setwd("etfdata"); targets::tar_make()'
#   - failed: JustETF fetch returned no data (network blocked / empty columns)
# Rscript --vanilla -e 'setwd("etfdata"); devtools::document()'
# R CMD INSTALL --library=$HOME/.Rlibs_etf etfdata
# R_LIBS_USER=$HOME/.Rlibs_etf Rscript --vanilla -e 'setwd("etfdata"); targets::tar_make()'
#   - failed: JustETF fetch returned no data (network blocked / empty columns)
# Rscript --vanilla -e 'setwd("etfdata"); devtools::document()'
# R CMD INSTALL --library=$HOME/.Rlibs_etf etfdata
# R_LIBS_USER=$HOME/.Rlibs_etf Rscript --vanilla -e 'setwd("etfdata"); targets::tar_make()'
#   - success
# Rscript --vanilla -e 'devtools::test()'
# Rscript --vanilla -e 'setwd("etfdata"); devtools::check()'
#   - success
# Rscript --vanilla -e 'setwd("etfdata"); pkgdown::build_site()'
#   - failed outside nix: Rscript not found (native R required)
# Rscript --vanilla -e 'setwd("etfdata"); dir.create(".tmp", showWarnings = FALSE); Sys.setenv(TMPDIR = file.path(getwd(), ".tmp")); pkgdown::build_site(devel = TRUE, preview = FALSE)'
#   - success
# nix-shell default.nix --run "R_LIBS_USER=$HOME/.Rlibs_etf Rscript --vanilla -e 'setwd(\"etfdata\"); targets::tar_make()'"
#   - success (history cache + vignette snapshot)
# nix-shell default.nix --run "R_LIBS_USER=$HOME/.Rlibs_etf Rscript --vanilla -e 'setwd(\"etfdata\"); devtools::check()'"
#   - success (0 errors/warnings/notes after .Rbuildignore + RDS version change)
# nix-shell default.nix --run "mkdir -p etfdata/.tmp && TMPDIR=$PWD/etfdata/.tmp R_LIBS_USER=$HOME/.Rlibs_etf Rscript --vanilla -e 'setwd(\"etfdata\"); pkgdown::build_site(devel = TRUE, preview = FALSE)'"
#   - success
# Removed stray $HOME directory from repo.
# Added HOME fallback guards in default.sh/default.R/default.nix.
# Updated RDS saves to version = 2 and ignored docs/vignettes/.quarto in .Rbuildignore.
