#' Comprehensive Data Management System for inrep Package
#' 
#' This module provides a unified dataset system that captures ALL data
#' progressively throughout the study, ensuring no data is lost and
#' everything is available for export.
#' 
#' @name comprehensive_data_manager

# Global state for comprehensive dataset
.comprehensive_dataset <- NULL

# Global state for logging data
.logging_data <- NULL
.logging_enabled <- FALSE

#' Initialize Comprehensive Dataset
#' 
#' Creates a comprehensive dataset that will capture all study data
#' progressively. This dataset grows with every page progression and
#' ensures no data is lost.
#' 
#' @param config Study configuration object
#' @param item_bank Item bank data frame
#' @param study_key Unique study identifier
#' @return Initialized comprehensive dataset
#' @export
initialize_comprehensive_dataset <- function(config, item_bank, study_key) {
  # Create base dataset structure
  base_dataset <- data.frame(
    study_key = study_key,
    session_id = generate_session_id(),
    start_time = Sys.time(),
    end_time = NA,
    total_duration_seconds = NA,
    stringsAsFactors = FALSE
  )
  
  # Add demographic columns
  if (!is.null(config$demographics)) {
    for (dem in config$demographics) {
      base_dataset[[paste0("demo_", dem)]] <- NA_character_
    }
  }
  
  # Add standard item response columns
  if (!is.null(item_bank)) {
    for (i in 1:nrow(item_bank)) {
      item_id <- item_bank$id[i] %||% paste0("item_", i)
      base_dataset[[paste0("item_", item_id)]] <- NA_real_
    }
  }
  
  # Add metadata columns
  base_dataset$current_stage <- "initialized"
  base_dataset$current_page <- 1
  base_dataset$total_pages <- if (!is.null(config$custom_page_flow)) length(config$custom_page_flow) else 1
  base_dataset$last_updated <- Sys.time()
  
  # Initialize logging system
  .logging_enabled <<- config$log_data %||% FALSE
  if (.logging_enabled) {
    .logging_data <<- list(
      actions = list(),
      page_times = list(),
      total_actions = 0,
      session_start = Sys.time(),
      current_page_start = Sys.time()
    )
    
    # Add logging columns to dataset
    base_dataset$total_actions <- 0
    base_dataset$total_page_switches <- 0
    base_dataset$total_input_changes <- 0
    base_dataset$total_button_clicks <- 0
    base_dataset$avg_time_per_page_seconds <- NA
    base_dataset$longest_page_time_seconds <- NA
    base_dataset$shortest_page_time_seconds <- NA
    base_dataset$page_times_json <- NA_character_
    base_dataset$action_log_json <- NA_character_
  }
  
  # Add result columns (will be filled at the end)
  base_dataset$final_theta <- NA_real_
  base_dataset$final_se <- NA_real_
  base_dataset$total_items_administered <- 0
  base_dataset$completion_time <- NA_real_
  base_dataset$study_completed <- FALSE
  
  # Store in global state
  .comprehensive_dataset <<- base_dataset
  
  return(base_dataset)
}

