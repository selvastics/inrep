# File: utils.R

#' Generate UUID
#'
#' Generates a universally unique identifier (UUID) for study configurations.
#' This is a convenience wrapper around uuid::UUIDgenerate().
#'
#' @return Character string containing a UUID.
#' @export
#' @examples
#' \dontrun{
#' # Generate a UUID for a study
#' study_id <- generate_uuid()
#' cat("Generated UUID:", study_id, "\n")
#' }
generate_uuid <- function() {
  uuid::UUIDgenerate()
}

#' Initialize Logging System
#'
#' Initializes the logging system for assessment sessions and research workflows.
#' This function creates a log file connection and assigns logging functions to the global environment.
#'
#' @param path Optional character string specifying the log file path.
#'   If NULL, creates a temporary log file in the system temp directory.
#'
#' @return A list containing:
#'   \itemize{
#'     \item success: logical indicating if logging was initialized successfully
#'     \item path: character string with the log file path
#'     \item message: character string with status message
#'   }
#'
#' @export
#' @examples
#' \dontrun{
#' # Initialize basic logging
#' log_success <- initialize_logging()
#' 
#' # Initialize with custom file path
#' log_file <- file.path(tempdir(), "my_assessment.log")
#' initialize_logging(path = log_file)
#' 
#' # Check if logging is working
#' if (exists("log_print")) {
#'   log_print("Test message", level = "INFO")
#'   cat("Logging is active\n")
#' }
#' }
initialize_logging <- function(path = NULL) {
  new_path <- if (is.null(path)) {
    file.path(tempdir(), "adaptive_test_default.log")
  } else {
    path
  }
  if (!log_open(new_path)) {
    message("Failed to initialize logging, using console output.")
    assign("log_print", function(msg, level = "INFO") {
      message(sprintf("[%s] %s", level, msg))
    }, envir = .GlobalEnv)
    return(list(success = FALSE, path = NULL, message = "Failed to initialize logging"))
  }
  assign(".log_path", new_path, envir = .GlobalEnv)
  assign("log_print", function(msg, level = "INFO") {
    cat(sprintf("[%s] %s\n", level, msg), file = .log_path, append = TRUE)
  }, envir = .GlobalEnv)
  print("Logging initialized successfully")
  list(success = TRUE, path = new_path, message = "Logging initialized successfully")
}

#' Advanced Logging Configuration
#'
#' Provides comprehensive logging capabilities for research platforms and assessment systems.
#' This function offers advanced configuration options for structured logging, monitoring,
#' and audit trail generation in adaptive testing environments.
#'
#' @param path Optional character string specifying the log file path.
#'   If NULL, creates a temporary log file in the system temp directory.
#'
#' @details
#' The logging system provides advanced configuration options for research environments.
#' 
#' @examples
#' \dontrun{
#' # Generate a UUID for study identification
#' study_id <- generate_uuid()
#' 
#' # Use in study configuration
#' config <- create_study_config(
#'   study_key = paste0("STUDY_", generate_uuid())
#' )
#' }
generate_uuid <- function() {
  uuid::UUIDgenerate()
}

