#' User Experience Improvements Module
#' 
#' Provides enhanced user experience features including better error messages,
#' progress indicators, helpful defaults, and intuitive workflows
#' 
#' @name user_experience_improvements
#' @docType data
NULL

#' Initialize User Experience Enhancements
#' 
#' Sets up improved user experience features
#' 
#' @param verbose Show helpful messages during operations
#' @param beginner_mode Enable extra guidance for new users
#' @param auto_fix Automatically fix common issues
#' @param show_tips Display helpful tips during setup
#' @return Configuration for UX enhancements
#' @export
initialize_ux_enhancements <- function(
  verbose = TRUE,
  beginner_mode = FALSE,
  auto_fix = TRUE,
  show_tips = TRUE
) {
  options(
    inrep.verbose = verbose,
    inrep.beginner_mode = beginner_mode,
    inrep.auto_fix = auto_fix,
    inrep.show_tips = show_tips
  )
  
  if (beginner_mode) {
    message("Welcome to inrep. Beginner mode enabled.")
    message("You'll receive extra guidance throughout the process.")
    message("To disable, set beginner_mode = FALSE")
  }
  
  invisible(list(
    verbose = verbose,
    beginner_mode = beginner_mode,
    auto_fix = auto_fix,
    show_tips = show_tips
  ))
}

#' User-Friendly Error Messages
#' 
#' Converts technical errors to user-friendly messages
#' 
#' @param error Error object or message
#' @param context Context where error occurred
#' @return User-friendly error message with suggestions
#' @export
user_friendly_error <- function(error, context = NULL) {
  error_msg <- if (inherits(error, "error")) error$message else as.character(error)
  
  # Common error patterns and friendly messages
  error_mappings <- list(
    "object .* not found" = list(
      message = "Required data or configuration is missing.",
      suggestion = "Please check that all required parameters are provided.",
      action = "Run check_setup() to verify your configuration."
    ),
    "subscript out of bounds" = list(
      message = "The item bank or data structure has an unexpected format.",
      suggestion = "Ensure your item bank has the required columns.",
      action = "Run validate_item_bank(your_item_bank) to check the format."
    ),
    "cannot open the connection" = list(
      message = "Unable to access a required file or network resource.",
      suggestion = "Check your internet connection and file permissions.",
      action = "Verify that all file paths are correct."
    ),
    "package .* not available" = list(
      message = "A required package is not installed.",
      suggestion = "Some features require additional packages.",
      action = "Run install_required_packages() to install missing packages."
    ),
    "invalid .* argument" = list(
      message = "One or more parameters have invalid values.",
      suggestion = "Check that all parameters are within valid ranges.",
      action = "Run validate_config(your_config) to check parameters."
    ),
    "memory" = list(
      message = "The operation requires more memory than available.",
      suggestion = "Try reducing the item bank size or number of participants.",
      action = "Consider using batch_process_large_study() for large datasets."
    )
  )
  
  # Find matching error pattern
  friendly_msg <- NULL
  for (pattern in names(error_mappings)) {
    if (grepl(pattern, error_msg, ignore.case = TRUE)) {
      friendly_msg <- error_mappings[[pattern]]
      break
    }
  }
  
  # Default message if no pattern matches
  if (is.null(friendly_msg)) {
    friendly_msg <- list(
      message = "An unexpected error occurred.",
      suggestion = "This might be a configuration issue.",
      action = "Run diagnose_issue() for detailed troubleshooting."
    )
  }
  
  # Format the message
  formatted_message <- paste0(
    "\n", cli_rule("Error"), "\n",
    "What happened: ", friendly_msg$message, "\n",
    "Why: ", friendly_msg$suggestion, "\n",
    "What to do: ", friendly_msg$action, "\n"
  )
  
  if (!is.null(context)) {
    formatted_message <- paste0(formatted_message, "Context: ", context, "\n")
  }
  
  if (getOption("inrep.verbose", TRUE)) {
    formatted_message <- paste0(
      formatted_message,
      "\nTechnical details: ", error_msg, "\n",
      cli_rule()
    )
  }
  
  return(formatted_message)
}

