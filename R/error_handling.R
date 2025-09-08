# Comprehensive Error Handling System for inrep Package
# Provides robust error handling, validation, and recovery mechanisms

#' Enhanced Error Handling and Validation System
#' 
#' This module provides comprehensive error handling, input validation,
#' and graceful error recovery for the inrep package.
#' 
#' @name error_handling
#' @keywords internal
NULL

#' Validate and sanitize user input
#' 
#' Validates user input parameters and provides helpful error messages
#' with suggestions for correction.
#' 
#' @param input The input value to validate
#' @param type The expected type of input
#' @param param_name The name of the parameter for error messages
#' @param valid_values Optional vector of valid values
#' @param min_val Optional minimum value for numeric inputs
#' @param max_val Optional maximum value for numeric inputs
#' @return Validated input value
#' @export
validate_input <- function(input, type, param_name, valid_values = NULL, 
                          min_val = NULL, max_val = NULL) {
  
  # Check for NULL input
  if (is.null(input)) {
    stop("Parameter '", param_name, "' cannot be NULL", call. = FALSE)
  }
  
  # Type validation
  if (type == "character") {
    if (!is.character(input)) {
      stop("Parameter '", param_name, "' must be a character string", call. = FALSE)
    }
    if (length(input) != 1) {
      stop("Parameter '", param_name, "' must be a single character string", call. = FALSE)
    }
    if (nchar(input) == 0) {
      stop("Parameter '", param_name, "' cannot be empty", call. = FALSE)
    }
  } else if (type == "numeric") {
    if (!is.numeric(input)) {
      stop("Parameter '", param_name, "' must be numeric", call. = FALSE)
    }
    if (length(input) != 1) {
      stop("Parameter '", param_name, "' must be a single number", call. = FALSE)
    }
    if (is.na(input)) {
      stop("Parameter '", param_name, "' cannot be NA", call. = FALSE)
    }
  } else if (type == "logical") {
    if (!is.logical(input)) {
      stop("Parameter '", param_name, "' must be logical (TRUE/FALSE)", call. = FALSE)
    }
    if (length(input) != 1) {
      stop("Parameter '", param_name, "' must be a single logical value", call. = FALSE)
    }
    if (is.na(input)) {
      stop("Parameter '", param_name, "' cannot be NA", call. = FALSE)
    }
  } else if (type == "integer") {
    if (!is.numeric(input) || !all(input == as.integer(input))) {
      stop("Parameter '", param_name, "' must be an integer", call. = FALSE)
    }
    if (length(input) != 1) {
      stop("Parameter '", param_name, "' must be a single integer", call. = FALSE)
    }
    if (is.na(input)) {
      stop("Parameter '", param_name, "' cannot be NA", call. = FALSE)
    }
  }
  
  # Valid values validation
  if (!is.null(valid_values)) {
    if (!input %in% valid_values) {
      stop("Parameter '", param_name, "' must be one of: ", 
           paste(valid_values, collapse = ", "), call. = FALSE)
    }
  }
  
  # Range validation for numeric inputs
  if (type %in% c("numeric", "integer")) {
    if (!is.null(min_val) && input < min_val) {
      stop("Parameter '", param_name, "' must be >= ", min_val, call. = FALSE)
    }
    if (!is.null(max_val) && input > max_val) {
      stop("Parameter '", param_name, "' must be <= ", max_val, call. = FALSE)
    }
  }
  
  return(input)
}