#' Update Comprehensive Dataset
#' 
#' Updates the comprehensive dataset with new data from any page type.
#' This function is called whenever data is collected from any page.
#' 
#' @param page_type Type of page ("demographics", "custom_page", "items", "results")
#' @param page_data Data collected from the current page
#' @param page_id Optional page identifier for custom pages
#' @param stage Current study stage
#' @param current_page Current page number
#' @return Updated comprehensive dataset
#' @export
update_comprehensive_dataset <- function(page_type, page_data, page_id = NULL, stage = NULL, current_page = NULL) {
  
  if (is.null(.comprehensive_dataset)) {
    warning("Comprehensive dataset not initialized. Call initialize_comprehensive_dataset() first.")
    return(NULL)
  }
  
  # Create a copy to update
  updated_dataset <- .comprehensive_dataset
  
  # Update based on page type
  switch(page_type,
    "demographics" = {
      # Update demographic data
      if (!is.null(page_data) && is.list(page_data)) {
        for (dem in names(page_data)) {
          col_name <- paste0("demo_", dem)
          if (col_name %in% names(updated_dataset)) {
            updated_dataset[[col_name]] <- page_data[[dem]]
          }
        }
      }
    },
    "custom_page" = {
      # Update custom page data
      if (!is.null(page_id) && !is.null(page_data)) {
        if (is.list(page_data)) {
          for (field in names(page_data)) {
            col_name <- paste0("custom_", page_id, "_", field)
            if (col_name %in% names(updated_dataset)) {
              updated_dataset[[col_name]] <- page_data[[field]]
            } else {
              # Add new column if it doesn't exist
              updated_dataset[[col_name]] <- page_data[[field]]
            }
          }
        }
      }
    },
    "items" = {
      # Update item response data
      if (!is.null(page_data) && is.list(page_data)) {
        for (item in names(page_data)) {
          col_name <- paste0("item_", item)
          if (col_name %in% names(updated_dataset)) {
            updated_dataset[[col_name]] <- page_data[[item]]
          }
        }
      }
    },
    "results" = {
      # Update final results
      if (!is.null(page_data) && is.list(page_data)) {
        if (!is.null(page_data$theta)) updated_dataset$final_theta <- page_data$theta
        if (!is.null(page_data$se)) updated_dataset$final_se <- page_data$se
        if (!is.null(page_data$administered)) updated_dataset$total_items_administered <- length(page_data$administered)
      }
      
      # Update end time and duration
      updated_dataset$end_time <- Sys.time()
      if (!is.na(updated_dataset$start_time)) {
        updated_dataset$total_duration_seconds <- as.numeric(difftime(updated_dataset$end_time, updated_dataset$start_time, units = "secs"))
      }
      updated_dataset$study_completed <- TRUE
      
      # Update with final logging data
      if (.logging_enabled) {
        updated_dataset <- update_dataset_with_logging()
      }
    }
  )
  
  # Update metadata
  if (!is.null(stage)) updated_dataset$current_stage <- stage
  if (!is.null(current_page)) updated_dataset$current_page <- current_page
  updated_dataset$last_updated <- Sys.time()
  
  # Update global state
  .comprehensive_dataset <<- updated_dataset
  
  return(updated_dataset)
}

#' Get Comprehensive Dataset
#' 
#' Returns the current comprehensive dataset with all collected data.
#' 
#' @return Current comprehensive dataset
#' @export
get_comprehensive_dataset <- function() {
  return(.comprehensive_dataset)
}

#' Export Comprehensive Dataset
#' 
#' Exports the comprehensive dataset to a file.
#' 
#' @param format Export format ("csv", "json", "rds")
#' @param file_path Optional file path
#' @return File path of exported file
#' @export
export_comprehensive_dataset <- function(format = "csv", file_path = NULL) {
  if (is.null(.comprehensive_dataset)) {
    warning("No comprehensive dataset to export")
    return(NULL)
  }
  
  if (is.null(file_path)) {
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    file_path <- paste0("comprehensive_dataset_", timestamp, ".", format)
  }
  
  switch(format,
    "csv" = utils::write.csv(.comprehensive_dataset, file_path, row.names = FALSE),
    "json" = jsonlite::write_json(.comprehensive_dataset, file_path, pretty = TRUE, auto_unbox = TRUE),
    "rds" = saveRDS(.comprehensive_dataset, file_path)
  )
  
  return(file_path)
}

#' Reset Comprehensive Dataset
#' 
#' Resets the comprehensive dataset (useful for testing or restarting).
#' 
#' @export
reset_comprehensive_dataset <- function() {
  .comprehensive_dataset <<- NULL
  message("Comprehensive dataset reset.")
}

