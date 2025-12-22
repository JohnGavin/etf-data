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
# nix-shell default.nix --run "Rscript --vanilla -e 'setwd(\"etfdata\"); source(\"R/setup/generate_nix_files.R\")'"
#   - generated package.nix
# nix-shell default.nix --run "Rscript --vanilla -e 'setwd(\"etfdata\"); devtools::load_all(); fetch_justetf_screener(source=\"api\", quiet=FALSE)'"
#   - no data; request failed before response body was available
# caffeinate -i /Users/johngavin/docs_gh/llm/default.sh
#   - default.R regeneration failed: SSL peer certificate for available_df.csv
# SSL_CERT_FILE=/etc/ssl/cert.pem caffeinate -i /Users/johngavin/docs_gh/llm/default.sh
#   - same SSL failure; default.nix parse error fixed manually
# nix-shell /Users/johngavin/docs_gh/llm/default.nix --run "cd /Users/johngavin/docs_gh/llm/finance/data/etfs/etfdata && bash /Users/johngavin/docs_gh/claude_rix/push_to_cachix.sh"
#   - failed: missing CACHIX_AUTH_TOKEN / CACHIX_SIGNING_KEY
# nix-shell /Users/johngavin/docs_gh/llm/default.nix --run "Rscript --vanilla -e 'setwd(\"etfdata\"); devtools::load_all(); fetch_justetf_screener(source=\"api\", quiet=FALSE)'"
#   - logged HTTP 404 response from JustETF API
