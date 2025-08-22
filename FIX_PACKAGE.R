# Fix script for inrep package
# Run this to ensure all changes are applied

cat("========================================\n")
cat("INREP PACKAGE FIX SCRIPT\n")
cat("========================================\n\n")

# Step 1: Remove old package completely
cat("Step 1: Removing old package version...\n")
tryCatch({
  remove.packages("inrep")
  cat("  - Old package removed\n")
}, error = function(e) {
  cat("  - Package not installed (OK)\n")
})

# Also remove from all library paths
lib_paths <- .libPaths()
for (lib_path in lib_paths) {
  pkg_path <- file.path(lib_path, "inrep")
  if (dir.exists(pkg_path)) {
    unlink(pkg_path, recursive = TRUE)
    cat("  - Removed from:", lib_path, "\n")
  }
}

# Clear namespace if loaded
if ("inrep" %in% loadedNamespaces()) {
  unloadNamespace("inrep")
  cat("  - Namespace unloaded\n")
}

# Step 2: Clear R temp files
cat("\nStep 2: Clearing temporary files...\n")
temp_dir <- file.path(tempdir(), "inrep")
if (dir.exists(temp_dir)) {
  unlink(temp_dir, recursive = TRUE)
  cat("  - Temp files cleared\n")
} else {
  cat("  - No temp files found (OK)\n")
}

# Step 3: Clear compiled files
cat("\nStep 3: Clearing compiled files...\n")
if (dir.exists("src")) {
  o_files <- list.files("src", pattern = "\\.o$", full.names = TRUE)
  so_files <- list.files("src", pattern = "\\.so$", full.names = TRUE)
  dll_files <- list.files("src", pattern = "\\.dll$", full.names = TRUE)
  
  all_compiled <- c(o_files, so_files, dll_files)
  if (length(all_compiled) > 0) {
    unlink(all_compiled)
    cat("  - Compiled files cleared\n")
  } else {
    cat("  - No compiled files found (OK)\n")
  }
}

# Step 4: Rebuild documentation
cat("\nStep 4: Rebuilding documentation...\n")
if (requireNamespace("devtools", quietly = TRUE)) {
  devtools::document()
  cat("  - Documentation rebuilt\n")
} else {
  cat("  - devtools not available, skipping\n")
}

# Step 5: Install fresh
cat("\nStep 5: Installing fresh package...\n")
if (requireNamespace("devtools", quietly = TRUE)) {
  devtools::install_local(".", force = TRUE, upgrade = "never")
  cat("  - Package installed successfully\n")
} else {
  install.packages(".", repos = NULL, type = "source")
  cat("  - Package installed from source\n")
}

# Step 6: Verify installation
cat("\nStep 6: Verifying installation...\n")
library(inrep)

# Check that select_next_item has correct signature
if (exists("select_next_item")) {
  args <- names(formals(select_next_item))
  if (identical(args, c("rv", "item_bank", "config"))) {
    cat("  ✓ select_next_item function signature correct\n")
  } else {
    cat("  ✗ WARNING: select_next_item has wrong signature:", paste(args, collapse=", "), "\n")
  }
}

# Test basic functionality
cat("\nStep 7: Testing basic functionality...\n")
tryCatch({
  data(bfi_items)
  config <- create_study_config(
    name = "Test",
    model = "GRM",
    max_items = 10
  )
  cat("  ✓ Basic configuration works\n")
  
  # Test select_next_item with new signature
  rv <- list(
    administered = integer(0),
    responses = numeric(0),
    current_ability = 0,
    current_se = 1
  )
  
  item <- select_next_item(rv, bfi_items, config)
  if (!is.null(item)) {
    cat("  ✓ Item selection works\n")
  }
  
}, error = function(e) {
  cat("  ✗ Error in basic test:", e$message, "\n")
})

cat("\n========================================\n")
cat("FIX COMPLETE!\n")
cat("========================================\n")
cat("\nYou can now run your examples:\n")
cat("  - launch_study(config, item_bank)\n")
cat("  - Hildesheim study script\n")
cat("\nIf you still see errors, restart R and run this script again.\n")