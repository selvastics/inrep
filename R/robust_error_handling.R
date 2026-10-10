# Error logging helpers used by launch_study() ----
#
# What this file does: it counts errors, writes them to a log file in
# tempdir(), and on request saves an .rds file with the error counter and the
# last error. The "recovery" functions only look for such files and return
# what they find (or a fixed placeholder list); nothing here restores a
# participant's session or re-runs failed code. Participant data are saved by
# preserve_session_data() in robust_session.R and by launch_study() itself.

# Package-level state, shared by all sessions in the R process
.error_handling_state <- new.env()
.error_handling_state$error_count <- 0
.error_handling_state$last_error <- NULL
.error_handling_state$recovery_attempts <- 0
.error_handling_state$max_recovery_attempts <- 3

#' @noRd
initialize_robust_error_handling <- function(
  max_recovery_attempts = 3,
  enable_auto_recovery = TRUE,
  set_global_handlers = FALSE
) {
  .error_handling_state$max_recovery_attempts <- max_recovery_attempts
  .error_handling_state$enable_auto_recovery <- enable_auto_recovery
  .error_handling_state$error_count <- 0
  .error_handling_state$recovery_attempts <- 0

  # Global handlers are opt-in; do not override the user's session by default.
  if (isTRUE(set_global_handlers)) {
    .error_handling_state$previous_error_option <- getOption("error")
    .error_handling_state$previous_warning_expression <- getOption("warning.expression")
    options(error = robust_error_handler)

    if (exists("robust_warning_handler") && is.function(robust_warning_handler)) {
      tryCatch({
        options(warning.expression = quote(robust_warning_handler))
      }, error = function(e) {
        .error_handling_state$warning_handler_available <- FALSE
      })
    }
  }

  return(list(
    max_recovery_attempts = max_recovery_attempts,
    enable_auto_recovery = enable_auto_recovery
  ))
}

#' Log an error and run the "recovery" steps
#'
#' @param e Error object
#' @noRd
robust_error_handler <- function(e) {
  .error_handling_state$error_count <- .error_handling_state$error_count + 1
  .error_handling_state$last_error <- e

  log_error_event("ERROR_OCCURRED", "Unhandled error occurred",
                  list(error_message = e$message,
                       call = as.character(e$call),
                       error_count = .error_handling_state$error_count))

  emergency_data_preservation()

  if (.error_handling_state$enable_auto_recovery &&
      .error_handling_state$recovery_attempts < .error_handling_state$max_recovery_attempts) {
    attempt_error_recovery(e)
  } else {
    show_user_friendly_error(e)
  }
}

#' Log a warning and re-signal it
#'
#' @param warning_message Warning message
#' @noRd
robust_warning_handler <- function(warning_message) {
  log_error_event("WARNING_OCCURRED", "Warning occurred",
                  list(warning_message = warning_message))
  warning(warning_message)
}

#' Append one line to the error log
#'
#' Writes to the session log file when one is set, otherwise to
#' \code{tempdir()/inrep_error.log}.
#'
#' @param event_type Type of error event
#' @param message Error description
#' @param details Additional error details
#' @noRd
log_error_event <- function(event_type, message, details = NULL) {
  log_file <- if (exists(".session_state") && !is.null(.session_state$log_file)) {
    .session_state$log_file
  } else {
    file.path(tempdir(), "inrep_error.log")
  }

  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")

  # jsonlite warns on atomic vectors with names; convert to list
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
    if (!is.null(safe_details)) paste0(" | ", jsonlite::toJSON(safe_details, auto_unbox = TRUE)) else "",
    "\n"
  )

  tryCatch({
    cat(log_entry, file = log_file, append = TRUE)
  }, error = function(e) {
    message("Error logging failed: ", e$message)
  })

  if (event_type %in% c("ERROR_OCCURRED", "RECOVERY_FAILED", "EMERGENCY_PRESERVATION_FAILED")) {
    message(sprintf("[ERROR] %s: %s", event_type, message))
  }
}

#' Save session data after an error
#'
#' Calls \code{preserve_session_data(force = TRUE)} (robust_session.R) and
#' writes the error context to an .rds file in \code{tempdir()}.
#'
#' @return Logical indicating whether both steps ran without error
#' @noRd
emergency_data_preservation <- function() {
  tryCatch({
    if (exists("preserve_session_data")) {
      preserve_session_data(force = TRUE)
    }

    emergency_save_current_data()

    log_error_event("EMERGENCY_PRESERVATION", "Emergency data preservation completed")
    return(TRUE)
  }, error = function(e) {
    log_error_event("EMERGENCY_PRESERVATION_FAILED", "Emergency data preservation failed",
                    list(error = e$message))
    return(FALSE)
  })
}

