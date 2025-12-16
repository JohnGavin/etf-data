# Log for Feature: Shinylive Dashboard Vignette
# Date: 2025-12-15
# Author: Gemini Agent

# 1. Created Issue #77: "Feat: Shinylive Dashboard Vignette"
# 2. Created branch 'feat-shinylive-vignette'

# 3. Changes
# - Created `vignettes/shinylive_dashboard.qmd`:
#   - Implemented a basic Shinylive app using `etfdata` functions.
#   - Configured YAML for `shinylive-r` format, including necessary packages and repositories.
# - Updated `DESCRIPTION` to add `shinylive`, `DT`, `htmltools` as `Suggests`.
# - Updated `.github/workflows/deploy-docs.yml` to install `shinylive` Quarto extension.

# 4. Verification
# devtools::document()
# devtools::check()
# Result: Passed locally.

# 5. Deployment
# - Committed changes.
# - Pushed to GitHub.
# - Created PR #78.
# - Merged PR.
