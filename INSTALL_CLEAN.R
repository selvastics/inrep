# Clean Installation Script for inrep Package
# This ensures the package installs correctly

cat("========================================\n")
cat("CLEAN INSTALLATION SCRIPT\n")
cat("========================================\n\n")

# Step 1: Complete removal
cat("Step 1: Complete removal of old package...\n")

# Remove package
suppressWarnings({
  if ("inrep" %in% rownames(installed.packages())) {
    remove.packages("inrep")
    cat("  - Package removed\n")
  }
})

# Unload namespace
if ("inrep" %in% loadedNamespaces()) {
  unloadNamespace("inrep")
  cat("  - Namespace unloaded\n")
}

# Remove from all library paths
for (lib in .libPaths()) {
  pkg_dir <- file.path(lib, "inrep")
  if (dir.exists(pkg_dir)) {
    unlink(pkg_dir, recursive = TRUE)
    cat("  - Removed from:", lib, "\n")
  }
}

# Step 2: Clear cache
cat("\nStep 2: Clearing cache...\n")

# Clear R session temp files
temp_files <- list.files(tempdir(), pattern = "inrep", full.names = TRUE, recursive = TRUE)
if (length(temp_files) > 0) {
  unlink(temp_files, recursive = TRUE)
  cat("  - Temp files cleared\n")
}

# Step 3: Restart R session (if in RStudio)
cat("\nStep 3: Preparing for installation...\n")
if (Sys.getenv("RSTUDIO") == "1") {
  cat("  - Please restart R session (Session -> Restart R)\n")
  cat("  - Then run: devtools::install_local('.', force = TRUE)\n")
} else {
  cat("  - Installing package...\n")
  
  # Step 4: Install fresh
  if (requireNamespace("devtools", quietly = TRUE)) {
    devtools::install_local(".", force = TRUE, upgrade = "never", quiet = FALSE)
    cat("\n  - Package installed successfully!\n")
  } else {
    install.packages(".", repos = NULL, type = "source")
    cat("\n  - Package installed from source!\n")
  }
  
  # Step 5: Test
  cat("\nStep 5: Testing installation...\n")
  library(inrep)
  
  # Check function signature
  if (exists("select_next_item")) {
    args <- names(formals(select_next_item))
    if (identical(args, c("rv", "item_bank", "config"))) {
      cat("  ✓ Functions correctly updated\n")
    } else {
      cat("  ✗ Function signature issue detected\n")
    }
  }
  
  # Test basic config
  tryCatch({
    config <- create_study_config(
      name = "Test",
      model = "GRM",
      max_items = 10
    )
    cat("  ✓ Configuration works\n")
  }, error = function(e) {
    cat("  ✗ Configuration error:", e$message, "\n")
  })
}

cat("\n========================================\n")
cat("Installation complete!\n")
cat("========================================\n")
cat("\nNext steps:\n")
cat("1. If in RStudio, restart R if not already done\n")
cat("2. Run: library(inrep)\n")
cat("3. Test with: launch_study(config, item_bank)\n")