#' Enhanced Configuration Handler
#' 
#' Handles all edge cases and validates study configurations to prevent errors
#' 
#' @name enhanced_config_handler
#' @docType data
NULL

#' Validate and Fix Study Configuration
#' 
#' Validates study configuration and fixes common issues
#' 
#' @param config Study configuration list
#' @param item_bank Item bank data frame (optional)
#' @return Validated and corrected configuration
#' @export
validate_and_fix_config <- function(config, item_bank = NULL) {
  if (is.null(config)) {
    stop("Configuration cannot be NULL")
  }
  
  # Initialize fixed config
  fixed_config <- config
  warnings <- list()
  
  # 1. Handle extreme item counts
  if (!is.null(fixed_config$max_items)) {
    if (fixed_config$max_items > 1000) {
      warnings$max_items <- "Maximum items exceeds 1000, capping at 1000 for performance"
      fixed_config$max_items <- 1000
    }
    if (fixed_config$max_items < 1) {
      warnings$min_items <- "Maximum items must be at least 1"
      fixed_config$max_items <- 1
    }
  }
  
  if (!is.null(fixed_config$min_items)) {
    if (fixed_config$min_items < 1) {
      fixed_config$min_items <- 1
    }
    if (!is.null(fixed_config$max_items) && fixed_config$min_items > fixed_config$max_items) {
      fixed_config$min_items <- fixed_config$max_items
      warnings$item_mismatch <- "min_items cannot exceed max_items, adjusted"
    }
  }
  
  # 2. Handle invalid model specifications
  valid_models <- c("1PL", "2PL", "3PL", "GRM", "PCM", "RSM", "GPCM")
  if (!is.null(fixed_config$model)) {
    if (!(fixed_config$model %in% valid_models)) {
      warnings$model <- paste("Invalid model:", fixed_config$model, "- defaulting to 2PL")
      fixed_config$model <- "2PL"
    }
  } else {
    fixed_config$model <- "2PL"
  }
  
  # 3. Handle extreme SEM values
  if (!is.null(fixed_config$min_SEM)) {
    if (fixed_config$min_SEM < 0) {
      fixed_config$min_SEM <- 0.3
      warnings$sem <- "Invalid min_SEM, using default 0.3"
    }
    if (fixed_config$min_SEM > 10) {
      # Value > 10 likely means disable adaptive stopping
      fixed_config$min_SEM <- 999
      fixed_config$adaptive_stopping <- FALSE
    }
  }
  
  # 4. Handle demographic variables
  if (!is.null(fixed_config$demographics)) {
    # Limit to 100 demographic variables
    if (length(fixed_config$demographics) > 100) {
      warnings$demographics <- "Too many demographic variables, limiting to 100"
      fixed_config$demographics <- fixed_config$demographics[1:100]
    }
    
    # Sanitize demographic names
    fixed_config$demographics <- make.names(fixed_config$demographics, unique = TRUE)
  }
  
  # 5. Handle special characters in names
  if (!is.null(fixed_config$name)) {
    # Ensure name is not empty
    if (nchar(trimws(fixed_config$name)) == 0) {
      fixed_config$name <- "Unnamed Study"
    }
    # Limit name length
    if (nchar(fixed_config$name) > 500) {
      fixed_config$name <- substr(fixed_config$name, 1, 500)
    }
  } else {
    fixed_config$name <- "Unnamed Study"
  }
  
  # 6. Handle input types
  valid_input_types <- c("text", "numeric", "select", "radio", "checkbox", "slider", "date", "email")
  if (!is.null(fixed_config$input_types)) {
    for (field in names(fixed_config$input_types)) {
      if (!(fixed_config$input_types[[field]] %in% valid_input_types)) {
        fixed_config$input_types[[field]] <- "text"
        warnings[[paste0("input_", field)]] <- "Invalid input type, defaulting to text"
      }
    }
  }
  
  # 7. Handle time limits
  if (!is.null(fixed_config$time_limit)) {
    if (fixed_config$time_limit < 0) {
      fixed_config$time_limit <- NULL
    } else if (fixed_config$time_limit > 86400) {  # More than 24 hours
      fixed_config$time_limit <- 86400
      warnings$time_limit <- "Time limit capped at 24 hours"
    }
  }
  
  # 8. Handle language settings
  valid_languages <- c("en", "de", "es", "fr", "it", "pt", "nl", "pl", "ru", "zh", "ja", "ko", "ar", "multi")
  if (!is.null(fixed_config$language)) {
    if (!(fixed_config$language %in% valid_languages)) {
      if (fixed_config$language != "multi") {
        fixed_config$language <- "en"
        warnings$language <- "Unsupported language, defaulting to English"
      }
    }
  } else {
    fixed_config$language <- "en"
  }
  
  # 9. Handle clinical/sensitive settings
  if (!is.null(fixed_config$suicide_item_alert)) {
    fixed_config$clinical_mode <- TRUE
    fixed_config$emergency_contact <- fixed_config$emergency_contact %||% "911"
  }
  
  # 10. Handle save formats
  valid_formats <- c("rds", "csv", "json", "xlsx", "pdf", "encrypted_json", "encrypted_rds")
  if (!is.null(fixed_config$save_format)) {
    if (!(fixed_config$save_format %in% valid_formats)) {
      fixed_config$save_format <- "rds"
      warnings$save_format <- "Invalid save format, defaulting to RDS"
    }
  }
  
  # 11. Handle branching rules
  if (!is.null(fixed_config$branching_rules)) {
    # Validate branching rules structure
    for (rule_name in names(fixed_config$branching_rules)) {
      rule <- fixed_config$branching_rules[[rule_name]]
      if (!all(c("condition", "action") %in% names(rule)) && 
          !all(c("theta_threshold", "next_module") %in% names(rule))) {
        warnings[[paste0("branch_", rule_name)]] <- "Invalid branching rule structure"
        fixed_config$branching_rules[[rule_name]] <- NULL
      }
    }
  }
  
  # 12. Handle extreme concurrent users
  if (!is.null(fixed_config$expected_n)) {
    if (fixed_config$expected_n > 10000) {
      fixed_config$enable_load_balancing <- TRUE
      fixed_config$enable_caching <- TRUE
      fixed_config$database_mode <- "distributed"
    }
  }
  
  # 13. Handle accessibility settings
  if (isTRUE(fixed_config$accessibility_enhanced)) {
    # Ensure all accessibility features are enabled
    fixed_config$font_size_adjustable <- TRUE
    fixed_config$high_contrast_available <- TRUE
    fixed_config$screen_reader_compatible <- TRUE
    fixed_config$keyboard_navigation <- TRUE
    fixed_config$aria_labels <- TRUE
  }
  
  # 14. Handle proctoring settings
  if (isTRUE(fixed_config$proctoring_enabled)) {
    # Set up proctoring requirements
    fixed_config$require_webcam <- fixed_config$webcam_monitoring %||% FALSE
    fixed_config$require_fullscreen <- TRUE
    fixed_config$detect_tab_switch <- TRUE
    fixed_config$prevent_right_click <- TRUE
  }
  
  # 15. Handle 360 feedback settings
  if (isTRUE(fixed_config$aggregate_results)) {
    fixed_config$multi_rater_mode <- TRUE
    if (is.null(fixed_config$minimum_raters)) {
      fixed_config$minimum_raters <- 3
    }
  }
  
  # 16. Validate item bank compatibility
  if (!is.null(item_bank)) {
    fixed_config <- validate_item_bank_compatibility(fixed_config, item_bank)
  }
  
  # Add warnings to config
  if (length(warnings) > 0) {
    fixed_config$validation_warnings <- warnings
  }
  
  # Add validation timestamp
  fixed_config$validated_at <- Sys.time()
  fixed_config$validation_version <- "2.0.0"
  
  return(fixed_config)
}

