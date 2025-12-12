# Session Log: Fix DESCRIPTION
# Date: 2025-12-12
# Issue: #5

library(desc)

pkg_path <- "finance/data/etfs/etfdata"
desc_path <- file.path(pkg_path, "DESCRIPTION")

d <- description$new(desc_path)

# Remove template fields if they exist and are invalid
if (d$has_fields("Maintainer")) d$del("Maintainer") # Authors@R handles this
if (d$has_fields("URL")) d$del("URL")
if (d$has_fields("BugReports")) d$del("BugReports")

# Ensure Authors@R is correct
d$set("Authors@R", 'person("John", "Gavin", email = "john@example.com", role = c("aut", "cre"))')

d$write(desc_path)

message("Fixed DESCRIPTION.")
