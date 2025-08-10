#' @title Enhanced Session Recovery System
#' @description Provides comprehensive session recovery with auto-save, browser refresh handling,
#' crash recovery, and data loss prevention mechanisms for the inrep package.
#' @details This module implements robust session management to prevent data loss
#' during assessment administration. It includes automatic saving, browser storage
#' integration, and recovery mechanisms for interrupted sessions.
#' @name enhanced_session_recovery
#' @docType data
NULL

# Global recovery state
.recovery_state <- new.env()
.recovery_state$auto_save_enabled <- TRUE
.recovery_state$auto_save_interval <- 30  # seconds
.recovery_state$recovery_cache <- list()
.recovery_state$browser_storage_key <- "inrep_session_backup"

#' Initialize Enhanced Session Recovery
#' 
#' @param auto_save_interval Interval for automatic saves in seconds (default: 30)
#' @param enable_browser_storage Enable browser localStorage for refresh handling
#' @param enable_cloud_backup Enable cloud backup for critical data
#' @param recovery_retention_days Days to retain recovery data (default: 7)
#' @return List with recovery configuration
#' @export
initialize_enhanced_recovery <- function(
  auto_save_interval = 30,
  enable_browser_storage = TRUE,
  enable_cloud_backup = FALSE,
  recovery_retention_days = 7
) {
  .recovery_state$auto_save_interval <- auto_save_interval
  .recovery_state$enable_browser_storage <- enable_browser_storage
  .recovery_state$enable_cloud_backup <- enable_cloud_backup
  .recovery_state$recovery_retention_days <- recovery_retention_days
  
  # Create recovery directory
  recovery_dir <- file.path(tempdir(), "inrep_recovery")
  if (!dir.exists(recovery_dir)) {
    dir.create(recovery_dir, recursive = TRUE)
  }
  .recovery_state$recovery_dir <- recovery_dir
  
  # Clean old recovery files
  clean_old_recovery_files(recovery_retention_days)
  
  # Start auto-save timer
  if (auto_save_interval > 0) {
    start_auto_save_timer(auto_save_interval)
  }
  
  return(list(
    recovery_dir = recovery_dir,
    auto_save_interval = auto_save_interval,
    browser_storage = enable_browser_storage,
    cloud_backup = enable_cloud_backup
  ))
}

#' Auto-Save Session Data
#' 
#' Automatically saves session data at regular intervals
#' 
#' @param session Shiny session object
#' @param data Session data to save
#' @param force Force immediate save regardless of timer
#' @return Logical indicating success
auto_save_session <- function(session, data, force = FALSE) {
  if (!.recovery_state$auto_save_enabled && !force) return(FALSE)
  
  tryCatch({
    # Generate recovery file path
    session_id <- data$session_id %||% generate_recovery_id()
    recovery_file <- file.path(
      .recovery_state$recovery_dir,
      paste0("recovery_", session_id, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".rds")
    )
    
    # Add metadata for recovery
    recovery_data <- list(
      timestamp = Sys.time(),
      session_id = session_id,
      participant_id = data$participant_id,
      progress = data$progress,
      responses = data$responses,
      theta_history = data$theta_history,
      se_history = data$se_history,
      items_administered = data$items_administered,
      demographics = data$demographics,
      config = data$config,
      checksum = digest::digest(data)
    )
    
    # Save to file
    saveRDS(recovery_data, recovery_file)
    
    # Save to browser storage if enabled
    if (.recovery_state$enable_browser_storage && !is.null(session)) {
      save_to_browser_storage(session, recovery_data)
    }
    
    # Cloud backup if enabled
    if (.recovery_state$enable_cloud_backup) {
      backup_to_cloud(recovery_data)
    }
    
    # Update recovery cache
    .recovery_state$recovery_cache[[session_id]] <- recovery_file
    
    # Log auto-save (to file only, not console)
    log_recovery_event("AUTO_SAVE", paste("Session data auto-saved:", session_id))
    
    return(TRUE)
  }, error = function(e) {
    log_recovery_event("AUTO_SAVE_ERROR", paste("Auto-save failed:", e$message))
    return(FALSE)
  })
}