#' Validate Item Bank Compatibility
#' 
#' Ensures item bank is compatible with configuration
#' 
#' @param config Study configuration
#' @param item_bank Item bank data frame
#' @return Updated configuration
validate_item_bank_compatibility <- function(config, item_bank) {
  if (is.null(item_bank) || nrow(item_bank) == 0) {
    stop("Item bank is empty or NULL")
  }
  
  # Check required columns based on model
  required_cols <- switch(config$model,
    "1PL" = c("item_id", "content", "difficulty"),
    "2PL" = c("item_id", "content", "difficulty", "discrimination"),
    "3PL" = c("item_id", "content", "difficulty", "discrimination", "guessing"),
    "GRM" = c("item_id", "content", "difficulty"),
    c("item_id", "content", "difficulty")
  )
  
  missing_cols <- setdiff(required_cols, names(item_bank))
  if (length(missing_cols) > 0) {
    # Add missing columns with defaults
    for (col in missing_cols) {
      if (col == "discrimination") {
        item_bank[[col]] <- 1
      } else if (col == "guessing") {
        item_bank[[col]] <- 0.25
      } else if (col == "difficulty") {
        item_bank[[col]] <- rnorm(nrow(item_bank), 0, 1)
      }
    }
    config$item_bank_modified <- TRUE
  }
  
  # Update max_items if needed
  if (is.null(config$max_items) || config$max_items > nrow(item_bank)) {
    config$max_items <- nrow(item_bank)
  }
  
  # Handle multimedia items
  if ("media_url" %in% names(item_bank)) {
    config$has_multimedia <- TRUE
    config$preload_media <- TRUE
  }
  
  # Handle item domains/categories
  if ("domain" %in% names(item_bank) || "category" %in% names(item_bank)) {
    config$has_categories <- TRUE
    config$balance_categories <- config$balance_categories %||% FALSE
  }
  
  # Handle clinical flags
  if ("clinical_flag" %in% names(item_bank)) {
    config$has_clinical_items <- TRUE
    config$monitor_clinical_responses <- TRUE
  }
  
  return(config)
}

