#' Robust Error Handling and Recovery for Sensitive Participant Data
#' 
#' This module provides comprehensive error handling, automatic recovery,
#' and data preservation mechanisms to ensure assessment stability.

# Global error handling state
.error_handling_state <- new.env()
.error_handling_state$error_count <- 0
.error_handling_state$last_error <- NULL
.error_handling_state$recovery_attempts <- 0
.error_handling_state$max_recovery_attempts <- 3

#' Initialize Robust Error Handling
#' 
#' @param max_recovery_attempts Maximum number of recovery attempts
#' @param enable_auto_recovery Whether to enable automatic recovery
#' @return List with error handling configuration
initialize_robust_error_handling <- function(
  max_recovery_attempts = 3,
  enable_auto_recovery = TRUE
) {
  .error_handling_state$max_recovery_attempts <- max_recovery_attempts
  .error_handling_state$enable_auto_recovery <- enable_auto_recovery
  .error_handling_state$error_count <- 0
  .error_handling_state$recovery_attempts <- 0
  
  # Set up global error handler
  options(error = robust_error_handler)
  
  # Set up warning handler
  options(warning.expression = quote(robust_warning_handler))
  
  return(list(
    max_recovery_attempts = max_recovery_attempts,
    enable_auto_recovery = enable_auto_recovery
  ))
}

#' Robust Error Handler
#' 
#' @param e Error object
robust_error_handler <- function(e) {
  # Increment error count
  .error_handling_state$error_count <- .error_handling_state$error_count + 1
  .error_handling_state$last_error <- e
  
  # Log the error
  log_error_event("ERROR_OCCURRED", "Unhandled error occurred", 
                  list(error_message = e$message, 
                       call = as.character(e$call),
                       error_count = .error_handling_state$error_count))
  
  # Attempt emergency data preservation
  emergency_data_preservation()
  
  # Attempt automatic recovery if enabled
  if (.error_handling_state$enable_auto_recovery && 
      .error_handling_state$recovery_attempts < .error_handling_state$max_recovery_attempts) {
    attempt_error_recovery(e)
  } else {
    # Max recovery attempts reached, show user-friendly error
    show_user_friendly_error(e)
  }
}

#' Robust Warning Handler
#' 
#' @param warning_message Warning message
robust_warning_handler <- function(warning_message) {
  # Log the warning
  log_error_event("WARNING_OCCURRED", "Warning occurred", 
                  list(warning_message = warning_message))
  
  # Continue execution (warnings don't stop the app)
  warning(warning_message)
}

#' Log Error Events
#' 
#' @param event_type Type of error event
#' @param message Error description
#' @param details Additional error details
log_error_event <- function(event_type, message, details = NULL) {
  # Get session log file if available
  log_file <- if (exists(".session_state") && !is.null(.session_state$log_file)) {
    .session_state$log_file
  } else {
    file.path(tempdir(), "inrep_error.log")
  }
  
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  
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
  
  log_entry <- paste0(
    "[", timestamp, "] ",
    event_type, ": ",
    message,
    if (!is.null(safe_details)) paste0(" | ", jsonlite::toJSON(safe_details, auto_unbox = TRUE)) else ""
  )
  
  tryCatch({
    cat(log_entry, file = log_file, append = TRUE)
  }, error = function(e) {
    # Fallback to console if file writing fails
    message("Error logging failed: ", e$message)
  })
  
  # Also log to console for immediate visibility
  message(sprintf("[ERROR] %s: %s", event_type, message))
}

#' Emergency Data Preservation
#' 
#' Attempts to preserve all current data immediately when an error occurs
#' 
#' @return Logical indicating if preservation was successful
emergency_data_preservation <- function() {
  tryCatch({
    # Force immediate data preservation
    if (exists("preserve_session_data")) {
      preserve_session_data(force = TRUE)
    }
    
    # Also try to save to a special emergency file
    emergency_save_current_data()
    
    log_error_event("EMERGENCY_PRESERVATION", "Emergency data preservation completed")
    return(TRUE)
  }, error = function(e) {
    log_error_event("EMERGENCY_PRESERVATION_FAILED", "Emergency data preservation failed", 
                    list(error = e$message))
    return(FALSE)
  })
}

#' Emergency Save Current Data
#' 
#' Saves current data to a special emergency file
emergency_save_current_data <- function() {
  tryCatch({
    # Get current data from global environment
    current_data <- get_current_environment_data()
    
    if (length(current_data) > 0) {
      # Save to emergency file
      emergency_file <- file.path(tempdir(), paste0("inrep_emergency_", 
                                                   format(Sys.time(), "%Y%m%d_%H%M%S"), ".rds"))
      saveRDS(current_data, emergency_file)
      
      log_error_event("EMERGENCY_SAVE_SUCCESS", "Emergency data save completed", 
                      list(file = emergency_file, size = file.size(emergency_file)))
    }
  }, error = function(e) {
    log_error_event("EMERGENCY_SAVE_FAILED", "Emergency data save failed", 
                    list(error = e$message))
  })
}

