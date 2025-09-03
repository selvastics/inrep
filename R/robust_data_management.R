#' Robust Data Management System for INREP
#' 
#' This module provides comprehensive data collection, storage, and preservation
#' capabilities for adaptive assessments. It ensures that all study data is
#' systematically collected and stored in a structured dataframe format.
#' 
#' @author Clievins Selva
#' @version 1.0.0

# Global data management state
.data_state <- new.env()
.data_state$study_data <- NULL
.data_state$session_active <- FALSE
.data_state$data_file_path <- NULL
.data_state$backup_enabled <- TRUE
.data_state$last_save_time <- NULL
.data_state$batch_updates <- list()
.data_state$batch_size <- 5  # Save after every 5 updates
.data_state$update_count <- 0

#' Initialize Data Management System
#' 
#' @param study_key Unique identifier for the study
#' @param config Study configuration object
#' @param item_bank Item bank data
#' @param output_dir Directory for data output (default: tempdir())
#' @param enable_backup Whether to enable automatic backup
#' @return List with data management configuration
initialize_data_management <- function(
  study_key = NULL,
  config = NULL,
  item_bank = NULL,
  output_dir = tempdir(),
  enable_backup = TRUE
) {
  # Generate unique study identifier
  if (is.null(study_key)) {
    study_key <- paste0("STUDY_", format(Sys.time(), "%Y%m%d_%H%M%S"), "_", 
                       sample(1000:9999, 1))
  }
  
  # Initialize data state
  .data_state$study_key <- study_key
  .data_state$config <- config
  .data_state$item_bank <- item_bank
  .data_state$output_dir <- output_dir
  .data_state$backup_enabled <- enable_backup
  .data_state$session_active <- TRUE
  .data_state$start_time <- Sys.time()
  .data_state$last_save_time <- Sys.time()
  
  # Create initial study dataframe structure
  .data_state$study_data <- create_initial_dataframe(config, item_bank)
  
  # Set up data file path
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  filename <- paste0(study_key, "_", timestamp, ".csv")
  .data_state$data_file_path <- file.path(output_dir, filename)
  
  # Log initialization
  log_data_event("DATA_MGMT_INIT", "Data management system initialized", 
                list(study_key = study_key, output_file = .data_state$data_file_path))
  
  return(list(
    study_key = study_key,
    data_file_path = .data_state$data_file_path,
    session_active = TRUE
  ))
}

#' Create Initial Dataframe Structure
#' 
#' @param config Study configuration
#' @param item_bank Item bank data
#' @return Initialized dataframe with study structure
create_initial_dataframe <- function(config, item_bank) {
  # Base columns for every study
  base_columns <- c(
    "session_id",
    "study_key", 
    "participant_id",
    "start_time",
    "end_time",
    "session_duration",
    "completion_status",
    "total_items",
    "administered_items",
    "final_ability_estimate",
    "final_standard_error",
    "study_type",
    "language",
    "device_info",
    "browser_info"
  )
  
  # Add item response columns if item bank is available
  item_columns <- character(0)
  if (!is.null(item_bank) && nrow(item_bank) > 0) {
    item_columns <- paste0("item_", item_bank$id %||% seq_len(nrow(item_bank)))
  }
  
  # Add custom page flow columns if applicable
  custom_columns <- character(0)
  if (!is.null(config$custom_page_flow)) {
    custom_columns <- c(
      "custom_pages_completed",
      "instruction_pages_viewed",
      "demo_pages_viewed",
      "custom_page_times"
    )
  }
  
  # Add demographics columns
  demo_columns <- c(
    "age",
    "gender", 
    "education",
    "participant_code",
    "custom_demographics"
  )
  
  # Combine all columns
  all_columns <- c(base_columns, item_columns, custom_columns, demo_columns)
  
  # Create empty dataframe with proper structure
  df <- data.frame(
    matrix(NA, nrow = 0, ncol = length(all_columns),
           dimnames = list(NULL, all_columns)),
    stringsAsFactors = FALSE
  )
  
  # Set appropriate data types
  df$session_id <- character(0)
  df$study_key <- character(0)
  df$participant_id <- character(0)
  df$start_time <- as.POSIXct(character(0))
  df$end_time <- as.POSIXct(character(0))
  df$session_duration <- numeric(0)
  df$completion_status <- character(0)
  df$total_items <- integer(0)
  df$administered_items <- integer(0)
  df$final_ability_estimate <- numeric(0)
  df$final_standard_error <- numeric(0)
  df$study_type <- character(0)
  df$language <- character(0)
  df$device_info <- character(0)
  df$browser_info <- character(0)
  
  if (length(custom_columns) > 0) {
    df$custom_pages_completed <- integer(0)
    df$instruction_pages_viewed <- integer(0)
    df$demo_pages_viewed <- integer(0)
    df$custom_page_times <- character(0)
  }
  
  df$age <- integer(0)
  df$gender <- character(0)
  df$education <- character(0)
  df$participant_code <- character(0)
  df$custom_demographics <- character(0)
  
  return(df)
}

