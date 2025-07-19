# Regenerate package documentation
library(roxygen2)
library(devtools)

cat("Regenerating documentation...\n")
roxygenise(".")
cat("Documentation regenerated.\n")

cat("Checking package...\n")
check(".")
