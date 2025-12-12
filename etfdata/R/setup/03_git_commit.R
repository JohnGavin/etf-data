# Session Log: Git Commit
# Date: 2025-12-12
# Issue: #5

library(gert)
library(usethis)

# Stage all files in the new package directory
pkg_path <- "finance/data/etfs/etfdata"

# Simple add of the directory
git_add(pkg_path)

# Commit
git_commit("Feat: Scaffold etfdata R package (Issue #5)")

# Push
# Note: we are on branch 'scaffold-etfdata'
pr_push()

message("Committed and pushed.")