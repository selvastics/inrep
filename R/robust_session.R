#' Robust Session Management for Sensitive Participant Data
#' 
#' This module provides robust session handling with automatic data preservation,
#' keep-alive functionality, and comprehensive logging to ensure data integrity
#' during assessments.

# Global session state
.session_state <- new.env()
.session_state$keep_alive_active <- FALSE
.session_state$session_start_time <- NULL
.session_state$last_activity <- NULL
.session_state$max_session_time <- NULL
.session_state$data_preservation_interval <- 30  # seconds
.session_state$keep_alive_interval <- 10  # seconds

#' Initialize Robust Session Management
#' 
#' @param max_session_time Maximum session time in seconds (default: 7200 = 2 hours)
#' @param data_preservation_interval Interval for automatic data preservation in seconds
#' @param keep_alive_interval Keep-alive ping interval in seconds
#' @param enable_logging Whether to enable comprehensive logging
#' @return List with session configuration
initialize_robust_session <- function(
  max_session_time = 7200,
  data_preservation_interval = 30,
  keep_alive_interval = 10,
  enable_logging = TRUE
) {
  # Initialize session state
  .session_state$session_start_time <- Sys.time()
  .session_state$last_activity <- Sys.time()
  .session_state$max_session_time <- max_session_time
  .session_state$data_preservation_interval <- data_preservation_interval
  .session_state$keep_alive_interval <- keep_alive_interval
  .session_state$enable_logging <- enable_logging
  .session_state$termination_logged <- FALSE  # Prevent duplicate termination messages
  .session_state$observers_created <- FALSE   # Prevent duplicate observer creation
  
  # Create session log file
  session_id <- generate_session_id()
  .session_state$session_id <- session_id
  .session_state$log_file <- file.path(tempdir(), paste0("inrep_session_", session_id, ".log"))
  
  # Initialize logging
  if (enable_logging) {
    log_session_event("SESSION_INIT", "Robust session management initialized", 
                     list(max_time = max_session_time, 
                          data_interval = data_preservation_interval,
                          keep_alive_interval = keep_alive_interval))
  }
  
  # Start monitoring only if not already started
  if (!isTRUE(.session_state$observers_created)) {
    .session_state$observers_created <- TRUE
    
    # Start keep-alive monitoring
    start_keep_alive_monitoring()
    
    # Start data preservation monitoring
    start_data_preservation_monitoring()
  }
  
  return(list(
    session_id = session_id,
    start_time = .session_state$session_start_time,
    max_time = max_session_time,
    log_file = .session_state$log_file
  ))
}

#' Generate Unique Session ID
#' 
#' @return Character string with unique session identifier
generate_session_id <- function() {
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  random_suffix <- paste(sample(c(letters, 0:9), 8, replace = TRUE), collapse = "")
  paste0("SESS_", timestamp, "_", random_suffix)
}

#' Log Session Events
#' 
#' @param event_type Type of event (e.g., "SESSION_INIT", "DATA_SAVE", "ERROR")
#' @param message Event description
#' @param details Additional event details as list
log_session_event <- function(event_type, message, details = NULL) {
  if (!.session_state$enable_logging) return()
  
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  session_id <- .session_state$session_id
  
  log_entry <- list(
    timestamp = timestamp,
    session_id = session_id,
    event_type = event_type,
    message = message,
    details = details
  )
  
  # Write to log file
  tryCatch({
    # Ensure details is a list to avoid jsonlite warnings
    safe_details <- if (!is.null(details)) {
      if (is.vector(details) && !is.list(details)) {
        as.list(details)
      } else {
        details
      }
    } else {
      NULL
    }
    
    log_line <- paste0(
      "[", timestamp, "] ",
      event_type, ": ",
      message,
      if (!is.null(safe_details)) paste0(" | ", jsonlite::toJSON(safe_details, auto_unbox = TRUE)) else "",
      "\n"
    )
    if (!is.null(.session_state$log_file) && nchar(.session_state$log_file) > 0) {
      cat(log_line, file = .session_state$log_file, append = TRUE)
    }
  }, error = function(e) {
    # Fallback to console if file writing fails
    error_msg <- if (!is.null(e$message)) e$message else "Unknown error"
    message("Session logging failed: ", error_msg)
  })
  
  # Only log to console for critical events, not background operations
  # Disabled SESSION_TERMINATED to avoid spam
  if (event_type %in% c("SESSION_INIT", "ERROR")) {
    message(sprintf("[SESSION] %s: %s", event_type, message))
  }
}

