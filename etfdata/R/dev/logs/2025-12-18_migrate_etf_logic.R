# Session Log - 2025-12-18
# Topic: Migrate ETF fetching logic
# Author: Gemini Agent

library(gert)
library(usethis)

# Set working directory context
setwd("llm/finance/data/etfs")

# 1. Create and Checkout Development Branch
# We use gert directly here to ensure uncommitted changes on 'main' are carried over safely
# without triggering potential interactive prompts from usethis::pr_init() regarding dirty state.
branch_name <- "feature/migrate-etf-logic"
if (!gert::git_branch_exists(branch_name)) {
  gert::git_branch_create(branch_name)
}
gert::git_branch_checkout(branch_name)

# 2. Stage Changes
# Adding all files including this log file and the migrated ETF data files
gert::git_add(".")

# 3. Commit Changes
gert::git_commit("Migrate ETF fetching logic and documentation from claude_rix")