#' Handle Extreme Parameters
#' 
#' Handles extreme parameter values gracefully
#' 
#' @param params List of parameters
#' @return Sanitized parameters
#' @export
handle_extreme_parameters <- function(params) {
  sanitized <- params
  
  # Numeric bounds
  numeric_bounds <- list(
    max_items = c(1, 1000),
    min_items = c(1, 1000),
    min_SEM = c(0.01, 10),
    time_limit = c(0, 86400),
    time_per_item = c(1, 3600),
    max_session_duration = c(1, 1440),
    theta_prior = c(-5, 5),
    passing_score = c(-4, 4),
    extended_time_factor = c(1, 5)
  )
  
  for (param in names(numeric_bounds)) {
    if (!is.null(sanitized[[param]])) {
      bounds <- numeric_bounds[[param]]
      if (is.numeric(sanitized[[param]])) {
        sanitized[[param]] <- pmax(bounds[1], pmin(bounds[2], sanitized[[param]]))
      }
    }
  }
  
  # String lengths
  string_maxlen <- list(
    name = 500,
    study_key = 100,
    language = 10,
    theme = 50
  )
  
  for (param in names(string_maxlen)) {
    if (!is.null(sanitized[[param]]) && is.character(sanitized[[param]])) {
      if (nchar(sanitized[[param]]) > string_maxlen[[param]]) {
        sanitized[[param]] <- substr(sanitized[[param]], 1, string_maxlen[[param]])
      }
    }
  }
  
  # Array limits
  array_limits <- list(
    demographics = 100,
    fixed_items = 500,
    report_formats = 10,
    study_phases = 20,
    modules = 50
  )
  
  for (param in names(array_limits)) {
    if (!is.null(sanitized[[param]]) && length(sanitized[[param]]) > array_limits[[param]]) {
      sanitized[[param]] <- sanitized[[param]][1:array_limits[[param]]]
    }
  }
  
  return(sanitized)
}

#' Create Fallback Configuration
#' 
#' Creates a minimal working configuration when errors occur
#' 
#' @param original_config Original configuration that failed
#' @return Fallback configuration
#' @export
create_fallback_config <- function(original_config = NULL) {
  fallback <- list(
    name = "Fallback Assessment",
    model = "1PL",
    max_items = 10,
    min_items = 5,
    min_SEM = 0.4,
    criteria = "RANDOM",
    language = "en",
    theme = "Light",
    adaptive = FALSE,
    session_save = TRUE,
    error_recovery = TRUE,
    fallback_mode = TRUE
  )
  
  # Try to preserve some original settings
  if (!is.null(original_config)) {
    safe_fields <- c("name", "language", "theme")
    for (field in safe_fields) {
      if (!is.null(original_config[[field]])) {
        tryCatch({
          fallback[[field]] <- original_config[[field]]
        }, error = function(e) {
          # Keep fallback value
        })
      }
    }
  }
  
  return(fallback)
}

#' Validate Unicode and Special Characters
#' 
#' Handles unicode and special characters in configuration
#' 
#' @param text Text to validate
#' @param field Field name for context
#' @return Sanitized text
#' @export
validate_unicode_text <- function(text, field = "text") {
  if (is.null(text) || !is.character(text)) {
    return(text)
  }
  
  # Convert to UTF-8
  text <- enc2utf8(text)
  
  # Remove control characters except newline and tab
  text <- gsub("[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F\\x7F]", "", text, perl = TRUE)
  
  # Handle specific fields
  if (field == "item_id") {
    # Item IDs should be ASCII only
    text <- gsub("[^A-Za-z0-9_-]", "_", text)
  } else if (field == "variable_name") {
    # Variable names should follow R naming conventions
    text <- make.names(text)
  }
  
  # Ensure not empty after cleaning
  if (nchar(trimws(text)) == 0) {
    text <- paste0("cleaned_", field)
  }
  
  return(text)
}