#' Add Session Data to Study Dataframe
#' 
#' @param session_data List containing session information
#' @param responses Vector of item responses
#' @param demographics List of demographic information
#' @param custom_data List of custom page data
#' @return Updated dataframe
add_session_data <- function(session_data = NULL, responses = NULL, 
                           demographics = NULL, custom_data = NULL) {
  if (!.data_state$session_active) {
    log_data_event("DATA_ADD_SKIPPED", "Session not active, skipping data addition")
    return(.data_state$study_data)
  }
  
  tryCatch({
    # Create new row for this session
    new_row <- create_session_row(session_data, responses, demographics, custom_data)
    
    # Add to study dataframe
    .data_state$study_data <- rbind(.data_state$study_data, new_row)
    
    # Auto-save if backup is enabled
    if (.data_state$backup_enabled) {
      save_study_data()
    }
    
    log_data_event("DATA_ADDED", "Session data added to study dataframe", 
                  list(rows = nrow(.data_state$study_data)))
    
    return(.data_state$study_data)
    
  }, error = function(e) {
    log_data_event("DATA_ADD_ERROR", "Failed to add session data", 
                  list(error = e$message))
    return(.data_state$study_data)
  })
}

#' Create Session Row
#' 
#' @param session_data Session information
#' @param responses Item responses
#' @param demographics Demographic data
#' @param custom_data Custom page data
#' @return Dataframe row for the session
create_session_row <- function(session_data, responses, demographics, custom_data) {
  # Get current dataframe structure
  df_template <- .data_state$study_data
  
  # Create new row with same structure
  new_row <- df_template[1, , drop = FALSE]
  new_row[1, ] <- NA
  
  # Fill in session information
  if (!is.null(session_data)) {
    new_row$session_id <- session_data$session_id %||% generate_session_id()
    new_row$study_key <- .data_state$study_key
    new_row$participant_id <- session_data$participant_id %||% "unknown"
    new_row$start_time <- session_data$start_time %||% .data_state$start_time
    new_row$end_time <- session_data$end_time %||% Sys.time()
    new_row$session_duration <- as.numeric(difftime(
      new_row$end_time, new_row$start_time, units = "secs"))
    new_row$completion_status <- session_data$completion_status %||% "incomplete"
    new_row$total_items <- session_data$total_items %||% nrow(.data_state$item_bank %||% data.frame())
    new_row$administered_items <- session_data$administered_items %||% 0
    new_row$final_ability_estimate <- session_data$final_ability %||% NA_real_
    new_row$final_standard_error <- session_data$final_se %||% NA_real_
    new_row$study_type <- session_data$study_type %||% "adaptive"
    new_row$language <- session_data$language %||% "en"
    new_row$device_info <- session_data$device_info %||% "unknown"
    new_row$browser_info <- session_data$browser_info %||% "unknown"
  }
  
  # Fill in item responses
  if (!is.null(responses) && !is.null(.data_state$item_bank)) {
    item_bank <- .data_state$item_bank
    for (i in seq_len(nrow(item_bank))) {
      item_id <- item_bank$id[i] %||% i
      col_name <- paste0("item_", item_id)
      if (col_name %in% names(new_row)) {
        new_row[[col_name]] <- responses[i] %||% NA_real_
      }
    }
  }
  
  # Fill in demographics
  if (!is.null(demographics)) {
    new_row$age <- demographics$age %||% NA_integer_
    new_row$gender <- demographics$gender %||% NA_character_
    new_row$education <- demographics$education %||% NA_character_
    new_row$participant_code <- demographics$participant_code %||% NA_character_
    
    # Store custom demographics as JSON string
    custom_demo <- demographics[!names(demographics) %in% 
                               c("age", "gender", "education", "participant_code")]
    if (length(custom_demo) > 0) {
      new_row$custom_demographics <- jsonlite::toJSON(custom_demo, auto_unbox = TRUE)
    }
  }
  
  # Fill in custom page data
  if (!is.null(custom_data)) {
    new_row$custom_pages_completed <- custom_data$pages_completed %||% 0
    new_row$instruction_pages_viewed <- custom_data$instruction_pages %||% 0
    new_row$demo_pages_viewed <- custom_data$demo_pages %||% 0
    new_row$custom_page_times <- jsonlite::toJSON(custom_data$page_times %||% list(), auto_unbox = TRUE)
  }
  
  return(new_row)
}