#' Validate study configuration with detailed error messages
#' 
#' @param config Study configuration to validate
#' @return Validated configuration with corrections applied
#' @export
validate_study_config <- function(config) {
  if (!is.list(config)) {
    stop("Configuration must be a list", call. = FALSE)
  }
  
  # Required parameters
  required_params <- c("name", "model")
  missing_params <- required_params[!required_params %in% names(config)]
  if (length(missing_params) > 0) {
    stop("Missing required parameters: ", paste(missing_params, collapse = ", "), 
         call. = FALSE)
  }
  
  # Validate name
  config$name <- validate_input(config$name, "character", "name")
  
  # Validate model
  valid_models <- c("1PL", "2PL", "3PL", "GRM")
  config$model <- validate_input(config$model, "character", "model", valid_models)
  
  # Validate max_items
  if ("max_items" %in% names(config)) {
    config$max_items <- validate_input(config$max_items, "integer", "max_items", 
                                      min_val = 1, max_val = 1000)
  } else {
    config$max_items <- 20
  }
  
  # Validate min_items
  if ("min_items" %in% names(config)) {
    config$min_items <- validate_input(config$min_items, "integer", "min_items", 
                                      min_val = 0, max_val = config$max_items)
  } else {
    config$min_items <- 5
  }
  
  # Validate min_SEM
  if ("min_SEM" %in% names(config)) {
    config$min_SEM <- validate_input(config$min_SEM, "numeric", "min_SEM", 
                                    min_val = 0.01, max_val = 2.0)
  } else {
    config$min_SEM <- 0.3
  }
  
  # Validate criteria
  if ("criteria" %in% names(config)) {
    valid_criteria <- c("MI", "MFI", "KL", "random")
    config$criteria <- validate_input(config$criteria, "character", "criteria", valid_criteria)
  } else {
    config$criteria <- "MI"
  }
  
  # Validate adaptive
  if ("adaptive" %in% names(config)) {
    config$adaptive <- validate_input(config$adaptive, "logical", "adaptive")
  } else {
    config$adaptive <- TRUE
  }
  
  # Validate parallel processing parameters
  if ("parallel_computation" %in% names(config)) {
    config$parallel_computation <- validate_input(config$parallel_computation, "logical", "parallel_computation")
  } else {
    config$parallel_computation <- FALSE
  }
  
  if (config$parallel_computation) {
    if ("parallel_workers" %in% names(config)) {
      max_workers <- min(parallel::detectCores(), 8)
      config$parallel_workers <- validate_input(config$parallel_workers, "integer", "parallel_workers", 
                                               min_val = 1, max_val = max_workers)
    } else {
      config$parallel_workers <- min(4, parallel::detectCores())
    }
    
    if ("parallel_batch_size" %in% names(config)) {
      config$parallel_batch_size <- validate_input(config$parallel_batch_size, "integer", "parallel_batch_size", 
                                                  min_val = 1, max_val = 1000)
    } else {
      config$parallel_batch_size <- 25
    }
  }
  
  # Validate theme
  if ("theme" %in% names(config)) {
    valid_themes <- c("light", "dark", "professional", "monochrome", "ocean", 
                     "forest", "midnight", "sunset", "hildesheim")
    config$theme <- validate_input(config$theme, "character", "theme", valid_themes)
  } else {
    config$theme <- "light"
  }
  
  # Validate demographics
  if ("demographics" %in% names(config)) {
    if (!is.character(config$demographics)) {
      stop("Parameter 'demographics' must be a character vector", call. = FALSE)
    }
    if (any(nchar(config$demographics) == 0)) {
      stop("Demographic field names cannot be empty", call. = FALSE)
    }
  }
  
  return(config)
}

#' Handle errors gracefully with recovery options
#' 
#' @param expr Expression to evaluate
#' @param error_message Custom error message
#' @param recovery_action Function to call for recovery
#' @param max_retries Maximum number of retry attempts
#' @return Result of expression or recovery action
#' @export
handle_error_gracefully <- function(expr, error_message = NULL, recovery_action = NULL, max_retries = 3) {
  retry_count <- 0
  
  while (retry_count <= max_retries) {
    tryCatch({
      return(eval(expr))
    }, error = function(e) {
      retry_count <<- retry_count + 1
      
      if (retry_count > max_retries) {
        if (!is.null(recovery_action)) {
          warning("Maximum retries exceeded, attempting recovery action")
          return(recovery_action())
        } else {
          stop(ifelse(is.null(error_message), e$message, error_message), call. = FALSE)
        }
      } else {
        warning("Attempt ", retry_count, " failed: ", e$message, ". Retrying...")
        Sys.sleep(0.1 * retry_count)  # Exponential backoff
      }
    })
  }
}

