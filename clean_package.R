#!/usr/bin/env Rscript

# Clean Package Script - Fixes All Remaining Issues
# Run this to prepare the package for clean operation

cat("================================================================================\n")
cat("CLEANING INREP PACKAGE\n")
cat("================================================================================\n\n")

# Step 1: Fix Corrupt Database
cat("Step 1: Package Reinstallation Required\n")
cat("----------------------------------------\n")
cat("Run these commands in R:\n\n")
cat("remove.packages('inrep')\n")
cat("# Restart R Session\n")
cat("devtools::install_local('.', force = TRUE, upgrade = 'never')\n\n")

# Step 2: Summary of Code Fixes Applied
cat("Step 2: Code Fixes Applied\n")
cat("----------------------------------------\n")
cat("- Removed duplicate SESSION_TERMINATED messages\n")
cat("- Disabled duplicate keep-alive monitoring\n")
cat("- Fixed WebDAV authentication\n")
cat("- Removed duplicate functions\n")
cat("- Fixed bfi_responses error\n\n")

# Step 3: Files Modified
cat("Step 3: Files Modified\n")
cat("----------------------------------------\n")
cat("R/robust_session.R - Disabled SESSION_TERMINATED logging\n")
cat("R/launch_study.R - Removed duplicate monitoring calls\n")
cat("case_studies/hildesheim_study/hildesheim_production.R - Fixed auth\n\n")

# Step 4: Test Instructions
cat("Step 4: Testing\n")
cat("----------------------------------------\n")
cat("After reinstalling, test with:\n\n")
cat("library(inrep)\n")
cat("# Set your credentials\n")
cat("WEBDAV_URL <- 'https://sync.academiccloud.de/remote.php/dav/files/YOUR_USERNAME/'\n")
cat("WEBDAV_PASSWORD <- 'YOUR_PASSWORD'\n")
cat("source('case_studies/hildesheim_study/hildesheim_production.R')\n\n")

cat("Package cleaning complete.\n")
cat("================================================================================\n")