#' Progress Indicator with ETA
#' 
#' Shows progress with estimated time remaining
#' 
#' @param current Current item/step
#' @param total Total items/steps
#' @param start_time Start time of operation
#' @param message Custom message to display
#' @return Progress bar with ETA
#' @export
show_progress_with_eta <- function(current, total, start_time, message = NULL) {
  if (current == 0) return(invisible())
  
  # Calculate progress
  progress <- current / total
  elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  
  # Estimate remaining time
  if (progress > 0) {
    total_estimated <- elapsed / progress
    remaining <- total_estimated - elapsed
    
    # Format time
    if (remaining < 60) {
      eta_text <- sprintf("%.0f seconds", remaining)
    } else if (remaining < 3600) {
      eta_text <- sprintf("%.1f minutes", remaining / 60)
    } else {
      eta_text <- sprintf("%.1f hours", remaining / 3600)
    }
  } else {
    eta_text <- "calculating..."
  }
  
  # Create progress bar
  bar_width <- 30
  filled <- round(progress * bar_width)
  bar <- paste0(
    "[",
    paste(rep("=", filled), collapse = ""),
    ifelse(filled < bar_width, ">", ""),
    paste(rep(" ", bar_width - filled - 1), collapse = ""),
    "]"
  )
  
  # Format message
  if (is.null(message)) {
    message <- "Processing"
  }
  
  status_text <- sprintf(
    "\r%s: %s %3.0f%% | Item %d/%d | ETA: %s",
    message, bar, progress * 100, current, total, eta_text
  )
  
  cat(status_text)
  if (current == total) cat("\n")
  
  invisible()
}

#' Smart Configuration Wizard
#' 
#' Interactive wizard to help users create configurations
#' 
#' @param purpose Purpose of the assessment (education, clinical, research, corporate)
#' @param experience User's experience level (beginner, intermediate, expert)
#' @return Generated configuration with explanations
#' @export
configuration_wizard <- function(purpose = NULL, experience = "beginner") {
  
  if (is.null(purpose)) {
    message("What is the purpose of your assessment?")
    message("1. Educational (student testing)")
    message("2. Clinical (psychological assessment)")
    message("3. Research (data collection)")
    message("4. Corporate (employee assessment)")
    purpose <- readline("Enter choice (1-4): ")
    purpose <- c("education", "clinical", "research", "corporate")[as.numeric(purpose)]
  }
  
  # Purpose-specific defaults
  configs <- list(
    education = list(
      name = "Educational Assessment",
      model = "2PL",
      max_items = 30,
      min_items = 15,
      min_SEM = 0.3,
      demographics = c("Grade", "School", "Teacher"),
      theme = "Academic",
      feedback_enabled = TRUE,
      explanation = "Configured for educational testing with moderate length and immediate feedback"
    ),
    clinical = list(
      name = "Clinical Assessment",
      model = "GRM",
      max_items = 50,
      min_items = 20,
      min_SEM = 0.25,
      demographics = c("Age", "Gender", "Diagnosis"),
      theme = "Professional",
      save_format = "encrypted_rds",
      clinical_mode = TRUE,
      explanation = "Configured for clinical use with enhanced security and professional appearance"
    ),
    research = list(
      name = "Research Study",
      model = "2PL",
      max_items = 100,
      min_items = 30,
      min_SEM = 0.2,
      demographics = c("Age", "Gender", "Education", "Country"),
      theme = "Light",
      cache_enabled = TRUE,
      parallel_computation = TRUE,
      explanation = "Configured for research with extensive data collection and performance optimization"
    ),
    corporate = list(
      name = "Employee Assessment",
      model = "2PL",
      max_items = 40,
      min_items = 25,
      min_SEM = 0.3,
      demographics = c("Department", "Role", "Experience"),
      theme = "Professional",
      proctoring_enabled = TRUE,
      time_limit = 3600,
      explanation = "Configured for corporate use with proctoring and time limits"
    )
  )
  
  config <- configs[[purpose]]
  
  # Add experience-based adjustments
  if (experience == "beginner") {
    config$show_introduction <- TRUE
    config$show_briefing <- TRUE
    config$practice_items <- TRUE
    config$verbose_feedback <- TRUE
    message("\nBeginner-friendly features added:")
    message("- Introduction and briefing pages")
    message("- Practice items before main assessment")
    message("- Detailed feedback throughout")
  }
  
  # Show configuration summary
  message("\n", cli_rule("Configuration Created"))
  message(config$explanation)
  message("\nKey settings:")
  for (key in c("model", "max_items", "min_items", "min_SEM")) {
    message(sprintf("  %s: %s", key, config[[key]]))
  }
  
  if (getOption("inrep.show_tips", TRUE)) {
    message("\n", cli_tip(), " Tip: You can modify any setting using config$setting <- value")
    message(cli_tip(), " Tip: Run validate_config(config) to check your configuration")
  }
  
  return(config)
}