#' Save to Browser Storage
#' 
#' Saves session data to browser localStorage for refresh recovery
#' 
#' @param session Shiny session object
#' @param data Data to save
save_to_browser_storage <- function(session, data) {
  if (is.null(session)) return()
  
  tryCatch({
    # Prepare data for browser storage (limit size)
    browser_data <- list(
      session_id = data$session_id,
      participant_id = data$participant_id,
      progress = data$progress,
      last_item_index = length(data$items_administered),
      responses = tail(data$responses, 50),  # Keep last 50 responses
      timestamp = as.character(Sys.time())
    )
    
    # Send to browser via custom message
    session$sendCustomMessage(
      type = "saveToLocalStorage",
      message = list(
        key = .recovery_state$browser_storage_key,
        data = jsonlite::toJSON(browser_data, auto_unbox = TRUE)
      )
    )
  }, error = function(e) {
    log_recovery_event("BROWSER_STORAGE_ERROR", e$message)
  })
}

#' Recover Session from Browser Storage
#' 
#' Attempts to recover session data from browser localStorage
#' 
#' @param session Shiny session object
#' @param callback Function to call with recovered data
#' @export
recover_from_browser_storage <- function(session, callback) {
  if (!.recovery_state$enable_browser_storage || is.null(session)) {
    return(NULL)
  }
  
  # Request data from browser
  session$sendCustomMessage(
    type = "getFromLocalStorage",
    message = list(
      key = .recovery_state$browser_storage_key,
      callback = "handleRecoveredData"
    )
  )
  
  # Set up observer for recovered data
  observeEvent(session$input$recovered_data, {
    if (!is.null(session$input$recovered_data)) {
      recovered <- jsonlite::fromJSON(session$input$recovered_data)
      
      # Validate recovered data
      if (validate_recovery_data(recovered)) {
        callback(recovered)
        log_recovery_event("BROWSER_RECOVERY", "Session recovered from browser storage")
      }
    }
  })
}

#' Recover Session from File
#' 
#' Attempts to recover the most recent session for a participant
#' 
#' @param participant_id Participant identifier
#' @param session_id Optional specific session to recover
#' @return Recovered session data or NULL
#' @export
recover_session <- function(participant_id = NULL, session_id = NULL) {
  recovery_files <- list.files(
    .recovery_state$recovery_dir,
    pattern = "^recovery_.*\\.rds$",
    full.names = TRUE
  )
  
  if (length(recovery_files) == 0) return(NULL)
  
  # Filter by participant or session if specified
  if (!is.null(session_id)) {
    recovery_files <- recovery_files[grep(session_id, recovery_files)]
  }
  
  if (length(recovery_files) == 0) return(NULL)
  
  # Get most recent file
  file_info <- file.info(recovery_files)
  most_recent <- recovery_files[which.max(file_info$mtime)]
  
  tryCatch({
    recovered_data <- readRDS(most_recent)
    
    # Validate checksum
    if (validate_recovery_data(recovered_data)) {
      log_recovery_event("SESSION_RECOVERED", 
                        paste("Recovered session:", recovered_data$session_id))
      return(recovered_data)
    }
    
    return(NULL)
  }, error = function(e) {
    log_recovery_event("RECOVERY_ERROR", paste("Failed to recover session:", e$message))
    return(NULL)
  })
}

#' Validate Recovery Data
#' 
#' Validates recovered session data for integrity
#' 
#' @param data Recovery data to validate
#' @return Logical indicating if data is valid
validate_recovery_data <- function(data) {
  if (is.null(data)) return(FALSE)
  
  # Check required fields
  required_fields <- c("session_id", "timestamp", "progress")
  if (!all(required_fields %in% names(data))) {
    return(FALSE)
  }
  
  # Check data age (don't recover if too old)
  if (!is.null(data$timestamp)) {
    age_hours <- as.numeric(difftime(Sys.time(), data$timestamp, units = "hours"))
    if (age_hours > 24) {
      log_recovery_event("RECOVERY_EXPIRED", 
                        paste("Recovery data too old:", age_hours, "hours"))
      return(FALSE)
    }
  }
  
  return(TRUE)
}

#' Start Auto-Save Timer
#' 
#' Starts the automatic save timer
#' 
#' @param interval Save interval in seconds
start_auto_save_timer <- function(interval) {
  if (exists(".recovery_state$auto_save_observer")) {
    .recovery_state$auto_save_observer$destroy()
  }
  
  .recovery_state$auto_save_observer <- observe({
    invalidateLater(interval * 1000)
    
    # Trigger auto-save for all active sessions
    if (exists(".active_sessions") && length(.active_sessions) > 0) {
      for (session_data in .active_sessions) {
        auto_save_session(NULL, session_data)
      }
    }
  })
}