#' Handle Complex Branching Rules
#' 
#' Validates and processes complex branching logic
#' 
#' @param rules List of branching rules
#' @return Processed rules
#' @export
handle_branching_rules <- function(rules) {
  if (is.null(rules) || length(rules) == 0) {
    return(NULL)
  }
  
  processed_rules <- list()
  
  for (i in seq_along(rules)) {
    rule <- rules[[i]]
    rule_name <- names(rules)[i] %||% paste0("rule_", i)
    
    # Validate rule structure
    if (is.list(rule)) {
      processed_rule <- list()
      
      # Handle different rule formats
      if ("condition" %in% names(rule) && "action" %in% names(rule)) {
        # Expression-based rule
        processed_rule$type <- "expression"
        processed_rule$condition <- validate_condition_expression(rule$condition)
        processed_rule$action <- validate_action(rule$action)
      } else if ("theta_threshold" %in% names(rule)) {
        # Threshold-based rule
        processed_rule$type <- "threshold"
        processed_rule$theta_threshold <- as.numeric(rule$theta_threshold)
        processed_rule$comparison <- rule$comparison %||% "greater"
        processed_rule$next_module <- rule$next_module %||% "continue"
      } else {
        next  # Skip invalid rule
      }
      
      processed_rules[[rule_name]] <- processed_rule
    }
  }
  
  return(processed_rules)
}

#' Validate Condition Expression
#' 
#' Validates branching condition expressions
#' 
#' @param condition Condition string
#' @return Validated condition
validate_condition_expression <- function(condition) {
  if (is.null(condition) || !is.character(condition)) {
    return("TRUE")
  }
  
  # Check for dangerous functions
  dangerous_patterns <- c("system", "eval", "source", "rm", "unlink", "file", "dir")
  for (pattern in dangerous_patterns) {
    if (grepl(pattern, condition, ignore.case = TRUE)) {
      return("TRUE")  # Default to safe condition
    }
  }
  
  # Validate allowed variables
  allowed_vars <- c("theta", "se", "items_answered", "time_elapsed", "responses")
  
  # Simple validation - more complex validation would parse the expression
  return(condition)
}

#' Validate Action
#' 
#' Validates branching action
#' 
#' @param action Action string
#' @return Validated action
validate_action <- function(action) {
  valid_actions <- c(
    "continue", "skip_to_end", "add_easy_items", "add_hard_items",
    "save_and_exit", "check_fatigue", "show_break", "change_module"
  )
  
  if (!(action %in% valid_actions)) {
    return("continue")
  }
  
  return(action)
}

#' Handle Performance Optimization Settings
#' 
#' Configures performance settings based on scale
#' 
#' @param config Configuration list
#' @param expected_users Expected number of users
#' @return Optimized configuration
#' @export
optimize_for_scale <- function(config, expected_users = NULL) {
  if (is.null(expected_users)) {
    expected_users <- config$expected_n %||% 100
  }
  
  # Small scale (< 100 users)
  if (expected_users < 100) {
    config$cache_enabled <- FALSE
    config$parallel_computation <- FALSE
    config$database_mode <- "sqlite"
    
  # Medium scale (100-1000 users)
  } else if (expected_users < 1000) {
    config$cache_enabled <- TRUE
    config$parallel_computation <- TRUE
    config$database_mode <- "postgresql"
    config$connection_pool_size <- 20
    
  # Large scale (1000-10000 users)
  } else if (expected_users < 10000) {
    config$cache_enabled <- TRUE
    config$parallel_computation <- TRUE
    config$database_mode <- "postgresql"
    config$connection_pool_size <- 50
    config$enable_load_balancing <- TRUE
    config$use_cdn <- TRUE
    
  # Massive scale (10000+ users)
  } else {
    config$cache_enabled <- TRUE
    config$parallel_computation <- TRUE
    config$database_mode <- "distributed"
    config$connection_pool_size <- 100
    config$enable_load_balancing <- TRUE
    config$use_cdn <- TRUE
    config$enable_queue_system <- TRUE
    config$horizontal_scaling <- TRUE
  }
  
  return(config)
}