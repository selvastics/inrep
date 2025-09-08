
#' Safe JSON serialization helper
#' @param obj Object to serialize
#' @return JSON string or error-safe alternative
safe_json_serialize <- function(obj) {
  tryCatch({
    # Handle numeric_version objects
    if (inherits(obj, "numeric_version")) {
      obj <- as.character(obj)
    }
    
    # Handle other problematic classes
    if (inherits(obj, c("package_version", "R_system_version"))) {
      obj <- as.character(obj)
    }
    
    # Recursively handle lists
    if (is.list(obj)) {
      obj <- lapply(obj, function(x) {
        if (inherits(x, c("numeric_version", "package_version", "R_system_version"))) {
          as.character(x)
        } else {
          x
        }
      })
    }
    
    # Try to serialize
    if (requireNamespace("jsonlite", quietly = TRUE)) {
      jsonlite::toJSON(obj, auto_unbox = TRUE, null = "null")
    } else {
      # Fallback to base R
      paste0("{\"data\": \"", as.character(obj), "\"}")
    }
  }, error = function(e) {
    # Safe fallback
    paste0("{\"error\": \"serialization_failed\", \"message\": \"", e$message, "\"}")
  })
}

#' Safe logging function with type validation
#' @param message Message to log
#' @param level Log level
safe_log <- function(message, level = "INFO") {
  tryCatch({
    # Ensure message is character
    if (!is.character(message)) {
      message <- as.character(message)
    }
    
    # Ensure level is character
    if (!is.character(level)) {
      level <- as.character(level)
    }
    
    # Ensure message has length > 0
    if (length(message) == 0) {
      message <- "Empty log message"
    }
    
    # Ensure level has length > 0
    if (length(level) == 0) {
      level <- "INFO"
    }
    
    # Call the actual logging function
    if (exists("logger", mode = "function")) {
      logger(message, level = level)
    } else {
      # Fallback to cat
      cat(paste0("[", level, "] ", message, "
"))
    }
  }, error = function(e) {
    # Silent fallback - don't break the application
    cat(paste0("[ERROR] Logging failed: ", e$message, "
"))
  })
}

#' Safe conditional check with length validation
#' @param condition Condition to check
#' @param default Default value if condition is invalid
safe_if <- function(condition, default = FALSE) {
  tryCatch({
    # Check if condition exists and has length > 0
    if (is.null(condition) || length(condition) == 0) {
      return(default)
    }
    
    # Check if condition is logical
    if (!is.logical(condition)) {
      # Try to convert
      condition <- as.logical(condition)
    }
    
    # Return the condition or default
    if (length(condition) > 0 && !is.na(condition)) {
      return(condition[1])  # Take first element if vector
    } else {
      return(default)
    }
  }, error = function(e) {
    return(default)
  })
}

#' Safe data preservation with error handling
#' @param data Data to preserve
#' @param session_id Session identifier
safe_preserve_data <- function(data, session_id = NULL) {
  tryCatch({
    # Validate inputs
    if (is.null(data)) {
      return(FALSE)
    }
    
    if (is.null(session_id) || length(session_id) == 0) {
      session_id <- paste0("session_", Sys.time())
    }
    
    # Try to preserve data
    if (exists("preserve_data", mode = "function")) {
      preserve_data(data, session_id)
    } else {
      # Fallback - just return TRUE
      TRUE
    }
  }, error = function(e) {
    # Log error but don't break the application
    safe_log(paste("Data preservation failed:", e$message), "WARNING")
    FALSE
  })
}

#' Comprehensive error handling wrapper for inrep functions
#' @param expr Expression to execute safely
#' @param default Default return value on error
#' @param silent Whether to suppress error messages
#' @return Result of expression or default value
safe_execute <- function(expr, default = NULL, silent = FALSE) {
  tryCatch({
    expr
  }, error = function(e) {
    if (!silent) {
      safe_log(paste("Safe execution caught error:", e$message), "WARNING")
    }
    default
  }, warning = function(w) {
    if (!silent) {
      safe_log(paste("Safe execution caught warning:", w$message), "INFO")
    }
    suppressWarnings(expr)
  })
}

#' Safe reactive value access with validation
#' @param rv Reactive values object
#' @param key Key to access
#' @param default Default value if key doesn't exist or is invalid
safe_rv_get <- function(rv, key, default = NULL) {
  tryCatch({
    if (is.null(rv) || !exists(key, where = rv)) {
      return(default)
    }
    
    value <- rv[[key]]
    
    if (is.null(value) || length(value) == 0) {
      return(default)
    }
    
    return(value)
  }, error = function(e) {
    return(default)
  })
}

#' Safe reactive value setting with validation
#' @param rv Reactive values object  
#' @param key Key to set
#' @param value Value to set
safe_rv_set <- function(rv, key, value) {
  tryCatch({
    if (!is.null(rv) && is.character(key) && length(key) > 0) {
      rv[[key]] <- value
      return(TRUE)
    }
    return(FALSE)
  }, error = function(e) {
    safe_log(paste("Failed to set reactive value:", e$message), "WARNING")
    return(FALSE)
  })
}
