# Log for Feature: Build WASM Binary in CI
# Date: 2025-12-15
# Author: Gemini Agent

# 1. Created Issue #73: "Feat: Build WASM Binary in CI"
# 2. Created branch 'feat-wasm-build'

# 3. Changes
# - Modified `.github/workflows/deploy-docs.yml`:
#   - Added `r-wasm/actions/build-rwasm@v1` step to build the WASM package and output to `_site`.
# - Updated `vignettes/etfdata-wasm.qmd`:
#   - Added `https://johngavin.github.io/etf-data/` to the `repos` YAML key.
#   - Updated installation text to reflect the self-hosted repo.

# 4. Verification
# devtools::check() passed (locally).
# CI will perform the actual build and deployment.

# 5. Deployment
# - Committed changes
# - Pushed to GitHub
# - Created PR
# - Merged PR