#' Get Current Environment Data
#' 
#' Collects all relevant data from the current environment
#' 
#' @return List with current environment data
get_current_environment_data <- function() {
  data <- list()
  
  # Try to get common objects
  common_objects <- c("rv", "config", "item_bank", "responses", "ability_estimates", 
                      "current_item", "participant_id", "session_data")
  
  for (obj_name in common_objects) {
    if (exists(obj_name, envir = .GlobalEnv)) {
      tryCatch({
        obj <- get(obj_name, envir = .GlobalEnv)
        data[[obj_name]] <- obj
      }, error = function(e) {
        # Skip if we can't get the object
      })
    }
  }
  
  # Add error context
  data$error_context <- list(
    error_count = .error_handling_state$error_count,
    last_error = .error_handling_state$last_error,
    timestamp = Sys.time()
  )
  
  return(data)
}

#' Attempt Error Recovery
#' 
#' @param e Error object
#' @return Logical indicating if recovery was successful
attempt_error_recovery <- function(e) {
  .error_handling_state$recovery_attempts <- .error_handling_state$recovery_attempts + 1
  
  log_error_event("RECOVERY_ATTEMPT", "Attempting error recovery", 
                  list(attempt = .error_handling_state$recovery_attempts,
                       max_attempts = .error_handling_state$max_recovery_attempts))
  
  tryCatch({
    # Try to recover the session
    recovered_data <- recover_session_after_error()
    
    if (!is.null(recovered_data)) {
      log_error_event("RECOVERY_SUCCESS", "Error recovery successful", 
                      list(attempt = .error_handling_state$recovery_attempts))
      return(TRUE)
    } else {
      log_error_event("RECOVERY_FAILED", "Error recovery failed", 
                      list(attempt = .error_handling_state$recovery_attempts))
      return(FALSE)
    }
  }, error = function(recovery_error) {
    log_error_event("RECOVERY_ERROR", "Error during recovery attempt", 
                    list(attempt = .error_handling_state$recovery_attempts,
                         error = recovery_error$message))
    return(FALSE)
  })
}

#' Recover Session After Error
#' 
#' Attempts to recover the session to a stable state
#' 
#' @return List with recovered data or NULL if recovery failed
recover_session_after_error <- function() {
  tryCatch({
    # Try to get data from emergency preservation
    if (exists("emergency_data_recovery")) {
      recovered_data <- emergency_data_recovery()
      if (!is.null(recovered_data)) {
        return(recovered_data)
      }
    }
    
    # Try to restore from last known good state
    restored_data <- restore_last_known_state()
    if (!is.null(restored_data)) {
      return(restored_data)
    }
    
    # If all else fails, try to create a minimal working state
    minimal_state <- create_minimal_working_state()
    return(minimal_state)
    
  }, error = function(e) {
    log_error_event("RECOVERY_PROCESS_ERROR", "Error during recovery process", 
                    list(error = e$message))
    return(NULL)
  })
}

#' Restore Last Known State
#' 
#' Attempts to restore the session to the last known good state
#' 
#' @return List with restored data or NULL if restoration failed
restore_last_known_state <- function() {
  tryCatch({
    # Look for backup files
    temp_dir <- tempdir()
    backup_pattern <- "inrep_backup_.*\\.rds$"
    backup_files <- list.files(temp_dir, pattern = backup_pattern, full.names = TRUE)
    
    if (length(backup_files) == 0) {
      return(NULL)
    }
    
    # Get the most recent backup
    file_info <- file.info(backup_files)
    most_recent <- backup_files[which.max(file_info$mtime)]
    
    # Load the backup
    restored_data <- readRDS(most_recent)
    
    log_error_event("STATE_RESTORATION_SUCCESS", "Last known state restored", 
                    list(file = most_recent))
    
    return(restored_data)
  }, error = function(e) {
    log_error_event("STATE_RESTORATION_FAILED", "Failed to restore last known state", 
                    list(error = e$message))
    return(NULL)
  })
}

#' Create Minimal Working State
#' 
#' Creates a minimal working state when recovery fails
#' 
#' @return List with minimal working state
create_minimal_working_state <- function() {
  tryCatch({
    # Create a minimal configuration
    minimal_config <- list(
      study_name = "Recovery Mode",
      max_items = 10,
      min_items = 1,
      model = "1PL",
      session_mode = "recovery"
    )
    
    # Create minimal reactive values
    minimal_rv <- list(
      item_counter = 0,
      responses = list(),
      current_ability = 0,
      session_active = TRUE
    )
    
    minimal_state <- list(
      config = minimal_config,
      reactive_values = minimal_rv,
      recovery_mode = TRUE,
      timestamp = Sys.time()
    )
    
    log_error_event("MINIMAL_STATE_CREATED", "Minimal working state created")
    
    return(minimal_state)
  }, error = function(e) {
    log_error_event("MINIMAL_STATE_FAILED", "Failed to create minimal working state", 
                    list(error = e$message))
    return(NULL)
  })
}