#' Update Last Activity Time
#' 
update_activity <- function() {
  .session_state$last_activity <- Sys.time()
  # Only log activity to file, not console (reduces spam)
  if (.session_state$enable_logging) {
    log_session_event("ACTIVITY", "User activity detected")
  }
}

#' Check Session Validity
#' 
#' @return Logical indicating if session is still valid
is_session_valid <- function() {
  if (is.null(.session_state$session_start_time)) return(FALSE)
  
  elapsed_time <- as.numeric(difftime(Sys.time(), .session_state$session_start_time, units = "secs"))
  max_time <- .session_state$max_session_time
  
  if (elapsed_time > max_time) {
    # Log session expiration to file only for background operations
    if (.session_state$enable_logging) {
      log_session_event("SESSION_EXPIRED", "Session time limit exceeded", 
                       list(elapsed = elapsed_time, max = max_time))
    }
    return(FALSE)
  }
  
  return(TRUE)
}

#' Start Keep-Alive Monitoring
#' 
start_keep_alive_monitoring <- function() {
  if (.session_state$keep_alive_active) return()
  
  .session_state$keep_alive_active <- TRUE
  
  # Create keep-alive observer
  .session_state$keep_alive_observer <- shiny::observe({
    if (!.session_state$keep_alive_active) return()
    
    shiny::invalidateLater(.session_state$keep_alive_interval * 1000)
    
    # Check session validity
    if (!is_session_valid()) {
      # Only log termination once - DISABLED to prevent spam
      if (!isTRUE(.session_state$termination_logged)) {
        .session_state$termination_logged <- TRUE
        # Disabled to prevent repeated messages
        # if (.session_state$enable_logging) {
        #   log_session_event("SESSION_TERMINATED", "Session terminated due to time limit")
        # }
      }
      stop_keep_alive_monitoring()
      return()
    }
    
      # Log keep-alive ping (minimal console output)
  if (.session_state$enable_logging) {
    log_session_event("KEEP_ALIVE", "Keep-alive ping", 
                     list(elapsed_time = as.numeric(difftime(Sys.time(), .session_state$session_start_time, units = "secs"))))
  }
  })
  
  # Only log to file for background operations
  if (.session_state$enable_logging) {
    log_session_event("KEEP_ALIVE_STARTED", "Keep-alive monitoring activated")
  }
}

#' Stop Keep-Alive Monitoring
#' 
stop_keep_alive_monitoring <- function() {
  if (!.session_state$keep_alive_active) return()
  
  .session_state$keep_alive_active <- FALSE
  
  if (!is.null(.session_state$keep_alive_observer)) {
    .session_state$keep_alive_observer$destroy()
    .session_state$keep_alive_observer <- NULL
  }
  
  # Only log to file for background operations
  if (.session_state$enable_logging) {
    log_session_event("KEEP_ALIVE_STOPPED", "Keep-alive monitoring deactivated")
  }
}

#' Start Data Preservation Monitoring
#' 
start_data_preservation_monitoring <- function() {
  # Create data preservation observer
  .session_state$data_preservation_observer <- shiny::observe({
    shiny::invalidateLater(.session_state$data_preservation_interval * 1000)
    
    # Check if session is still valid
    if (!is_session_valid()) return()
    
    # Attempt to preserve current data
    preserve_session_data()
  })
  
  # Only log to file, not console for background operations
  if (.session_state$enable_logging) {
    log_session_event("DATA_PRESERVATION_STARTED", "Automatic data preservation activated")
  }
}

#' Preserve Session Data
#' 
#' @param force Whether to force preservation even if session is invalid
#' @return Logical indicating if preservation was successful
preserve_session_data <- function(force = FALSE) {
  if (!force && !is_session_valid()) {
    # Log data preservation skipped to file only for background operations
    if (.session_state$enable_logging) {
      log_session_event("DATA_PRESERVATION_SKIPPED", "Session invalid, skipping data preservation")
    }
    return(FALSE)
  }
  
  tryCatch({
    # Use the new robust data management system if available
    if (exists("add_session_data") && is.function(add_session_data)) {
      # Get current session data from reactive values
      session_data <- get_enhanced_session_data()
      
      if (!is.null(session_data) && length(session_data) > 0) {
        # Add to study dataframe
        add_session_data(
          session_data = session_data$session_info,
          responses = session_data$responses,
          demographics = session_data$demographics,
          custom_data = session_data$custom_data
        )
        
        # Log data preservation to file only (minimal console output)
        if (.session_state$enable_logging) {
          log_session_event("DATA_PRESERVED", "Session data preserved using enhanced system")
        }
        return(TRUE)
      }
    }
    
    # Fallback to original method
    session_data <- get_session_data()
    
    if (length(session_data) > 0) {
      # Save to temporary file
      temp_file <- file.path(tempdir(), paste0("inrep_data_", .session_state$session_id, ".rds"))
      saveRDS(session_data, temp_file)
      
      # Log data preservation to file only (minimal console output)
      if (.session_state$enable_logging) {
        log_session_event("DATA_PRESERVED", "Session data automatically preserved", 
                         list(file = temp_file, size = file.size(temp_file)))
      }
      return(TRUE)
    } else {
      # Log to file only for background operations
      if (.session_state$enable_logging) {
        log_session_event("DATA_PRESERVATION_EMPTY", "No session data to preserve")
      }
      return(FALSE)
    }
  }, error = function(e) {
    # Log errors to file only for background operations
    if (.session_state$enable_logging) {
      log_session_event("DATA_PRESERVATION_ERROR", "Failed to preserve session data", 
                       list(error = if (!is.null(e$message)) e$message else "Unknown error"))
    }
    return(FALSE)
  })
}

