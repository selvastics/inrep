#' Fix Corrupt Lazy-Load Database
#' 
#' This script helps fix the corrupt lazy-load database error
#' 
#' Run this script if you see errors like:
#' "lazy-load database 'inrep/R/inrep.rdb' is corrupt"

fix_corrupt_inrep <- function() {
  message("Fixing corrupt inrep package database...")
  
  # Step 1: Completely remove the package
  if ("inrep" %in% rownames(installed.packages())) {
    message("Removing corrupt inrep installation...")
    
    # Detach if loaded
    if ("package:inrep" %in% search()) {
      detach("package:inrep", unload = TRUE, character.only = TRUE)
    }
    
    # Unload namespace
    if ("inrep" %in% loadedNamespaces()) {
      unloadNamespace("inrep")
    }
    
    # Remove the package
    remove.packages("inrep")
  }
  
  # Step 2: Clear R's temp directory
  message("Clearing temporary files...")
  temp_files <- list.files(tempdir(), pattern = "^Rtmp", full.names = TRUE)
  if (length(temp_files) > 0) {
    unlink(temp_files, recursive = TRUE)
  }
  
  # Step 3: Clear package cache
  message("Clearing package cache...")
  
  # Clear compiled package cache
  pkg_dir <- file.path(.libPaths()[1], "inrep")
  if (dir.exists(pkg_dir)) {
    unlink(pkg_dir, recursive = TRUE)
  }
  
  # Step 4: Garbage collection
  gc(verbose = FALSE)
  
  # Step 5: Restart R session if in RStudio
  if (rstudioapi::isAvailable()) {
    message("\nPackage cleaned. R session will restart...")
    message("After restart, reinstall with:")
    message('  remotes::install_github("selvastics/inrep@enhancement/comprehensive-robustness-v1.0")')
    
    Sys.sleep(2)
    rstudioapi::restartSession()
  } else {
    message("\nPackage cleaned. Please restart R and reinstall with:")
    message('  remotes::install_github("selvastics/inrep@enhancement/comprehensive-robustness-v1.0")')
  }
}

# Alternative manual fix
manual_fix_instructions <- function() {
  cat("
================================================================================
MANUAL FIX FOR CORRUPT LAZY-LOAD DATABASE
================================================================================

If the automatic fix doesn't work, follow these steps manually:

1. Close all R sessions
2. Navigate to your R library folder:
   - Windows: C:/Users/[YourName]/AppData/Local/R/win-library/4.5/
   - Mac: ~/Library/R/4.5/library/
   - Linux: ~/R/x86_64-pc-linux-gnu-library/4.5/

3. Delete the 'inrep' folder completely

4. Clear Windows temp folder (if on Windows):
   - Press Win+R, type %temp%, press Enter
   - Delete all folders starting with 'Rtmp'

5. Start a fresh R session

6. Reinstall the package:
   remotes::install_github('selvastics/inrep@enhancement/comprehensive-robustness-v1.0')

================================================================================
")
}

# Run the fix
message("Choose an option:")
message("1. Automatic fix (will restart R)")
message("2. Show manual instructions")
message("3. Cancel")

choice <- readline("Enter choice (1/2/3): ")

if (choice == "1") {
  fix_corrupt_inrep()
} else if (choice == "2") {
  manual_fix_instructions()
} else {
  message("Cancelled.")
}