#' Initialize Comprehensive Logging System
#'
#' Sets up a comprehensive logging system for inrep assessments with multiple
#' output options, structured formatting, and integration with the logr package.
#' Provides detailed audit trails for research compliance and debugging.
#'
#' @param path Character string specifying file path for log output. If \code{NULL},
#'   creates a temporary file with timestamp for session-specific logging.
#' @param level Character string specifying minimum log level to capture.
#'   Options: \code{"DEBUG"}, \code{"INFO"}, \code{"WARN"}, \code{"ERROR"}.
#' @param format Character string specifying log format. Options:
#'   \code{"standard"}, \code{"json"}, \code{"detailed"}.
#' @param console_output Logical indicating whether to also output to console.
#'   
#' @return Logical: \code{TRUE} if logging initialized successfully, \code{FALSE} otherwise.
#'   On failure, falls back to console-only logging with warning message.
#' 
#' @export
#' 
#' @details
#' The logging system provides:
#' \itemize{
#'   \item Timestamped entries with session identification
#'   \item Multiple log levels with filtering capabilities
#'   \item Structured output formats for automated processing
#'   \item Integration with assessment workflow tracking
#'   \item Participant action logging for audit trails
#'   \item Performance metrics and error tracking
#' }
#' 
#' Log entries include:
#' \itemize{
#'   \item Assessment initialization and configuration
#'   \item Item administration and response capture
#'   \item Ability estimation and item selection decisions
#'   \item User interface interactions and navigation
#'   \item Data validation and quality checks
#'   \item Session management and termination
#' }
#' 
#' @examples
#' \dontrun{
#' # Initialize basic logging
#' log_success <- initialize_logging()
#' 
#' # Initialize with custom file path
#' log_file <- file.path(tempdir(), "my_assessment.log")
#' initialize_logging(path = log_file, level = "INFO")
#' 
#' # Initialize with JSON format for automated processing
#' initialize_logging(
#'   path = "assessment_log.json",
#'   level = "DEBUG",
#'   format = "json",
#'   console_output = TRUE
#' )
#' 
#' # Check if logging is working
#' if (exists("log_print")) {
#'   log_print("Test message", level = "INFO")
#'   cat("Logging is active\n")
#' }
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{log_print}} for writing log entries
#'   \item \code{\link{launch_study}} for assessment execution with logging
#'   \item \code{logr} package for advanced logging features
#' }

#' Log Open
#'
#' Opens a log file connection.
#'
#' @param path File path for the log.
#' @return TRUE if successful, FALSE otherwise.
log_open <- function(path) {
  con <- try(file(path, open = "a"), silent = TRUE)
  if (inherits(con, "try-error")) return(FALSE)
  success <- try({
    writeLines(sprintf("[LOG START] %s", Sys.time()), con)
    close(con)
    TRUE
  }, silent = TRUE)
  if (inherits(success, "try-error")) return(FALSE)
  return(TRUE)
}