#' Get Current Session Data
#' 
#' @return List with current session data
get_session_data <- function() {
  # This function should be customized based on your data structure
  # For now, we'll collect common session elements
  
  session_data <- list()
  
  # Try to get reactive values if they exist
  if (exists("rv", envir = .GlobalEnv)) {
    tryCatch({
      rv <- get("rv", envir = .GlobalEnv)
      if (inherits(rv, "reactivevalues")) {
        session_data$reactive_values <- shiny::reactiveValuesToList(rv)
      }
    }, error = function(e) {
      # Log data collection errors to file only for background operations
      if (.session_state$enable_logging) {
        log_session_event("DATA_COLLECTION_ERROR", "Failed to collect reactive values", 
                         list(error = if (!is.null(e$message)) e$message else "Unknown error"))
      }
    })
  }
  
  # Try to get other common session objects
  common_objects <- c("config", "item_bank", "responses", "ability_estimates")
  for (obj_name in common_objects) {
    if (exists(obj_name, envir = .GlobalEnv)) {
      tryCatch({
        obj <- get(obj_name, envir = .GlobalEnv)
        session_data[[obj_name]] <- obj
      }, error = function(e) {
        # Log data collection errors to file only for background operations
        if (.session_state$enable_logging) {
          log_session_event("DATA_COLLECTION_ERROR", 
                           sprintf("Failed to collect %s", obj_name), 
                           list(error = if (!is.null(e$message)) e$message else "Unknown error"))
        }
      })
    }
  }
  
  # Add session metadata
  session_data$session_metadata <- list(
    session_id = .session_state$session_id,
    start_time = .session_state$session_start_time,
    last_activity = .session_state$last_activity,
    max_time = .session_state$max_session_time
  )
  
  return(session_data)
}

#' Get Enhanced Session Data
#' 
#' @return List with enhanced session data for dataframe system
get_enhanced_session_data <- function() {
  session_data <- list()
  
  tryCatch({
    # Get reactive values if they exist
    if (exists("rv", envir = .GlobalEnv)) {
      rv <- get("rv", envir = .GlobalEnv)
      if (inherits(rv, "reactivevalues")) {
        rv_list <- shiny::reactiveValuesToList(rv)
        
        # Extract session information
        session_data$session_info <- list(
          session_id = .session_state$session_id,
          participant_id = rv_list$participant_id %||% "unknown",
          start_time = .session_state$session_start_time,
          end_time = Sys.time(),
          completion_status = rv_list$completion_status %||% "incomplete",
          total_items = length(rv_list$responses %||% c()),
          administered_items = sum(!is.na(rv_list$responses %||% c())),
          final_ability = rv_list$current_ability %||% NA_real_,
          final_se = rv_list$current_se %||% NA_real_,
          study_type = if (!is.null(rv_list$custom_page_flow)) "custom" else "adaptive",
          language = rv_list$language %||% "en",
          device_info = rv_list$device_info %||% "unknown",
          browser_info = rv_list$browser_info %||% "unknown"
        )
        
        # Extract responses
        session_data$responses <- rv_list$responses %||% c()
        
        # Extract demographics
        session_data$demographics <- rv_list$demographics %||% rv_list$demo_data %||% list()
        
        # Extract custom page data
        if (!is.null(rv_list$custom_page_flow)) {
          session_data$custom_data <- list(
            pages_completed = rv_list$current_page %||% 0,
            instruction_pages = rv_list$instruction_pages_viewed %||% 0,
            demo_pages = rv_list$demo_pages_viewed %||% 0,
            page_times = rv_list$page_times %||% list()
          )
        }
      }
    }
    
    # Get config and item bank if available
    if (exists("config", envir = .GlobalEnv)) {
      config <- get("config", envir = .GlobalEnv)
      session_data$config <- config
    }
    
    if (exists("item_bank", envir = .GlobalEnv)) {
      item_bank <- get("item_bank", envir = .GlobalEnv)
      session_data$item_bank <- item_bank
    }
    
  }, error = function(e) {
    # Log data collection errors
    if (.session_state$enable_logging) {
      log_session_event("ENHANCED_DATA_COLLECTION_ERROR", "Failed to collect enhanced session data", 
                       list(error = if (!is.null(e$message)) e$message else "Unknown error"))
    }
  })
  
  return(session_data)
}