#' Log Action
#' 
#' Logs a user action for comprehensive tracking.
#' 
#' @param action_type Type of action
#' @param action_details Action details
#' @param page_id Page identifier
#' @export
log_action <- function(action_type, action_details = NULL, page_id = NULL) {
  if (!.logging_enabled) return()
  
  action_entry <- list(
    timestamp = Sys.time(),
    action_type = action_type,
    action_details = action_details,
    page_id = page_id
  )
  
  .logging_data$actions <<- append(.logging_data$actions, list(action_entry))
  .logging_data$total_actions <<- .logging_data$total_actions + 1
}

#' Log Page Time
#' 
#' Logs time spent on a page.
#' 
#' @param page_id Page identifier
#' @param time_spent_seconds Time spent in seconds
#' @export
log_page_time <- function(page_id, time_spent_seconds) {
  if (!.logging_enabled) return()
  
  .logging_data$page_times[[page_id]] <<- time_spent_seconds
}

#' Update Page Start Time
#' 
#' Updates the start time for the current page.
#' 
#' @param page_id Page identifier
#' @export
update_page_start_time <- function(page_id) {
  if (!.logging_enabled) return()
  
  .logging_data$current_page_start <<- Sys.time()
  log_action("page_switch", list(page_id = page_id), page_id)
  
  return(.logging_data)
}

#' Get Dataset Summary
#' 
#' Returns a summary of the comprehensive dataset.
#' 
#' @return Dataset summary
#' @export
get_dataset_summary <- function() {
  if (is.null(.comprehensive_dataset)) {
    return(list(
      initialized = FALSE,
      message = "Comprehensive dataset not initialized"
    ))
  }
  
  summary <- list(
    initialized = TRUE,
    study_key = .comprehensive_dataset$study_key,
    session_id = .comprehensive_dataset$session_id,
    start_time = .comprehensive_dataset$start_time,
    end_time = .comprehensive_dataset$end_time,
    total_duration_seconds = .comprehensive_dataset$total_duration_seconds,
    current_stage = .comprehensive_dataset$current_stage,
    current_page = .comprehensive_dataset$current_page,
    total_pages = .comprehensive_dataset$total_pages,
    study_completed = .comprehensive_dataset$study_completed,
    total_items_administered = .comprehensive_dataset$total_items_administered
  )
  
  # Add logging summary if enabled
  if (.logging_enabled && !is.null(.logging_data)) {
    summary$logging_enabled <- TRUE
    summary$total_actions <- .logging_data$total_actions
    summary$total_page_times <- length(.logging_data$page_times)
  } else {
    summary$logging_enabled <- FALSE
  }
  
  return(summary)
}

# Internal helper function
update_dataset_with_logging <- function() {
  if (!.logging_enabled || is.null(.logging_data)) return(get_comprehensive_dataset())
  
  dataset <- get_comprehensive_dataset()
  if (is.null(dataset)) return(NULL)
  
  # Calculate logging statistics
  total_actions <- .logging_data$total_actions
  page_times <- unlist(.logging_data$page_times)
  
  dataset$total_actions <- total_actions
  dataset$total_page_switches <- sum(sapply(.logging_data$actions, function(x) x$action_type == "page_switch"))
  dataset$total_input_changes <- sum(sapply(.logging_data$actions, function(x) x$action_type == "input_change"))
  dataset$total_button_clicks <- sum(sapply(.logging_data$actions, function(x) x$action_type == "button_click"))
  
  if (length(page_times) > 0) {
    dataset$avg_time_per_page_seconds <- mean(page_times)
    dataset$longest_page_time_seconds <- max(page_times)
    dataset$shortest_page_time_seconds <- min(page_times)
  }
  
  # Store as JSON
  dataset$page_times_json <- jsonlite::toJSON(.logging_data$page_times, auto_unbox = TRUE)
  dataset$action_log_json <- jsonlite::toJSON(.logging_data$actions, auto_unbox = TRUE)
  
  return(dataset)
}