#' Save Study Data
#' 
#' @param force Whether to force save even if no changes
#' @return Logical indicating success
save_study_data <- function(force = FALSE) {
  if (!.data_state$session_active && !force) {
    log_data_event("SAVE_SKIPPED", "Session not active, skipping save")
    return(FALSE)
  }
  
  tryCatch({
    if (is.null(.data_state$study_data) || nrow(.data_state$study_data) == 0) {
      log_data_event("SAVE_EMPTY", "No data to save")
      return(FALSE)
    }
    
    # Save to CSV
    write.csv(.data_state$study_data, .data_state$data_file_path, 
              row.names = FALSE, fileEncoding = "UTF-8")
    
    # Also save as RDS for backup
    rds_path <- gsub("\\.csv$", ".rds", .data_state$data_file_path)
    saveRDS(.data_state$study_data, rds_path)
    
    .data_state$last_save_time <- Sys.time()
    
    log_data_event("DATA_SAVED", "Study data saved successfully", 
                  list(file = .data_state$data_file_path, 
                       rows = nrow(.data_state$study_data)))
    
    return(TRUE)
    
  }, error = function(e) {
    log_data_event("SAVE_ERROR", "Failed to save study data", 
                  list(error = e$message))
    return(FALSE)
  })
}

#' Update Session Data
#' 
#' @param updates List of updates to apply
#' @return Updated dataframe
update_session_data <- function(updates) {
  if (!.data_state$session_active) {
    return(.data_state$study_data)
  }
  
  tryCatch({
    if (nrow(.data_state$study_data) > 0) {
      # Update the last row (current session)
      last_row_idx <- nrow(.data_state$study_data)
      
      for (field in names(updates)) {
        if (field %in% names(.data_state$study_data)) {
          .data_state$study_data[last_row_idx, field] <- updates[[field]]
        }
      }
      
      # Auto-save if backup is enabled (with batching)
      if (.data_state$backup_enabled) {
        .data_state$update_count <- .data_state$update_count + 1
        if (.data_state$update_count >= .data_state$batch_size) {
          save_study_data()
          .data_state$update_count <- 0
        }
      }
      
      log_data_event("DATA_UPDATED", "Session data updated", 
                    list(updated_fields = names(updates)))
    }
    
    return(.data_state$study_data)
    
  }, error = function(e) {
    log_data_event("UPDATE_ERROR", "Failed to update session data", 
                  list(error = e$message))
    return(.data_state$study_data)
  })
}

#' Get Current Study Data
#' 
#' @return Current study dataframe
get_study_data <- function() {
  return(.data_state$study_data)
}

