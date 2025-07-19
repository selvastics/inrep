#!/usr/bin/env Rscript

# Regenerate package documentation and NAMESPACE
if (!requireNamespace("roxygen2", quietly = TRUE)) {
  install.packages("roxygen2")
}

library(roxygen2)

# Set working directory to package root
setwd(".")

# Generate documentation
roxygenise()

# Check if the main functions are exported
if (file.exists("NAMESPACE")) {
  namespace_content <- readLines("NAMESPACE")
  cat("Generated NAMESPACE content:\n")
  cat(paste(namespace_content, collapse = "\n"))
  cat("\n\n")
  
  if (any(grepl("create_study_config", namespace_content))) {
    cat("✓ create_study_config is exported\n")
  } else {
    cat("✗ create_study_config is NOT exported\n")
  }
  
  if (any(grepl("launch_study", namespace_content))) {
    cat("✓ launch_study is exported\n")
  } else {
    cat("✗ launch_study is NOT exported\n")
  }
} else {
  cat("ERROR: NAMESPACE file was not generated\n")
}