#' Check Setup Completeness
#' 
#' Verifies that everything is properly configured
#' 
#' @param config Configuration object
#' @param item_bank Item bank data frame
#' @param verbose Show detailed output
#' @return List of check results with recommendations
#' @export
check_setup <- function(config = NULL, item_bank = NULL, verbose = TRUE) {
  checks <- list()
  issues <- list()
  warnings <- list()
  
  # Check configuration
  if (is.null(config)) {
    issues$config <- "No configuration provided"
  } else {
    if (is.null(config$name)) warnings$name <- "Study name is missing"
    if (is.null(config$model)) issues$model <- "IRT model not specified"
    if (is.null(config$max_items)) warnings$max_items <- "Maximum items not set"
    checks$config <- "Configuration present"
  }
  
  # Check item bank
  if (is.null(item_bank)) {
    issues$item_bank <- "No item bank provided"
  } else {
    n_items <- nrow(item_bank)
    if (n_items < 10) {
      warnings$item_count <- sprintf("Only %d items in bank (minimum 10 recommended)", n_items)
    }
    
    required_cols <- c("item_id", "content", "difficulty")
    missing_cols <- setdiff(required_cols, names(item_bank))
    if (length(missing_cols) > 0) {
      issues$columns <- paste("Missing required columns:", paste(missing_cols, collapse = ", "))
    }
    
    checks$item_bank <- sprintf("Item bank with %d items", n_items)
  }
  
  # Check dependencies
  required_packages <- c("shiny", "TAM")
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      issues[[paste0("package_", pkg)]] <- sprintf("Required package '%s' not installed", pkg)
    } else {
      checks[[paste0("package_", pkg)]] <- sprintf("Package '%s' available", pkg)
    }
  }
  
  # Check system resources (platform-safe)
  mem_available <- tryCatch({
    as.numeric(system("awk '/MemAvailable/ {print $2}' /proc/meminfo", 
                     intern = TRUE, ignore.stderr = TRUE)) / 1024
  }, error = function(e) {
    NULL  # Unable to detect on this platform
  })
  if (length(mem_available) > 0 && mem_available < 500) {
    warnings$memory <- sprintf("Low memory available: %.0f MB", mem_available)
  }
  
  # Display results
  if (verbose) {
    message(cli_rule("Setup Check Results"))
    
    if (length(checks) > 0) {
      message("\nPassed checks:")
      for (check in checks) {
        message("  ", cli_check(), " ", check)
      }
    }
    
    if (length(warnings) > 0) {
      message("\nWarnings:")
      for (warning in warnings) {
        message("  ", cli_warning(), " ", warning)
      }
    }
    
    if (length(issues) > 0) {
      message("\nIssues to fix:")
      for (issue in issues) {
        message("  ", cli_cross(), " ", issue)
      }
      message("\nRun fix_setup_issues() to automatically fix these issues")
    } else {
      message("\n", cli_check(), " All checks passed! Ready to launch study.")
    }
  }
  
  return(invisible(list(
    passed = length(issues) == 0,
    checks = checks,
    warnings = warnings,
    issues = issues
  )))
}

#' Fix Common Setup Issues
#' 
#' Automatically fixes common configuration issues
#' 
#' @param config Configuration object
#' @param item_bank Item bank data frame
#' @return Fixed configuration and item bank
#' @export
fix_setup_issues <- function(config = NULL, item_bank = NULL) {
  fixed <- list()
  
  # Fix configuration
  if (is.null(config)) {
    message("No configuration found. Creating default configuration...")
    config <- configuration_wizard()
    fixed$config_created <- TRUE
  }
  
  # Fix missing required fields
  defaults <- list(
    name = "Unnamed Study",
    model = "2PL",
    max_items = 30,
    min_items = 10,
    min_SEM = 0.3,
    language = "en",
    theme = "Light"
  )
  
  for (field in names(defaults)) {
    if (is.null(config[[field]])) {
      config[[field]] <- defaults[[field]]
      fixed[[field]] <- sprintf("Set %s to default: %s", field, defaults[[field]])
    }
  }
  
  # Fix item bank
  if (!is.null(item_bank)) {
    # Add missing columns
    if (!"item_id" %in% names(item_bank)) {
      item_bank$item_id <- paste0("item_", seq_len(nrow(item_bank)))
      fixed$item_id <- "Added item_id column"
    }
    
    if (!"content" %in% names(item_bank)) {
      item_bank$content <- paste("Question", seq_len(nrow(item_bank)))
      fixed$content <- "Added placeholder content"
    }
    
    if (!"difficulty" %in% names(item_bank)) {
      item_bank$difficulty <- rnorm(nrow(item_bank))
      fixed$difficulty <- "Added random difficulty values"
    }
    
    if (config$model == "2PL" && !"discrimination" %in% names(item_bank)) {
      item_bank$discrimination <- runif(nrow(item_bank), 0.5, 2.5)
      fixed$discrimination <- "Added discrimination parameters for 2PL model"
    }
  }
  
  # Display fixes
  if (length(fixed) > 0) {
    message(cli_rule("Issues Fixed"))
    for (fix in fixed) {
      message("  ", cli_check(), " ", fix)
    }
    message("\nConfiguration and item bank have been updated.")
  } else {
    message("No issues found to fix.")
  }
  
  return(list(config = config, item_bank = item_bank))
}