#' Emergency Data Recovery
#' 
#' Attempts to recover data from the most recent preservation point
#' 
#' @return List with recovered data or NULL if recovery failed
emergency_data_recovery <- function() {
  tryCatch({
    # Look for preserved data files
    temp_dir <- tempdir()
    pattern <- paste0("inrep_data_", .session_state$session_id, ".*\\.rds$")
    data_files <- list.files(temp_dir, pattern = pattern, full.names = TRUE)
    
    if (length(data_files) == 0) {
      # Log recovery failures to file only for background operations
      if (.session_state$enable_logging) {
        log_session_event("RECOVERY_FAILED", "No preserved data files found")
      }
      return(NULL)
    }
    
    # Get the most recent file
    file_info <- file.info(data_files)
    most_recent <- data_files[which.max(file_info$mtime)]
    
    # Load the data
    recovered_data <- readRDS(most_recent)
    
    # Log recovery success to file only for background operations
    if (.session_state$enable_logging) {
      log_session_event("RECOVERY_SUCCESS", "Data recovered from emergency preservation", 
                       list(file = most_recent, size = file.size(most_recent)))
    }
    
    return(recovered_data)
  }, error = function(e) {
    # Log recovery errors to file only for background operations
    if (.session_state$enable_logging) {
      log_session_event("RECOVERY_ERROR", "Emergency data recovery failed", 
                       list(error = if (!is.null(e$message)) e$message else "Unknown error"))
    }
    return(NULL)
  })
}

#' Clean Up Session
#' 
#' @param save_final_data Whether to save final data before cleanup
cleanup_session <- function(save_final_data = TRUE) {
  # Log cleanup to file only for background operations
  if (.session_state$enable_logging) {
    log_session_event("SESSION_CLEANUP", "Starting session cleanup")
  }
  
  # Save final data if requested
  if (save_final_data) {
    preserve_session_data(force = TRUE)
  }
  
  # Stop monitoring
  stop_keep_alive_monitoring()
  
  # Clean up observers
  if (!is.null(.session_state$data_preservation_observer)) {
    .session_state$data_preservation_observer$destroy()
    .session_state$data_preservation_observer <- NULL
  }
  
  # Clear session state
  .session_state$keep_alive_active <- FALSE
  .session_state$session_start_time <- NULL
  .session_state$last_activity <- NULL
  
  # Log cleanup completion to file only for background operations
  if (.session_state$enable_logging) {
    log_session_event("SESSION_CLEANUP_COMPLETE", "Session cleanup completed")
  }
}

#' Get Session Status
#' 
#' @return List with current session status
get_session_status <- function() {
  if (is.null(.session_state$session_start_time)) {
    return(list(active = FALSE, message = "No active session"))
  }
  
  elapsed_time <- as.numeric(difftime(Sys.time(), .session_state$session_start_time, units = "secs"))
  max_time <- .session_state$max_session_time
  remaining_time <- max(0, max_time - elapsed_time)
  
  return(list(
    active = TRUE,
    session_id = .session_state$session_id,
    start_time = .session_state$session_start_time,
    elapsed_time = elapsed_time,
    remaining_time = remaining_time,
    max_time = max_time,
    keep_alive_active = .session_state$keep_alive_active,
    log_file = .session_state$log_file
  ))
}

#' Force Session Extension
#' 
#' @param additional_time Additional time in seconds
#' @return Logical indicating if extension was successful
extend_session <- function(additional_time) {
  if (is.null(.session_state$max_session_time)) {
    # Log extension failure to file only for background operations
    if (.session_state$enable_logging) {
      log_session_event("EXTENSION_FAILED", "No active session to extend")
    }
    return(FALSE)
  }
  
  .session_state$max_session_time <- .session_state$max_session_time + additional_time
  
  # Log session extension to file only for background operations
  if (.session_state$enable_logging) {
    log_session_event("SESSION_EXTENDED", "Session time extended", 
                     list(additional_time = additional_time, 
                          new_max_time = .session_state$max_session_time))
  }
  
  return(TRUE)
}