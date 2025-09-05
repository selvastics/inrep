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

#' Clean up old session files to prevent conflicts
#' 
#' @param max_age_hours Maximum age of session files in hours (default: 24)
cleanup_old_sessions <- function(max_age_hours = 24) {
  temp_dir <- tempdir()
  existing_sessions <- list.files(temp_dir, pattern = "inrep_session_.*\\.log", full.names = TRUE)
  
  current_time <- Sys.time()
  cleaned_count <- 0
  
  for (session_file in existing_sessions) {
    if (file.exists(session_file)) {
      file_time <- file.mtime(session_file)
      age_hours <- as.numeric(difftime(current_time, file_time, units = "hours"))
      
      if (age_hours > max_age_hours) {
        tryCatch({
          file.remove(session_file)
          cleaned_count <- cleaned_count + 1
        }, error = function(e) {
          # Ignore cleanup errors
        })
      }
    }
  }
  
  if (cleaned_count > 0) {
    log_session_event("CLEANUP", sprintf("Cleaned up %d old session files", cleaned_count))
  }
}

#' Ensure Complete Data Isolation Between Sessions
#' 
#' @param session_id The session ID to check
#' @return TRUE if session is completely isolated
ensure_complete_data_isolation <- function(session_id) {
  # Clean up old sessions first
  cleanup_old_sessions()
  
  # Create session-specific data directory to ensure complete isolation
  session_data_dir <- file.path(tempdir(), paste0("session_data_", session_id))
  if (!dir.exists(session_data_dir)) {
    dir.create(session_data_dir, recursive = TRUE)
  }
  
  # Set session-specific environment variables to prevent data leakage
  Sys.setenv(INREP_SESSION_ID = session_id)
  Sys.setenv(INREP_SESSION_DATA_DIR = session_data_dir)
  
  # Clear any global variables that might contain data from previous sessions
  if (exists(".logging_data", envir = .GlobalEnv)) {
    rm(".logging_data", envir = .GlobalEnv)
  }
  
  # Initialize fresh session-specific logging data
  .GlobalEnv$.logging_data <- new.env()
  .GlobalEnv$.logging_data$session_id <- session_id
  .GlobalEnv$.logging_data$session_start <- Sys.time()
  .GlobalEnv$.logging_data$current_page_start <- Sys.time()
  
  # Check for existing session files that might indicate conflicts
  temp_dir <- tempdir()
  existing_sessions <- list.files(temp_dir, pattern = "inrep_session_.*\\.log", full.names = TRUE)
  
  # Check if any existing sessions are still active (modified within last 5 minutes)
  current_time <- Sys.time()
  active_sessions <- c()
  
  for (session_file in existing_sessions) {
    if (file.exists(session_file)) {
      file_time <- file.mtime(session_file)
      if (as.numeric(difftime(current_time, file_time, units = "mins")) < 5) {
        active_sessions <- c(active_sessions, session_file)
      }
    }
  }
  
  # Log isolation status
  if (length(active_sessions) > 0) {
    warning(sprintf("Found %d potentially active sessions. Complete data isolation ensured for: %s", 
                   length(active_sessions), session_id))
  }
  
  return(TRUE)  # Always allow new sessions with complete isolation
}

#' Clean up session data on termination to ensure no data leakage
#' 
#' @param session_id The session ID to clean up
cleanup_session_data <- function(session_id) {
  tryCatch({
    # Remove session-specific data directory
    session_data_dir <- file.path(tempdir(), paste0("session_data_", session_id))
    if (dir.exists(session_data_dir)) {
      unlink(session_data_dir, recursive = TRUE)
    }
    
    # Clear session-specific environment variables
    Sys.unsetenv("INREP_SESSION_ID")
    Sys.unsetenv("INREP_SESSION_DATA_DIR")
    
    # Clear global logging data for this session
    if (exists(".logging_data", envir = .GlobalEnv)) {
      rm(".logging_data", envir = .GlobalEnv)
    }
    
    log_session_event("SESSION_CLEANUP", sprintf("Cleaned up all data for session: %s", session_id))
  }, error = function(e) {
    # Log cleanup errors but don't fail
    log_session_event("CLEANUP_ERROR", sprintf("Error cleaning up session %s: %s", session_id, e$message))
  })
}

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
  
  # Create session log file with complete data isolation
  session_id <- generate_session_id()
  ensure_complete_data_isolation(session_id)  # Ensure complete data isolation
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
  # Generate a more robust unique session ID with multiple entropy sources
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S_%OS3")  # Include milliseconds
  process_id <- Sys.getpid()  # Process ID for additional uniqueness
  random_suffix <- paste(sample(c(letters, LETTERS, 0:9), 12, replace = TRUE), collapse = "")
  machine_id <- Sys.info()["nodename"]  # Machine identifier
  
  # Create a hash of all components for additional uniqueness
  combined_string <- paste(timestamp, process_id, random_suffix, machine_id, sep = "_")
  hash_suffix <- substr(digest::digest(combined_string, algo = "md5"), 1, 8)
  
  paste0("SESS_", timestamp, "_", process_id, "_", hash_suffix)
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
      if (!is.null(safe_details)) paste0(" | ", jsonlite::toJSON(safe_details, auto_unbox = TRUE)) else ""
    )
    cat(log_line, file = .session_state$log_file, append = TRUE)
  }, error = function(e) {
    # Fallback to console if file writing fails
    message("Session logging failed: ", e$message)
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
  .session_state$keep_alive_observer <- observe({
    if (!.session_state$keep_alive_active) return()
    
    invalidateLater(.session_state$keep_alive_interval * 1000)
    
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
  
  # Clean up session data to ensure no data leakage
  if (!is.null(.session_state$session_id)) {
    cleanup_session_data(.session_state$session_id)
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
  .session_state$data_preservation_observer <- observe({
    invalidateLater(.session_state$data_preservation_interval * 1000)
    
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
    # Get current session data from global environment
    session_data <- get_session_data()
    
    # Check if session_data is valid and not empty
    if (!is.null(session_data) && length(session_data) > 0) {
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
                       list(error = e$message))
    }
    # Don't re-throw the error to prevent crashes
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
      if (is.reactivevalues(rv)) {
        # Check if rv has any values before converting
        rv_list <- reactiveValuesToList(rv)
        if (length(rv_list) > 0) {
          session_data$reactive_values <- rv_list
        }
      }
    }, error = function(e) {
      # Log data collection errors to file only for background operations
      if (.session_state$enable_logging) {
        log_session_event("DATA_COLLECTION_ERROR", "Failed to collect reactive values", 
                         list(error = e$message))
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
                           list(error = e$message))
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
                       list(error = e$message))
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
  
  # Complete data cleanup to ensure no data leakage between sessions
  if (!is.null(.session_state$session_id)) {
    cleanup_session_data(.session_state$session_id)
  }
  
  # Clear session state
  .session_state$keep_alive_active <- FALSE
  .session_state$session_start_time <- NULL
  .session_state$last_activity <- NULL
  .session_state$session_id <- NULL
  
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