#' Save the error context to tempdir()
#'
#' Saves the output of \code{get_current_environment_data()} (error counter,
#' last error, timestamp) as \code{inrep_emergency_<time>.rds}.
#' @noRd
emergency_save_current_data <- function() {
  tryCatch({
    current_data <- get_current_environment_data()

    if (length(current_data) > 0) {
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

#' Error context
#'
#' Returns the error counter, the last error and a timestamp. It does not
#' collect participant data.
#'
#' @return List with element \code{error_context}
#' @noRd
get_current_environment_data <- function() {
  data <- list()

  data$error_context <- list(
    error_count = .error_handling_state$error_count,
    last_error = .error_handling_state$last_error,
    timestamp = Sys.time()
  )

  return(data)
}

#' Count a recovery attempt and look for saved data
#'
#' @param e Error object
#' @return \code{TRUE} if \code{recover_session_after_error()} returned
#'   something. Since that function falls back to a placeholder list, this is
#'   \code{TRUE} unless an error occurs; nothing is restored into the session.
#' @noRd
attempt_error_recovery <- function(e) {
  .error_handling_state$recovery_attempts <- .error_handling_state$recovery_attempts + 1

  log_error_event("RECOVERY_ATTEMPT", "Attempting error recovery",
                  list(attempt = .error_handling_state$recovery_attempts,
                       max_attempts = .error_handling_state$max_recovery_attempts))

  tryCatch({
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

#' Look for saved data after an error
#'
#' Returns, in this order, the newest file from
#' \code{emergency_data_recovery()}, the newest \code{inrep_backup_*.rds}
#' file, or the placeholder from \code{create_minimal_working_state()}.
#'
#' @return List, or NULL on error
#' @noRd
recover_session_after_error <- function() {
  tryCatch({
    if (exists("emergency_data_recovery")) {
      recovered_data <- emergency_data_recovery()
      if (!is.null(recovered_data)) {
        return(recovered_data)
      }
    }

    restored_data <- restore_last_known_state()
    if (!is.null(restored_data)) {
      return(restored_data)
    }

    minimal_state <- create_minimal_working_state()
    return(minimal_state)

  }, error = function(e) {
    log_error_event("RECOVERY_PROCESS_ERROR", "Error during recovery process",
                    list(error = e$message))
    return(NULL)
  })
}

#' Read the newest backup file
#'
#' Reads the newest \code{inrep_backup_*.rds} file in \code{tempdir()}. These
#' files are written by \code{create_periodic_backup()} and hold only the error
#' context.
#'
#' @return List or NULL
#' @noRd
restore_last_known_state <- function() {
  tryCatch({
    temp_dir <- tempdir()
    backup_pattern <- "inrep_backup_.*\\.rds$"
    backup_files <- list.files(temp_dir, pattern = backup_pattern, full.names = TRUE)

    if (length(backup_files) == 0) {
      return(NULL)
    }

    file_info <- file.info(backup_files)
    most_recent <- backup_files[which.max(file_info$mtime)]

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

#' Placeholder state
#'
#' Returns a fixed list (configuration "Recovery Mode", 1PL, ten items, empty
#' responses). The list is not used to restart anything.
#'
#' @return List
#' @noRd
create_minimal_working_state <- function() {
  tryCatch({
    minimal_config <- list(
      study_name = "Recovery Mode",
      max_items = 10,
      min_items = 1,
      model = "1PL",
      session_mode = "recovery"
    )

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

#' Console message after repeated errors
#'
#' Writes a message to the R console (not to the participant's browser) and
#' saves an error report.
#'
#' @param e Error object
#' @noRd
show_user_friendly_error <- function(e) {
  error_message <- paste0(
    "inrep: an unexpected error occurred. ",
    "Details are in the error log and in an error report in tempdir()."
  )

  log_error_event("USER_FRIENDLY_ERROR", "Showing user-friendly error message",
                  list(original_error = e$message))

  message(error_message)

  save_error_report(e)
}

#' Save an error report to tempdir()
#'
#' @param e Error object
#' @noRd
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

#' Reset the error counters
#' @noRd
reset_error_handling_state <- function() {
  .error_handling_state$error_count <- 0
  .error_handling_state$last_error <- NULL
  .error_handling_state$recovery_attempts <- 0

  log_error_event("ERROR_STATE_RESET", "Error handling state reset")
}

#' Current error counters
#'
#' @return List
#' @noRd
get_error_handling_status <- function() {
  return(list(
    error_count = .error_handling_state$error_count,
    last_error = .error_handling_state$last_error,
    recovery_attempts = .error_handling_state$recovery_attempts,
    max_recovery_attempts = .error_handling_state$max_recovery_attempts,
    enable_auto_recovery = .error_handling_state$enable_auto_recovery
  ))
}

#' Periodic backup of the error context
#'
#' Inside a running Shiny app, creates an observer that every
#' \code{backup_interval} seconds saves the error context (not participant
#' data) as \code{inrep_backup_<time>.rds} and keeps the newest five files.
#' Outside a running app it does nothing; \code{launch_study()} calls it
#' before the app runs, so there it has no effect.
#'
#' @param backup_interval Backup interval in seconds
#' @noRd
create_periodic_backup <- function(backup_interval = 300) {
  if (!shiny::isRunning()) {
    return(invisible(NULL))
  }

  backup_observer <- shiny::observe({
    shiny::invalidateLater(backup_interval * 1000)

    tryCatch({
      current_data <- get_current_environment_data()

      if (length(current_data) > 0) {
        backup_file <- file.path(tempdir(), paste0("inrep_backup_",
                                                  format(Sys.time(), "%Y%m%d_%H%M%S"), ".rds"))
        saveRDS(current_data, backup_file)

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

#' Delete old backup files
#'
#' @param keep_count Number of recent backups to keep
#' @noRd
cleanup_old_backups <- function(keep_count = 5) {
  tryCatch({
    temp_dir <- tempdir()
    backup_pattern <- "inrep_backup_.*\\.rds$"
    backup_files <- list.files(temp_dir, pattern = backup_pattern, full.names = TRUE)

    if (length(backup_files) > keep_count) {
      file_info <- file.info(backup_files)
      file_info$filename <- backup_files
      file_info <- file_info[order(file_info$mtime, decreasing = TRUE), ]

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
