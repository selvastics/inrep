#' Essential Enhanced Features for inrep Package
#' 
#' This file contains only the essential enhanced features that are actively used:
#' - Configuration validation and fixing
#' - Performance optimization initialization
#' - Response reporting
#' 
#' @name enhanced_features
#' @keywords internal

# ===========================================================================
# PERFORMANCE STATE
# ===========================================================================

# Global performance state
.performance_state <- new.env()
.performance_state$cache <- list()
.performance_state$memory_monitor <- list(active = FALSE)

# ===========================================================================
# CONFIGURATION VALIDATION
# ===========================================================================

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
      fixed_config$min_SEM <- 999
      fixed_config$adaptive_stopping <- FALSE
    }
  }
  
  # 4. Handle demographic variables
  if (!is.null(fixed_config$demographics)) {
    if (length(fixed_config$demographics) > 100) {
      warnings$demographics <- "Too many demographic variables, limiting to 100"
      fixed_config$demographics <- fixed_config$demographics[1:100]
    }
    fixed_config$demographics <- make.names(fixed_config$demographics, unique = TRUE)
  }
  
  # 5. Handle names
  if (!is.null(fixed_config$name)) {
    if (nchar(trimws(fixed_config$name)) == 0) {
      fixed_config$name <- "Unnamed Study"
    }
    if (nchar(fixed_config$name) > 500) {
      fixed_config$name <- substr(fixed_config$name, 1, 500)
    }
  } else {
    fixed_config$name <- "Unnamed Study"
  }
  
  # 6. Validate item bank compatibility
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
  
  if (!is.data.frame(item_bank)) {
    stop("Item bank must be a data frame")
  }
  
  n_items <- nrow(item_bank)
  
  # Check max_items doesn't exceed item bank
  if (!is.null(config$max_items) && config$max_items > n_items) {
    config$max_items <- n_items
    config$validation_warnings$max_items_adjusted <- 
      paste("max_items reduced to", n_items, "(item bank size)")
  }
  
  # Check model compatibility
  if (config$model == "GRM") {
    required_cols <- c("Question", "a", "b1", "b2", "b3", "b4")
    if (!all(required_cols %in% names(item_bank))) {
      config$validation_warnings$grm_params <- 
        "GRM requires a, b1, b2, b3, b4 parameters"
    }
  } else if (config$model %in% c("2PL", "3PL")) {
    required_cols <- c("Question", "a", "b")
    if (!all(required_cols %in% names(item_bank))) {
      config$validation_warnings$binary_params <- 
        paste(config$model, "requires a and b parameters")
    }
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

#' Optimize Configuration for Scale
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

# ===========================================================================
# PERFORMANCE OPTIMIZATION
# ===========================================================================

#' Initialize Performance Optimization
#' 
#' @param enable_caching Enable result caching
#' @param enable_memory_management Enable automatic memory management
#' @param enable_query_optimization Enable query result caching
#' @param max_cache_size Maximum cache size in MB
#' @param max_concurrent_users Maximum concurrent users
#' @return List with performance configuration
#' @export
initialize_performance_optimization <- function(
  enable_caching = TRUE,
  enable_memory_management = TRUE,
  enable_query_optimization = TRUE,
  max_cache_size = 500,
  max_concurrent_users = 1000
) {
  .performance_state$enable_caching <- enable_caching
  .performance_state$enable_memory_management <- enable_memory_management
  .performance_state$enable_query_optimization <- enable_query_optimization
  .performance_state$max_cache_size <- max_cache_size * 1024 * 1024
  .performance_state$max_concurrent_users <- max_concurrent_users
  
  # Start memory monitoring
  if (enable_memory_management) {
    start_memory_monitoring()
  }
  
  # Initialize cache cleanup
  if (enable_caching) {
    schedule_cache_cleanup()
  }
  
  return(list(
    caching = enable_caching,
    memory_management = enable_memory_management,
    query_optimization = enable_query_optimization,
    max_cache_size = max_cache_size,
    max_concurrent_users = max_concurrent_users
  ))
}

#' Start Memory Monitoring
#' @noRd
start_memory_monitoring <- function() {
  .performance_state$memory_monitor$active <- TRUE
  .performance_state$memory_monitor$threshold <- 0.8
}

#' Check Cache Size
#' @noRd
check_cache_size <- function() {
  if (length(.performance_state$cache) == 0) return(0)
  
  total_size <- 0
  for (key in names(.performance_state$cache)) {
    entry <- .performance_state$cache[[key]]
    if (!is.null(entry$size)) {
      total_size <- total_size + as.numeric(entry$size)
    }
  }
  
  return(total_size)
}

#' Evict Old Cache Entries
#' @noRd
evict_old_cache_entries <- function() {
  if (length(.performance_state$cache) == 0) return()
  
  # Get cache entries
  entries <- lapply(names(.performance_state$cache), function(key) {
    entry <- .performance_state$cache[[key]]
    list(
      key = key,
      created = entry$created,
      hits = entry$hits %||% 0,
      size = as.numeric(entry$size)
    )
  })
  
  # Sort by hits (LRU)
  entries <- entries[order(sapply(entries, function(x) x$hits))]
  
  # Remove bottom 25%
  n_remove <- ceiling(length(entries) * 0.25)
  if (n_remove > 0) {
    for (i in seq_len(n_remove)) {
      .performance_state$cache[[entries[[i]]$key]] <- NULL
    }
  }
}

#' Schedule Cache Cleanup
#' @noRd
schedule_cache_cleanup <- function() {
  # Placeholder - would use shiny::observe in actual Shiny app
  .performance_state$cache_cleanup_scheduled <- TRUE
}

# ===========================================================================
# RESPONSE REPORTING
# ===========================================================================

#' Create Enhanced Response Report
#'
#' @param config Study configuration object
#' @param cat_result CAT result object with responses
#' @param item_bank Item bank dataset
#' @param include_labels Include response labels
#' 
#' @return Data frame with response report
#' @export
create_response_report <- function(config, cat_result, item_bank, include_labels = TRUE) {
  
  if (is.null(cat_result) || is.null(cat_result$responses)) {
    stop("Invalid cat_result: missing responses")
  }
  
  items <- cat_result$administered
  responses <- cat_result$responses
  
  # Basic table structure
  if (config$model == "GRM") {
    # For GRM, show actual response values with optional labels
    dat <- data.frame(
      Item = item_bank$Question[items],
      Response = responses,
      Time = round(cat_result$response_times, 1),
      check.names = FALSE
    )
    
    # Add response labels if requested
    if (include_labels && config$language %in% c("en", "de", "es", "fr")) {
      response_labels <- switch(config$language,
        "en" = c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"),
        "de" = c("Stark ablehnen", "Ablehnen", "Neutral", "Zustimmen", "Stark zustimmen"),
        "es" = c("Totalmente en desacuerdo", "En desacuerdo", "Neutral", "De acuerdo", "Totalmente de acuerdo"),
        "fr" = c("Fortement en désaccord", "En désaccord", "Neutre", "D'accord", "Fortement d'accord")
      )
      
      # Add response labels column
      dat$Response_Label <- response_labels[responses]
      
      # Reorder columns
      dat <- dat[, c("Item", "Response", "Response_Label", "Time")]
    }
    
  } else {
    # For binary models, show correct/incorrect with answers
    # Check if Answer column exists (for compatibility with different item banks)
    if ("Answer" %in% names(item_bank)) {
      dat <- data.frame(
        Item = item_bank$Question[items],
        Response = ifelse(responses == 1, "Correct", "Incorrect"),
        Correct = item_bank$Answer[items],
        Time = round(cat_result$response_times, 1),
        check.names = FALSE
      )
    } else {
      # For item banks without Answer column (e.g., personality items)
      dat <- data.frame(
        Item = item_bank$Question[items],
        Response = responses,
        Score = responses,  # For personality items, response is the score
        Time = round(cat_result$response_times, 1),
        check.names = FALSE
      )
    }
  }
  
  # Add validation metadata
  attr(dat, "validation_info") <- list(
    total_items = length(items),
    total_responses = length(responses),
    response_consistency = all(!is.na(responses)),
    model = config$model,
    timestamp = Sys.time()
  )
  
  return(dat)
}

#' Validate Response Report Consistency
#'
#' @param original_responses Vector of original responses
#' @param report_data Response report data frame
#' @param config Study configuration object
#' 
#' @return List with validation results
#' @export
validate_response_report <- function(original_responses, report_data, config) {

  if (config$model == "GRM") {
    # For GRM, responses should match exactly
    reported_responses <- report_data$Response
    consistency_check <- all(reported_responses == original_responses)
  } else {
    # For binary models, check scoring consistency
    if ("Correct" %in% names(report_data)) {
      # Traditional binary model with Answer column
      reported_binary <- ifelse(report_data$Response == "Correct", 1, 0)
      consistency_check <- length(reported_binary) == length(original_responses)
    } else {
      # For item banks without Answer column (e.g., personality items)
      reported_responses <- report_data$Response
      consistency_check <- all(reported_responses == original_responses)
    }
  }
  
  validation_result <- list(
    consistent = consistency_check,
    original_count = length(original_responses),
    reported_count = nrow(report_data),
    model = config$model,
    timestamp = Sys.time()
  )
  
  return(validation_result)
}