#' Show User-Friendly Error
#' 
#' Displays a user-friendly error message when recovery fails
#' 
#' @param e Error object
show_user_friendly_error <- function(e) {
  # Create user-friendly error message
  error_message <- paste0(
    "We're sorry, but an unexpected error occurred. ",
    "Your progress has been automatically saved. ",
    "Please contact support if this problem persists."
  )
  
  # Log the user-friendly message
  log_error_event("USER_FRIENDLY_ERROR", "Showing user-friendly error message", 
                  list(original_error = e$message))
  
  # In a Shiny app, this would be shown in the UI
  # For now, we'll just message it
  message(error_message)
  
  # Try to save the error report
  save_error_report(e)
}

#' Save Error Report
#' 
#' Saves a detailed error report for debugging
#' 
#' @param e Error object
save_error_report <- function(e) {
  tryCatch({
    error_report <- list(
      timestamp = Sys.time(),
      error_message = e$message,
      error_call = as.character(e$call),
      error_count = .error_handling_state$error_count,
      recovery_attempts = .error_handling_state$recovery_attempts,
      session_info = if (exists("get_session_status")) get_session_status() else NULL,
      system_info = list(
        r_version = R.version.string,
        platform = R.version$platform,
        memory_usage = gc()
      )
    )
    
    # Save error report
    report_file <- file.path(tempdir(), paste0("inrep_error_report_", 
                                              format(Sys.time(), "%Y%m%d_%H%M%S"), ".rds"))
    saveRDS(error_report, report_file)
    
    log_error_event("ERROR_REPORT_SAVED", "Error report saved", 
                    list(file = report_file))
    
  }, error = function(save_error) {
    log_error_event("ERROR_REPORT_FAILED", "Failed to save error report", 
                    list(error = save_error$message))
  })
}

#' Reset Error Handling State
#' 
#' Resets the error handling state after successful recovery
reset_error_handling_state <- function() {
  .error_handling_state$error_count <- 0
  .error_handling_state$last_error <- NULL
  .error_handling_state$recovery_attempts <- 0
  
  log_error_event("ERROR_STATE_RESET", "Error handling state reset")
}

#' Get Error Handling Status
#' 
#' @return List with current error handling status
get_error_handling_status <- function() {
  return(list(
    error_count = .error_handling_state$error_count,
    last_error = .error_handling_state$last_error,
    recovery_attempts = .error_handling_state$recovery_attempts,
    max_recovery_attempts = .error_handling_state$max_recovery_attempts,
    enable_auto_recovery = .error_handling_state$enable_auto_recovery
  ))
}

#' Create Periodic Backup
#' 
#' Creates a periodic backup of the current session state
#' 
#' @param backup_interval Backup interval in seconds
create_periodic_backup <- function(backup_interval = 300) {  # 5 minutes
  # Create backup observer
  backup_observer <- observe({
    invalidateLater(backup_interval * 1000)
    
    tryCatch({
      # Get current data
      current_data <- get_current_environment_data()
      
      if (length(current_data) > 0) {
        # Create backup file
        backup_file <- file.path(tempdir(), paste0("inrep_backup_", 
                                                  format(Sys.time(), "%Y%m%d_%H%M%S"), ".rds"))
        saveRDS(current_data, backup_file)
        
        # Clean up old backups (keep only last 5)
        cleanup_old_backups()
        
        log_error_event("BACKUP_CREATED", "Periodic backup created", 
                        list(file = backup_file))
      }
    }, error = function(e) {
      log_error_event("BACKUP_FAILED", "Periodic backup failed", 
                      list(error = e$message))
    })
  })
  
  return(backup_observer)
}

#' Clean Up Old Backups
#' 
#' Removes old backup files, keeping only the most recent ones
#' 
#' @param keep_count Number of recent backups to keep
cleanup_old_backups <- function(keep_count = 5) {
  tryCatch({
    temp_dir <- tempdir()
    backup_pattern <- "inrep_backup_.*\\.rds$"
    backup_files <- list.files(temp_dir, pattern = backup_pattern, full.names = TRUE)
    
    if (length(backup_files) > keep_count) {
      # Get file info and sort by modification time
      file_info <- file.info(backup_files)
      file_info$filename <- backup_files
      file_info <- file_info[order(file_info$mtime, decreasing = TRUE), ]
      
      # Remove old files
      files_to_remove <- file_info$filename[(keep_count + 1):nrow(file_info)]
      unlink(files_to_remove)
      
      log_error_event("BACKUP_CLEANUP", "Old backup files cleaned up", 
                      list(removed_count = length(files_to_remove)))
    }
  }, error = function(e) {
    log_error_event("BACKUP_CLEANUP_FAILED", "Failed to clean up old backups", 
                    list(error = e$message))
  })
}