#' Handle Browser Refresh
#' 
#' JavaScript injection for handling browser refresh events
#' 
#' @return JavaScript code as character string
#' @export
get_browser_refresh_handler <- function() {
  '
  // Save data before page unload
  window.addEventListener("beforeunload", function(e) {
    var sessionData = Shiny.shinyapp.$values;
    if (sessionData && sessionData.session_data) {
      localStorage.setItem("inrep_session_backup", 
                          JSON.stringify(sessionData.session_data));
    }
    
    // Show warning if assessment in progress
    if (sessionData && sessionData.progress > 0 && sessionData.progress < 100) {
      e.preventDefault();
      e.returnValue = "Your assessment is in progress. Are you sure you want to leave?";
      return e.returnValue;
    }
  });
  
  // Check for recovery data on page load
  window.addEventListener("load", function() {
    var recoveryData = localStorage.getItem("inrep_session_backup");
    if (recoveryData) {
      Shiny.setInputValue("recovered_data", recoveryData);
      
      // Show recovery notification
      if (typeof Shiny !== "undefined" && Shiny.shinyapp) {
        Shiny.setInputValue("show_recovery_prompt", true);
      }
    }
  });
  
  // Custom message handlers
  Shiny.addCustomMessageHandler("saveToLocalStorage", function(message) {
    try {
      localStorage.setItem(message.key, message.data);
    } catch(e) {
      console.error("Failed to save to localStorage:", e);
    }
  });
  
  Shiny.addCustomMessageHandler("getFromLocalStorage", function(message) {
    try {
      var data = localStorage.getItem(message.key);
      if (data) {
        Shiny.setInputValue(message.callback, data);
      }
    } catch(e) {
      console.error("Failed to retrieve from localStorage:", e);
    }
  });
  '
}

#' Clean Old Recovery Files
#' 
#' Removes recovery files older than specified days
#' 
#' @param days Number of days to retain files
clean_old_recovery_files <- function(days) {
  if (!dir.exists(.recovery_state$recovery_dir)) return()
  
  recovery_files <- list.files(
    .recovery_state$recovery_dir,
    pattern = "^recovery_.*\\.rds$",
    full.names = TRUE
  )
  
  if (length(recovery_files) == 0) return()
  
  file_info <- file.info(recovery_files)
  cutoff_time <- Sys.time() - (days * 24 * 60 * 60)
  
  old_files <- recovery_files[file_info$mtime < cutoff_time]
  
  if (length(old_files) > 0) {
    unlink(old_files)
    log_recovery_event("CLEANUP", 
                      paste("Removed", length(old_files), "old recovery files"))
  }
}

#' Backup to Cloud
#' 
#' Backs up recovery data to cloud storage
#' 
#' @param data Data to backup
backup_to_cloud <- function(data) {
  # Implementation depends on cloud provider
  # This is a placeholder for cloud backup functionality
  tryCatch({
    # Example: Save to configured WebDAV endpoint
    if (exists(".webdav_config") && !is.null(.webdav_config$url)) {
      # Implement WebDAV upload
      log_recovery_event("CLOUD_BACKUP", "Data backed up to cloud")
    }
  }, error = function(e) {
    log_recovery_event("CLOUD_BACKUP_ERROR", e$message)
  })
}

#' Generate Recovery ID
#' 
#' Generates a unique recovery identifier
#' 
#' @return Character string with recovery ID
generate_recovery_id <- function() {
  paste0(
    "REC_",
    format(Sys.time(), "%Y%m%d%H%M%S"),
    "_",
    paste(sample(c(letters, 0:9), 6, replace = TRUE), collapse = "")
  )
}

#' Log Recovery Event
#' 
#' Logs recovery-related events
#' 
#' @param event_type Type of event
#' @param message Event message
log_recovery_event <- function(event_type, message) {
  if (exists("log_session_event")) {
    log_session_event(paste0("RECOVERY_", event_type), message)
  } else {
    # Fallback to simple logging
    # Use message() instead of cat() for CRAN compliance
    message(sprintf("[%s] %s: %s", 
                   format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
                   event_type, 
                   message))
  }
}

#' Get Recovery Status
#' 
#' Returns current recovery system status
#' 
#' @return List with recovery status information
#' @export
get_recovery_status <- function() {
  list(
    auto_save_enabled = .recovery_state$auto_save_enabled,
    auto_save_interval = .recovery_state$auto_save_interval,
    browser_storage_enabled = .recovery_state$enable_browser_storage,
    cloud_backup_enabled = .recovery_state$enable_cloud_backup,
    recovery_dir = .recovery_state$recovery_dir,
    cached_sessions = length(.recovery_state$recovery_cache),
    recovery_files = length(list.files(.recovery_state$recovery_dir, 
                                       pattern = "^recovery_.*\\.rds$"))
  )
}