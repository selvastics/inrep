#' Installation Helper for inrep Package
#' 
#' This script helps with clean installation/reinstallation of the inrep package
#' Source this file to get helper functions for package management
#' 
#' Usage:
#'   source("https://raw.githubusercontent.com/selvastics/inrep/main/inst/install_helper.R")
#'   clean_install_inrep()

#' Clean Install inrep
#' 
#' Performs a clean installation of the inrep package
#' 
#' @param source Installation source ("github", "local", "cran")
#' @param branch GitHub branch (if source = "github")
#' @param path Local path (if source = "local")
#' @param verbose Show detailed messages
clean_install_inrep <- function(source = "github", branch = "main", path = NULL, verbose = TRUE) {
  
  if (verbose) message("Starting clean installation of inrep package...")
  
  # Step 1: Detach package if loaded
  if ("package:inrep" %in% search()) {
    if (verbose) message("Detaching currently loaded inrep package...")
    try(detach("package:inrep", unload = TRUE, character.only = TRUE), silent = TRUE)
  }
  
  # Step 2: Unload namespace
  if ("inrep" %in% loadedNamespaces()) {
    if (verbose) message("Unloading inrep namespace...")
    try(unloadNamespace("inrep"), silent = TRUE)
  }
  
  # Step 3: Clean up any remaining objects
  cleanup_inrep_remnants(verbose)
  
  # Step 4: Remove installed package
  if ("inrep" %in% rownames(installed.packages())) {
    if (verbose) message("Removing existing inrep installation...")
    try(remove.packages("inrep"), silent = TRUE)
  }
  
  # Step 5: Clear package cache
  if (verbose) message("Clearing package cache...")
  clear_package_cache()
  
  # Step 6: Install fresh
  if (verbose) message(paste("Installing inrep from", source, "..."))
  
  switch(source,
    github = {
      if (!requireNamespace("remotes", quietly = TRUE)) {
        if (verbose) message("Installing remotes package...")
        install.packages("remotes")
      }
      remotes::install_github(
        paste0("selvastics/inrep@", branch),
        force = TRUE,
        upgrade = "never"
      )
    },
    local = {
      if (is.null(path)) {
        stop("Please provide a path for local installation")
      }
      install.packages(path, repos = NULL, type = "source")
    },
    cran = {
      install.packages("inrep")
    },
    stop("Unknown source. Use 'github', 'local', or 'cran'")
  )
  
  if (verbose) {
    message("\n===========================================")
    message("inrep package successfully installed!")
    message("===========================================")
    message("You can now load it with: library(inrep)")
  }
  
  invisible(TRUE)
}

#' Cleanup inrep Remnants
#' 
#' Removes any remaining objects from the global environment
#' 
#' @param verbose Show messages
cleanup_inrep_remnants <- function(verbose = TRUE) {
  
  # List of possible environment names used by inrep
  env_names <- c(
    ".session_state",
    ".security_state",
    ".performance_state", 
    ".recovery_state",
    ".survey_state",
    ".ux_state",
    ".inrep_cache",
    ".inrep_env"
  )
  
  # Remove from global environment
  for (env_name in env_names) {
    if (exists(env_name, envir = .GlobalEnv)) {
      if (verbose) message(paste("  Removing", env_name))
      rm(list = env_name, envir = .GlobalEnv)
    }
  }
  
  # Close any inrep connections
  cons <- showConnections()
  if (nrow(cons) > 0) {
    for (i in seq_len(nrow(cons))) {
      if (grepl("inrep", cons[i, "description"], ignore.case = TRUE)) {
        if (verbose) message(paste("  Closing connection:", cons[i, "description"]))
        try(close(getConnection(as.integer(rownames(cons)[i]))), silent = TRUE)
      }
    }
  }
  
  # Clean temporary files
  temp_dir <- tempdir()
  temp_patterns <- c("inrep_*", "TAM_*")
  
  for (pattern in temp_patterns) {
    files <- list.files(temp_dir, pattern = pattern, full.names = TRUE)
    if (length(files) > 0) {
      if (verbose) message(paste("  Removing", length(files), "temporary files"))
      try(unlink(files, recursive = TRUE), silent = TRUE)
    }
  }
  
  invisible(NULL)
}

#' Clear Package Cache
#' 
#' Clears R's package cache to ensure fresh installation
clear_package_cache <- function() {
  # Clear pkgcache if available
  if (requireNamespace("pkgcache", quietly = TRUE)) {
    try(pkgcache::pkg_cache_delete_files(), silent = TRUE)
  }
  
  # Clear renv cache if in renv project
  if (requireNamespace("renv", quietly = TRUE)) {
    if (renv::project() != "") {
      try(renv::clean(), silent = TRUE)
    }
  }
  
  # Force garbage collection
  gc(verbose = FALSE)
  
  invisible(NULL)
}

#' Quick Reinstall
#' 
#' Quick function to reinstall from GitHub
#' 
#' @param branch Branch to install from
quick_reinstall <- function(branch = "main") {
  clean_install_inrep("github", branch = branch, verbose = TRUE)
}

#' Check inrep Status
#' 
#' Checks the current status of inrep installation
check_inrep_status <- function() {
  cat("\n=== inrep Package Status ===\n")
  
  # Check if installed
  if ("inrep" %in% rownames(installed.packages())) {
    pkg_info <- packageDescription("inrep")
    cat("Installed: YES\n")
    cat("Version:", pkg_info$Version, "\n")
    cat("Built:", pkg_info$Built, "\n")
  } else {
    cat("Installed: NO\n")
  }
  
  # Check if loaded
  if ("package:inrep" %in% search()) {
    cat("Attached: YES\n")
  } else {
    cat("Attached: NO\n")
  }
  
  # Check if namespace loaded
  if ("inrep" %in% loadedNamespaces()) {
    cat("Namespace Loaded: YES\n")
  } else {
    cat("Namespace Loaded: NO\n")
  }
  
  # Check for remnants
  env_names <- c(".session_state", ".security_state", ".performance_state", 
                 ".recovery_state", ".survey_state", ".ux_state")
  remnants <- sum(sapply(env_names, exists, envir = .GlobalEnv))
  
  if (remnants > 0) {
    cat("Environment Remnants:", remnants, "found\n")
    cat("  Run cleanup_inrep_remnants() to remove\n")
  } else {
    cat("Environment Remnants: None\n")
  }
  
  cat("\n")
  invisible(NULL)
}

# Print help message
cat("\n")
cat("==============================================\n")
cat("inrep Installation Helper Loaded\n")
cat("==============================================\n")
cat("\n")
cat("Available functions:\n")
cat("  clean_install_inrep()  - Perform clean installation\n")
cat("  quick_reinstall()      - Quick reinstall from GitHub\n")
cat("  check_inrep_status()   - Check package status\n")
cat("  cleanup_inrep_remnants() - Clean up remnants\n")
cat("\n")
cat("For clean installation, run:\n")
cat("  clean_install_inrep()\n")
cat("\n")