#' Select Next Item
#'
#' Selects the next item for administration in adaptive or non-adaptive mode.
#'
#' @param rv Reactive values object containing test state.
#' @param item_bank Data frame containing item parameters.
#' @param config Study configuration list.
#' @return Item index or NULL if no items remain.
#' @export
select_next_item <- function(rv, item_bank, config) {
  rv$item_counter <- rv$item_counter + 1
  if (length(rv$administered) >= config$max_items) {
    print("Maximum items reached")
    return(NULL)
  }
  
  # Non-adaptive mode: Use fixed order from item_groups or fixed_items
  if (!config$adaptive) {
    if (!is.null(config$fixed_items)) {
      if (rv$item_counter <= length(config$fixed_items)) {
        item <- config$fixed_items[rv$item_counter]
        print(sprintf("Selecting fixed item %d: %d", rv$item_counter, item))
        return(item)
      }
      print("No more fixed items available")
      return(NULL)
    }
    if (!is.null(config$item_groups)) {
      group_items <- unlist(config$item_groups)
      available <- setdiff(group_items, rv$administered)
      if (length(available) == 0 || rv$item_counter > length(group_items)) {
        print("No more items in item_groups")
        return(NULL)
      }
      item <- group_items[rv$item_counter]
      print(sprintf("Selecting item %d from group: %d", rv$item_counter, item))
      return(item)
    }
    available <- setdiff(seq_len(nrow(item_bank)), rv$administered)
    if (length(available) == 0 || rv$item_counter > length(available)) {
      print("No more items available")
      return(NULL)
    }
    item <- available[1]
    print(sprintf("Selecting item %d: %d", rv$item_counter, item))
    return(item)
  }
  
  # Adaptive mode
  if (!is.null(config$fixed_items) && rv$item_counter <= length(config$fixed_items)) {
    item <- config$fixed_items[rv$item_counter]
    print(sprintf("Selecting fixed item %d: %d", rv$item_counter, item))
    return(item)
  }
  available <- setdiff(seq_len(nrow(item_bank)), rv$administered)
  if (!is.null(config$item_groups)) {
    available <- intersect(available, unlist(config$item_groups))
  }
  if (length(available) == 0) {
    print("No more items available in specified groups")
    return(NULL)
  }
  if (rv$item_counter <= config$adaptive_start) {
    item <- sample(available, 1)
    print(sprintf("Selecting random item %d: %d", rv$item_counter, item))
    return(item)
  }
  
  item_info <- function(theta, item_idx) {
    cache_key <- paste(theta, item_idx, sep = ":")
    if (!is.null(rv$item_info_cache[[cache_key]])) {
      return(rv$item_info_cache[[cache_key]])
    }
    a <- item_bank$a[item_idx]
    b <- item_bank$b[item_idx] %||% 0
    c_param <- if (config$model == "3PL" && "c" %in% names(item_bank)) item_bank$c[item_idx] else 0
    b_thresholds <- if (config$model == "GRM") {
      b_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
      as.numeric(item_bank[item_idx, b_cols])
    } else NULL
    info <- if (config$model == "3PL") {
      p <- c_param + (1 - c_param) / (1 + exp(-a * (theta - b)))
      q <- 1 - p
      (a^2 * (p - c_param)^2 * q) / (p * (1 - c_param)^2)
    } else if (config$model == "GRM") {
      n_categories <- length(b_thresholds) + 1
      probs <- numeric(n_categories)
      probs[1] <- 1 / (1 + exp(a * (theta - b_thresholds[1])))
      for (k in 2:(n_categories - 1)) {
        probs[k] <- 1 / (1 + exp(a * (theta - b_thresholds[k - 1]))) -
          1 / (1 + exp(a * (theta - b_thresholds[k])))
      }
      probs[n_categories] <- 1 - 1 / (1 + exp(a * (theta - b_thresholds[n_categories - 1])))
      probs <- pmax(probs, 1e-10)
      probs <- probs / sum(probs)
      a^2 * sum(probs * (1 - probs))
    } else {
      p <- 1 / (1 + exp(-a * (theta - b)))
      a^2 * p * (1 - p)
    }
    rv$item_info_cache[[cache_key]] <- info
    info
  }
  
  group_weights <- if (!is.null(config$item_groups) && length(rv$administered) > 0) {
    group_counts <- table(sapply(rv$administered, function(i) {
      for (g in names(config$item_groups)) if (i %in% config$item_groups[[g]]) return(g)
      return("Other")
    }))
    weights <- 1 / (1 + (group_counts / max(1, length(rv$administered))))
    setNames(weights[names(config$item_groups)], names(config$item_groups))
  } else {
    setNames(rep(1, length(names(config$item_groups))), names(config$item_groups))
  }
  
  info <- vapply(available, function(i) item_info(rv$current_ability, i), numeric(1))
  if (config$criteria == "MI") {
    top_items <- available[info >= 0.95 * max(info, na.rm = TRUE)]
    item <- sample(top_items, 1)
  } else if (config$criteria == "RANDOM") {
    item <- sample(available, 1)
  } else if (config$criteria == "WEIGHTED") {
    group_indices <- sapply(available, function(i) {
      for (g in names(config$item_groups)) if (i %in% config$item_groups[[g]]) return(g)
      "Other"
    })
    probs <- info * (group_weights[group_indices] %||% 1) / sum(info * (group_weights[group_indices] %||% 1), na.rm = TRUE)
    item <- sample(available, 1, prob = probs)
  } else if (config$criteria == "MFI") {
    exposure <- table(rv$administered) / max(1, length(rv$administered))
    exposure_penalty <- vapply(available, function(i) {
      1 - 0.5 * (exposure[as.character(i)] %||% 0)
    }, numeric(1))
    adjusted_info <- info * exposure_penalty
    top_items <- available[adjusted_info >= 0.95 * max(adjusted_info, na.rm = TRUE)]
    item <- sample(top_items, 1)
  } else {
    top_items <- available[info >= 0.95 * max(info, na.rm = TRUE)]
    item <- sample(top_items, 1)
  }
  print(sprintf("Selected item %d with information %f", item, max(info, na.rm = TRUE)))
  item
}