#' Finalize Study Data
#' 
#' @param final_session_data Final session information
#' @return Final dataframe
finalize_study_data <- function(final_session_data = NULL) {
  tryCatch({
    # Update final session data
    if (!is.null(final_session_data)) {
      update_session_data(final_session_data)
    }
    
    # Mark session as complete
    if (nrow(.data_state$study_data) > 0) {
      .data_state$study_data$completion_status[nrow(.data_state$study_data)] <- "completed"
      .data_state$study_data$end_time[nrow(.data_state$study_data)] <- Sys.time()
    }
    
    # Final save
    save_study_data(force = TRUE)
    
    # Deactivate session
    .data_state$session_active <- FALSE
    
    log_data_event("DATA_FINALIZED", "Study data finalized", 
                  list(final_rows = nrow(.data_state$study_data)))
    
    return(.data_state$study_data)
    
  }, error = function(e) {
    log_data_event("FINALIZE_ERROR", "Failed to finalize study data", 
                  list(error = e$message))
    return(.data_state$study_data)
  })
}

#' Log Data Event
#' 
#' @param event_type Type of event
#' @param message Event message
#' @param details Additional details
log_data_event <- function(event_type, message, details = NULL) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  log_entry <- list(
    timestamp = timestamp,
    event_type = event_type,
    message = message,
    details = details
  )
  
  # Print to console for important events
  if (event_type %in% c("DATA_MGMT_INIT", "DATA_SAVED", "DATA_FINALIZED", "SAVE_ERROR", "FINALIZE_ERROR")) {
    cat(sprintf("[%s] %s: %s\n", timestamp, event_type, message))
  }
  
  # Log to file if logging is enabled
  if (exists("logger") && is.function(logger)) {
    tryCatch({
      logger(message, level = if (grepl("ERROR", event_type)) "ERROR" else "INFO")
    }, error = function(e) {
      # Fallback to simple cat if logger fails
      cat(sprintf("[%s] %s: %s\n", timestamp, event_type, message))
    })
  }
}

#' Generate Session ID
#' 
#' @return Unique session identifier
generate_session_id <- function() {
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  random_suffix <- paste0(sample(letters, 8, replace = TRUE), collapse = "")
  return(paste0("SESS_", timestamp, "_", random_suffix))
}

#' Emergency Data Recovery
#' 
#' @param file_path Path to data file
#' @return Recovered dataframe or NULL
emergency_data_recovery <- function(file_path = NULL) {
  if (is.null(file_path)) {
    file_path <- .data_state$data_file_path
  }
  
  tryCatch({
    if (file.exists(file_path)) {
      if (grepl("\\.csv$", file_path)) {
        recovered_data <- read.csv(file_path, stringsAsFactors = FALSE)
      } else if (grepl("\\.rds$", file_path)) {
        recovered_data <- readRDS(file_path)
      } else {
        return(NULL)
      }
      
      log_data_event("DATA_RECOVERED", "Data recovered from file", 
                    list(file = file_path, rows = nrow(recovered_data)))
      
      return(recovered_data)
    }
  }, error = function(e) {
    log_data_event("RECOVERY_ERROR", "Failed to recover data", 
                  list(error = e$message))
    return(NULL)
  })
  
  return(NULL)
}

#' Get Data Statistics
#' 
#' @return List with data statistics
get_data_statistics <- function() {
  if (is.null(.data_state$study_data) || nrow(.data_state$study_data) == 0) {
    return(list(
      total_sessions = 0,
      completed_sessions = 0,
      incomplete_sessions = 0,
      total_responses = 0,
      data_file_size = 0
    ))
  }
  
  df <- .data_state$study_data
  
  return(list(
    total_sessions = nrow(df),
    completed_sessions = sum(df$completion_status == "completed", na.rm = TRUE),
    incomplete_sessions = sum(df$completion_status != "completed", na.rm = TRUE),
    total_responses = sum(!is.na(df[, grepl("^item_", names(df))]), na.rm = TRUE),
    data_file_size = if (file.exists(.data_state$data_file_path)) {
      file.size(.data_state$data_file_path)
    } else {
      0
    },
    last_save_time = .data_state$last_save_time
  ))
}