#' Validate item bank with detailed error reporting
#' 
#' @param item_bank Item bank data frame
#' @param model IRT model type
#' @return TRUE if valid, FALSE otherwise
#' @export
validate_item_bank_detailed <- function(item_bank, model) {
  errors <- c()
  warnings <- c()
  
  # Check if item_bank is a data frame
  if (!is.data.frame(item_bank)) {
    errors <- c(errors, "Item bank must be a data frame")
    return(list(valid = FALSE, errors = errors, warnings = warnings))
  }
  
  # Check if item_bank is empty
  if (nrow(item_bank) == 0) {
    errors <- c(errors, "Item bank cannot be empty")
    return(list(valid = FALSE, errors = errors, warnings = warnings))
  }
  
  # Check for item_id column
  if (!"item_id" %in% names(item_bank)) {
    errors <- c(errors, "Item bank must contain 'item_id' column")
  }
  
  # Check for duplicate item_ids
  if ("item_id" %in% names(item_bank)) {
    if (any(duplicated(item_bank$item_id))) {
      errors <- c(errors, "Item bank contains duplicate item_ids")
    }
  }
  
  # Model-specific validation
  if (model == "1PL") {
    if (!"b" %in% names(item_bank)) {
      errors <- c(errors, "1PL model requires 'b' column")
    }
  } else if (model == "2PL") {
    required_cols <- c("a", "b")
    missing_cols <- required_cols[!required_cols %in% names(item_bank)]
    if (length(missing_cols) > 0) {
      errors <- c(errors, paste("2PL model requires columns:", paste(missing_cols, collapse = ", ")))
    }
  } else if (model == "3PL") {
    required_cols <- c("a", "b", "c")
    missing_cols <- required_cols[!required_cols %in% names(item_bank)]
    if (length(missing_cols) > 0) {
      errors <- c(errors, paste("3PL model requires columns:", paste(missing_cols, collapse = ", ")))
    }
  } else if (model == "GRM") {
    required_cols <- c("a", "b1", "b2", "b3")
    missing_cols <- required_cols[!required_cols %in% names(item_bank)]
    if (length(missing_cols) > 0) {
      errors <- c(errors, paste("GRM model requires columns:", paste(missing_cols, collapse = ", ")))
    }
  }
  
  # Validate parameter values
  if ("a" %in% names(item_bank)) {
    if (any(item_bank$a <= 0, na.rm = TRUE)) {
      errors <- c(errors, "Discrimination parameters (a) must be positive")
    }
  }
  
  if ("c" %in% names(item_bank)) {
    if (any(item_bank$c < 0 | item_bank$c >= 1, na.rm = TRUE)) {
      errors <- c(errors, "Guessing parameters (c) must be between 0 and 1")
    }
  }
  
  # Check for missing values
  numeric_cols <- sapply(item_bank, is.numeric)
  if (any(is.na(item_bank[, numeric_cols]))) {
    warnings <- c(warnings, "Item bank contains missing values in numeric columns")
  }
  
  return(list(
    valid = length(errors) == 0,
    errors = errors,
    warnings = warnings
  ))
}

#' Create user-friendly error messages
#' 
#' @param error_type Type of error
#' @param context Additional context
#' @return User-friendly error message
#' @export
create_user_friendly_error <- function(error_type, context = NULL) {
  error_messages <- list(
    "invalid_config" = "Invalid study configuration. Please check your parameters and try again.",
    "invalid_item_bank" = "Invalid item bank. Please ensure all required columns are present and parameters are valid.",
    "missing_dependencies" = "Required packages are missing. Please install them and try again.",
    "parallel_error" = "Parallel processing error. Falling back to sequential processing.",
    "memory_error" = "Insufficient memory. Try reducing batch size or item bank size.",
    "network_error" = "Network error. Please check your connection and try again.",
    "validation_error" = "Input validation failed. Please check your parameters.",
    "computation_error" = "Computation error. Please check your data and try again."
  )
  
  base_message <- error_messages[[error_type]] %||% "An unexpected error occurred."
  
  if (!is.null(context)) {
    return(paste(base_message, "Context:", context))
  } else {
    return(base_message)
  }
}

#' Log errors with context
#' 
#' @param error Error object
#' @param context Additional context
#' @param level Log level
#' @export
log_error <- function(error, context = NULL, level = "ERROR") {
  error_msg <- paste("Error:", error$message)
  if (!is.null(context)) {
    error_msg <- paste(error_msg, "Context:", context)
  }
  
  # Log to console if debug mode is enabled
  if (getOption("inrep.debug", FALSE)) {
    message(paste("[", level, "]", error_msg))
  }
  
  # Log to file if logging is enabled
  if (getOption("inrep.logging", FALSE)) {
    log_file <- getOption("inrep.log_file", "inrep.log")
    cat(paste(Sys.time(), "[", level, "]", error_msg, "\n"), 
        file = log_file, append = TRUE)
  }
}

#' Set up error handling options
#' 
#' @param debug Enable debug mode
#' @param logging Enable file logging
#' @param log_file Log file path
#' @export
setup_error_handling <- function(debug = FALSE, logging = FALSE, log_file = "inrep.log") {
  options(
    inrep.debug = debug,
    inrep.logging = logging,
    inrep.log_file = log_file
  )
}