#' Install Required Packages
#' 
#' Installs all packages needed for full functionality
#' 
#' @param include_optional Include optional packages for enhanced features
#' @return Invisible NULL
#' @export
install_required_packages <- function(include_optional = TRUE) {
  required <- c("shiny", "TAM", "ggplot2", "jsonlite")
  optional <- c("DT", "shinyWidgets", "shinycssloaders", "plotly", 
                "knitr", "rmarkdown", "mirt")
  
  to_install <- required
  if (include_optional) {
    to_install <- c(to_install, optional)
  }
  
  # Check which packages need installation
  missing <- c()
  for (pkg in to_install) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing <- c(missing, pkg)
    }
  }
  
  if (length(missing) == 0) {
    message("All required packages are already installed.")
    return(invisible())
  }
  
  message("The following packages will be installed:")
  message(paste("  -", missing, collapse = "\n"))
  
  response <- readline("Proceed with installation? (y/n): ")
  
  if (tolower(response) == "y") {
    for (pkg in missing) {
      message(sprintf("Installing %s...", pkg))
      install.packages(pkg, quiet = TRUE)
    }
    message("\nInstallation complete!")
  } else {
    message("Installation cancelled.")
  }
  
  invisible()
}

#' Diagnose Issues
#' 
#' Comprehensive diagnostic tool for troubleshooting
#' 
#' @param error_log Path to error log file
#' @param session_info Include session information
#' @return Diagnostic report
#' @export
diagnose_issue <- function(error_log = NULL, session_info = TRUE) {
  report <- list()
  
  message(cli_rule("Diagnostic Report"))
  
  # System information
  report$system <- list(
    os = Sys.info()["sysname"],
    r_version = R.version.string,
    platform = R.version$platform
  )
  message("\nSystem Information:")
  message(sprintf("  OS: %s", report$system$os))
  message(sprintf("  R Version: %s", report$system$r_version))
  
  # Memory status
  gc_info <- gc()
  report$memory <- list(
    used_mb = sum(gc_info[, "used"]) / 1024,
    max_mb = sum(gc_info[, "max used"]) / 1024
  )
  message(sprintf("\nMemory Usage: %.1f MB / %.1f MB", 
                 report$memory$used_mb, report$memory$max_mb))
  
  # Package versions
  key_packages <- c("inrep", "shiny", "TAM")
  report$packages <- list()
  message("\nPackage Versions:")
  for (pkg in key_packages) {
    if (requireNamespace(pkg, quietly = TRUE)) {
      version <- packageVersion(pkg)
      report$packages[[pkg]] <- as.character(version)
      message(sprintf("  %s: %s", pkg, version))
    } else {
      report$packages[[pkg]] <- "Not installed"
      message(sprintf("  %s: Not installed", pkg))
    }
  }
  
  # Check for common issues
  message("\nCommon Issues Check:")
  
  # Check temp directory
  temp_dir <- tempdir()
  if (!dir.exists(temp_dir)) {
    message("  ", cli_cross(), " Temp directory not accessible")
  } else {
    message("  ", cli_check(), " Temp directory accessible")
  }
  
  # Check network (if relevant)
  if (capabilities("libcurl")) {
    message("  ", cli_check(), " Network capabilities available")
  } else {
    message("  ", cli_warning(), " Limited network capabilities")
  }
  
  # Parse error log if provided
  if (!is.null(error_log) && file.exists(error_log)) {
    message("\nRecent Errors:")
    errors <- readLines(error_log, n = 10)
    for (error in tail(errors, 5)) {
      message("  ", error)
    }
  }
  
  # Recommendations
  message("\nRecommendations:")
  if (report$memory$used_mb > report$memory$max_mb * 0.8) {
    message("  - Consider increasing memory allocation with options(java.parameters = '-Xmx4g')")
  }
  if (report$packages$TAM == "Not installed") {
    message("  - Install TAM package: install.packages('TAM')")
  }
  
  if (session_info) {
    report$session <- sessionInfo()
  }
  
  message(cli_rule())
  message("Save this report with: saveRDS(diagnose_issue(), 'diagnostic_report.rds')")
  
  invisible(report)
}

# Helper functions for CLI elements
cli_rule <- function(text = "") {
  width <- getOption("width", 80)
  if (text == "") {
    paste(rep("-", width), collapse = "")
  } else {
    text <- paste0(" ", text, " ")
    side_width <- (width - nchar(text)) / 2
    paste0(
      paste(rep("-", floor(side_width)), collapse = ""),
      text,
      paste(rep("-", ceiling(side_width)), collapse = "")
    )
  }
}

cli_check <- function() "[OK]"
cli_cross <- function() "[X]"
cli_warning <- function() "[!]"
cli_tip <- function() "[TIP]"
