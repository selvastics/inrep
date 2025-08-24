#!/usr/bin/env Rscript

#' Clean Installation Script for increp Package
#' 
#' This script provides a clean installation experience with:
#' - Suppressed unnecessary warnings
#' - Clear progress messages
#' - Automatic dependency handling
#' - Post-installation verification

cat("\n=====================================\n")
cat("  INCREP CLEAN INSTALLATION SCRIPT  \n")
cat("=====================================\n\n")

# Function to install package cleanly
install_increp_clean <- function(
  repo = "selvastics/inrep", 
  branch = "main",
  force = TRUE,
  quiet = TRUE
) {
  
  # Check and install required packages
  cat("📦 Checking dependencies...\n")
  required_packages <- c("devtools", "remotes")
  
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      cat(sprintf("  Installing %s...\n", pkg))
      install.packages(pkg, quiet = TRUE, repos = "https://cran.r-project.org")
    }
  }
  
  # Prepare installation
  cat("\n🔧 Preparing installation...\n")
  
  # Set options for cleaner output
  old_options <- options(
    warn = -1,  # Suppress warnings temporarily
    verbose = FALSE,
    show.error.messages = TRUE
  )
  on.exit(options(old_options))  # Restore options on exit
  
  # Build the GitHub URL
  if (grepl("@", branch)) {
    # Branch specified with @ notation
    github_url <- paste0(repo, "@", branch)
  } else {
    # Standard branch
    github_url <- repo
    if (branch != "main") {
      github_url <- paste0(github_url, "@", branch)
    }
  }
  
  cat(sprintf("  Repository: %s\n", github_url))
  
  # Perform installation
  cat("\n📥 Installing increp package...\n")
  
  tryCatch({
    # Suppress package startup messages
    suppressPackageStartupMessages({
      suppressWarnings({
        # Use remotes for cleaner installation
        if (requireNamespace("remotes", quietly = TRUE)) {
          remotes::install_github(
            github_url,
            force = force,
            quiet = quiet,
            upgrade = "never",  # Don't upgrade dependencies
            build_vignettes = FALSE  # Skip vignettes for faster install
          )
        } else {
          devtools::install_github(
            github_url,
            force = force,
            quiet = quiet,
            upgrade = "never"
          )
        }
      })
    })
    
    cat("✅ Installation completed successfully!\n")
    
  }, error = function(e) {
    cat("❌ Installation failed with error:\n")
    cat(sprintf("   %s\n", e$message))
    return(FALSE)
  })
  
  # Verify installation
  cat("\n🔍 Verifying installation...\n")
  
  if (requireNamespace("inrep", quietly = TRUE)) {
    # Load the package quietly
    suppressPackageStartupMessages({
      library(inrep, quietly = TRUE)
    })
    
    # Check key functions
    essential_functions <- c(
      "launch_study",
      "create_study_config",
      "estimate_ability",
      "select_next_item"
    )
    
    all_present <- TRUE
    for (func in essential_functions) {
      if (exists(func, where = "package:inrep")) {
        cat(sprintf("  ✓ %s found\n", func))
      } else {
        cat(sprintf("  ✗ %s missing\n", func))
        all_present <- FALSE
      }
    }
    
    if (all_present) {
      cat("\n✅ All essential functions verified!\n")
      
      # Get package version
      pkg_version <- packageVersion("inrep")
      cat(sprintf("\n📌 increp version %s installed\n", pkg_version))
      
      # Show quick start
      cat("\n🚀 Quick Start:\n")
      cat("   library(inrep)\n")
      cat("   ?quick_start  # For interactive guide\n")
      cat("   show_examples()  # For example code\n")
      
      return(TRUE)
    } else {
      cat("\n⚠️ Some functions are missing. Please reinstall.\n")
      return(FALSE)
    }
  } else {
    cat("❌ Package not found after installation.\n")
    return(FALSE)
  }
}

# Function to clean up before installation
clean_before_install <- function() {
  cat("\n🧹 Cleaning up before installation...\n")
  
  # Unload package if loaded
  if ("inrep" %in% loadedNamespaces()) {
    cat("  Unloading existing inrep package...\n")
    tryCatch({
      detach("package:inrep", unload = TRUE, force = TRUE)
    }, error = function(e) {
      # Ignore if not attached
    })
  }
  
  # Clear any cached data
  if (exists(".inrep_cache", envir = .GlobalEnv)) {
    cat("  Clearing cache...\n")
    rm(".inrep_cache", envir = .GlobalEnv)
  }
  
  cat("  Clean-up complete.\n")
}

# Main installation function
install_increp <- function(
  branch = NULL,
  clean = TRUE,
  verify = TRUE
) {
  
  # Header
  cat("\n╔════════════════════════════════════╗\n")
  cat("║     INCREP PACKAGE INSTALLER       ║\n")
  cat("╚════════════════════════════════════╝\n")
  
  # Determine branch
  if (is.null(branch)) {
    cat("\nSelect installation source:\n")
    cat("1. Main branch (stable)\n")
    cat("2. Development branch\n")
    cat("3. Specific branch/PR\n")
    
    if (interactive()) {
      choice <- readline("Enter choice (1-3): ")
      
      branch <- switch(choice,
        "1" = "main",
        "2" = "dev",
        "3" = readline("Enter branch name or PR (e.g., 'cursor/fix-...'): "),
        "main"  # Default
      )
    } else {
      branch <- "main"
    }
  }
  
  # Clean if requested
  if (clean) {
    clean_before_install()
  }
  
  # Install
  success <- install_increp_clean(
    repo = "selvastics/inrep",
    branch = branch,
    force = TRUE,
    quiet = TRUE
  )
  
  if (success && verify) {
    cat("\n🎉 Installation successful!\n")
    cat("\n📚 Documentation:\n")
    cat("   GitHub: https://github.com/selvastics/inrep\n")
    cat("   Vignettes: vignette(package = 'inrep')\n")
  }
  
  return(invisible(success))
}

# Run if called directly
if (!interactive()) {
  # Command line arguments
  args <- commandArgs(trailingOnly = TRUE)
  
  if (length(args) > 0) {
    branch <- args[1]
  } else {
    branch <- "main"
  }
  
  install_increp(branch = branch, clean = TRUE, verify = TRUE)
} else {
  # Interactive mode
  cat("\n📋 Usage:\n")
  cat("   install_increp()  # Interactive installation\n")
  cat("   install_increp('main')  # Install main branch\n")
  cat("   install_increp('cursor/fix-hildesheim-study-button-and-translate-to-english-772c')  # Specific branch\n")
  cat("\nOr run the installer with: install_increp()\n")
}