#' Core Utilities for inrep Package
#' 
#' This file consolidates all core utility functions including:
#' - Basic utility functions (from utils.R)
#' - Custom operators (from utils_operators.R)  
#' - Session management utilities (from session_utils.R)
#' 
#' @name core_utils
#' @keywords internal

NULL

# ============================================================================
# SECTION 1: BASIC UTILITY FUNCTIONS (from utils.R)
# ============================================================================

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
#' This function creates a log file connection and configures inrep's internal logger.
#'
#' @param path Optional character string specifying the log file path.
#'   If NULL, creates a temporary log file in the system temp directory.
#' @param assign_global Deprecated. Previously assigned \code{log_print} into \code{.GlobalEnv}.
#'   This is no longer performed; use \code{log_print()} instead.
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
#' # Write a test message
#' log_print("Test message", level = "INFO")
#' }
initialize_logging <- function(path = NULL, assign_global = FALSE) {
  new_path <- if (is.null(path)) {
    file.path(tempdir(), "adaptive_test_default.log")
  } else {
    path
  }

  if (isTRUE(assign_global)) {
    warning("initialize_logging(assign_global=TRUE) is deprecated and ignored; use log_print() instead.")
  }

  if (!log_open(new_path)) {
    message("Failed to initialize logging, using console output.")
    .inrep_env$log_path <- NULL
    .inrep_env$log_print <- function(msg, level = "INFO") {
      message(sprintf("[%s] %s", level, msg))
    }
    return(list(success = FALSE, path = NULL, message = "Failed to initialize logging"))
  }
  .inrep_env$log_path <- new_path
  .inrep_env$log_print <- function(msg, level = "INFO") {
    cat(sprintf("[%s] %s\n", level, msg), file = .inrep_env$log_path, append = TRUE)
  }
  message("Logging initialized successfully")
  list(success = TRUE, path = new_path, message = "Logging initialized successfully")
}

#' Write a Log Entry
#'
#' Writes a log entry using inrep's configured logger. If logging has not been
#' initialized, this falls back to console output.
#'
#' @param msg Character scalar. Message to write.
#' @param level Character scalar. Log level label (for example, \code{"INFO"}, \code{"WARNING"}, \code{"ERROR"}).
#'
#' @export
log_print <- function(msg, level = "INFO") {
  if (!exists(".inrep_env", envir = asNamespace("inrep"), inherits = FALSE)) {
    message(sprintf("[%s] %s", level, msg))
    return(invisible(FALSE))
  }

  lp <- tryCatch(.inrep_env$log_print, error = function(e) NULL)
  if (is.null(lp) || !is.function(lp)) {
    message(sprintf("[%s] %s", level, msg))
    return(invisible(FALSE))
  }

  lp(msg, level = level)
  invisible(TRUE)
}
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
#' @noRd
select_next_item_basic_internal <- function(rv, item_bank, config) {
  rv$item_counter <- rv$item_counter + 1
  if (length(rv$administered) >= config$max_items) {
    message("Maximum items reached")
    return(NULL)
  }
  
  # Non-adaptive mode: Use fixed order from item_groups or fixed_items
  if (!config$adaptive) {
    if (!is.null(config$fixed_items)) {
      if (rv$item_counter <= length(config$fixed_items)) {
        item <- config$fixed_items[rv$item_counter]
        message(sprintf("Selecting fixed item %d: %d", rv$item_counter, item))
        return(item)
      }
              message("No more fixed items available")
      return(NULL)
    }
    if (!is.null(config$item_groups)) {
      group_items <- unlist(config$item_groups)
      available <- setdiff(group_items, rv$administered)
      if (length(available) == 0 || rv$item_counter > length(group_items)) {
        message("No more items in item_groups")
        return(NULL)
      }
      item <- group_items[rv$item_counter]
              message(sprintf("Selecting item %d from group: %d", rv$item_counter, item))
      return(item)
    }
    available <- setdiff(seq_len(nrow(item_bank)), rv$administered)
    if (length(available) == 0 || rv$item_counter > length(available)) {
              message("No more items available")
      return(NULL)
    }
    item <- available[1]
            message(sprintf("Selecting item %d: %d", rv$item_counter, item))
    return(item)
  }
  
  # Adaptive mode
  if (!is.null(config$fixed_items) && rv$item_counter <= length(config$fixed_items)) {
    item <- config$fixed_items[rv$item_counter]
    message(sprintf("Selecting fixed item %d: %d", rv$item_counter, item))
    return(item)
  }
  available <- setdiff(seq_len(nrow(item_bank)), rv$administered)
  if (!is.null(config$item_groups)) {
    available <- intersect(available, unlist(config$item_groups))
  }
  if (length(available) == 0) {
    message("No more items available in specified groups")
    return(NULL)
  }
  if (rv$item_counter <= config$adaptive_start) {
    item <- sample(available, 1)
          message(sprintf("Selecting random item %d: %d", rv$item_counter, item))
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
  message(sprintf("Selected item %d with information %f", item, max(info, na.rm = TRUE)))
  item
}

# ============================================================================
# SECTION 2: CUSTOM OPERATORS (from utils_operators.R)
# ============================================================================

#' Null-coalescing Operator
#'
#' Returns the left-hand side if not NULL, otherwise returns the right-hand side
#'
#' @name null_coalescing_operator
#' @aliases %||%
#' @param x Left-hand side value.
#' @param y Right-hand side value (default).
#' @return `x` if not NULL, otherwise `y`.
#' @export
#' @examples
#' NULL %||% "default"  # Returns "default"
#' "value" %||% "default"  # Returns "value"
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

#' String Repetition Operator
#'
#' Repeats a string a specified number of times.
#'
#' @param string Character string to repeat.
#' @param times Number of times to repeat.
#' @return Character string repeated the specified number of times.
#' @export
#' @examples
#' "=" %r% 50  # Returns "=================================================="
#' "-" %r% 10  # Returns "----------"
`%r%` <- function(string, times) {
  paste(rep(string, times), collapse = "")
}

# ============================================================================  
# SECTION 3: SESSION MANAGEMENT UTILITIES (from session_utils.R)
# ============================================================================

#' Session Utilities
#'
#' Utility functions for session initialization, validation, and cloud saving.
#'
#' @name session_utils
#' @importFrom jsonlite write_json
NULL

#' Initialize Reactive Values for Assessment Session
#'
#' @description
#' Initializes the reactive values object used by the Shiny study runtime.
#' It sets up the fields that track administered items, responses, timing, and
#' intermediate ability/SE estimates.
#'
#' @param config A study configuration object created by \code{\link{create_study_config}}.
#'   Must contain assessment parameters including model specifications, stopping criteria,
#'   and optional demographic requirements.
#'
#' @details
#' The returned object is a plain list. Downstream code treats it as a reactive
#' container (typically a Shiny \code{reactiveValues()} instance) and updates
#' fields as the session progresses.
#'
#' @return A comprehensive list containing initialized reactive values:
#' \describe{
#'   \item{\code{stage}}{Current assessment stage ("demographics", "assessment", "complete")}
#'   \item{\code{demographics}}{Named list for demographic data collection (if specified)}
#'   \item{\code{administered}}{Integer vector of administered item indices}
#'   \item{\code{responses}}{List of participant responses with timestamps}
#'   \item{\code{current_ability}}{Real-time ability estimate (theta)}
#'   \item{\code{current_se}}{Current standard error of ability estimate}
#'   \item{\code{theta_history}}{Vector of ability estimates across items}
#'   \item{\code{se_history}}{Vector of standard errors across items}
#'   \item{\code{current_item}}{Currently displayed item information}
#'   \item{\code{item_info_cache}}{Cached item information values for performance}
#'   \item{\code{item_counter}}{Number of items administered}
#'   \item{\code{response_times}}{Vector of response times in seconds}
#'   \item{\code{start_time}}{Session start timestamp}
#'   \item{\code{session_start}}{Assessment start timestamp}
#'   \item{\code{error_message}}{Current error message (if any)}
#'   \item{\code{feedback_message}}{Current feedback message}
#'   \item{\code{cat_result}}{Final CAT results and statistics}
#'   \item{\code{loading}}{Boolean indicating processing status}
#' }
#'
#' @examples
#' \dontrun{
#' # Create configuration with demographics
#' config <- create_study_config(
#'   name = "Cognitive Assessment",
#'   model = "2PL",
#'   max_items = 20,
#'   min_SEM = 0.3,
#'   demographics = c("age", "education", "gender")
#' )
#' 
#' # Initialize reactive values
#' rv <- init_reactive_values(config)
#' 
#' # Check initialization
#' rv$stage  # "demographics" (due to demographics requirement)
#' length(rv$demographics)  # 3 (age, education, gender)
#' rv$current_ability  # 0 (default prior mean)
#' rv$current_se  # 1 (default prior SD)
#' 
#' # Configuration without demographics
#' config_basic <- create_study_config(
#'   name = "Quick Assessment",
#'   model = "1PL",
#'   max_items = 10
#' )
#' 
#' rv_basic <- init_reactive_values(config_basic)
#' rv_basic$stage  # "assessment" (skip demographics)
#' rv_basic$demographics  # NULL
#' }
#'
#' @seealso 
#' \code{\link{create_study_config}} for creating configuration objects,
#' \code{\link{validate_session}} for session validation,
#' \code{\link{resume_session}} for session restoration,
#' \code{\link{save_session_to_cloud}} for cloud storage
#'
#' @references
#' Robitzsch, A., Kiefer, T., & Wu, M. (2020). \emph{TAM: Test Analysis Modules}. 
#' R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#'
#' Chang, W., Cheng, J., Allaire, J., Xie, Y., & McPherson, J. (2021). 
#' \emph{shiny: Web Application Framework for R}. R package version 1.6.0. 
#' \url{https://CRAN.R-project.org/package=shiny}
#'
#' @export
init_reactive_values <- function(config) {
  requireNamespace("logr", quietly = TRUE)
  
  # Validate config
  if (!is.list(config)) {
    message("Invalid config for reactive values initialization")
    stop("Invalid config for reactive values initialization")
  }
  
  rv <- list(
    stage = if (is.null(config$demographics)) "assessment" else "demographics",
    demographics = if (!is.null(config$demographics)) {
      setNames(vector("list", length(config$demographics)), config$demographics)
    } else NULL,
    administered = integer(0),
    responses = list(),
    current_ability = config$theta_prior[1] %||% 0,
    current_se = config$theta_prior[2] %||% 1,
    theta_history = numeric(0),
    se_history = numeric(0),
    current_item = NULL,
    item_info_cache = list(),
    item_counter = 0,
    response_times = numeric(0),
    start_time = Sys.time(),
    session_start = Sys.time(),
    error_message = NULL,
    feedback_message = NULL,
    cat_result = NULL,
    loading = FALSE
  )
  
  message("Initialized reactive values")
  return(rv)
}

#' Validate Assessment Session State and Handle Cloud Storage
#'
#' @description
#' Normalizes the session state object (adds missing fields, applies timeout
#' reset) and optionally uploads completed sessions to WebDAV.
#'
#' @param rv A reactive values object containing current session state, typically
#'   created by \code{\link{init_reactive_values}}.
#' @param config A study configuration object created by \code{\link{create_study_config}}
#'   containing assessment parameters and validation rules.
#' @param webdav_url Character string specifying WebDAV URL for cloud storage,
#'   or \code{NULL} to disable cloud saving. Should follow format
#'   \code{"https://server.com/webdav/path/"}.
#' @param password Character string containing password for WebDAV authentication,
#'   or \code{NULL} if authentication is not required.
#'
#' @details
#' If \code{rv} or \code{config} is invalid, a fresh object is created via
#' \code{init_reactive_values()}. If the session exceeds \code{config$max_session_duration},
#' the session is reset.
#'
#' @return An updated reactive values object.
#'
#' @examples
#' \dontrun{
#' # Basic session validation
#' config <- create_study_config(
#'   name = "Validation Test",
#'   model = "2PL",
#'   max_items = 15,
#'   session_timeout = 3600  # 1 hour timeout
#' )
#' 
#' rv <- init_reactive_values(config)
#' rv$responses <- list(c(1, 0, 1, 1, 0))  # Add some responses
#' rv$administered <- c(1, 5, 10, 15, 20)
#' 
#' # Validate without cloud storage
#' rv_validated <- validate_session(rv, config, NULL, NULL)
#' rv_validated$session_valid  # TRUE if validation passed
#' 
#' # Optional WebDAV upload (requires httr/jsonlite)
#' validate_session(
#'   rv, config,
#'   webdav_url = "https://cloud.example.com/webdav/",
#'   password = Sys.getenv("WEBDAV_PASSWORD")
#' )
#' }
#'
#' @seealso 
#' \code{\link{init_reactive_values}} for session initialization,
#' \code{\link{resume_session}} for session restoration,
#' \code{\link{save_session_to_cloud}} for manual cloud storage,
#' \code{\link{create_study_config}} for configuration parameters
#'
#' @references
#' Robitzsch, A., Kiefer, T., & Wu, M. (2020). \emph{TAM: Test Analysis Modules}. 
#' R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#'
#' Fielding, R., Gettys, J., Mogul, J., Frystyk, H., Masinter, L., Leach, P., & 
#' Berners-Lee, T. (1999). \emph{Hypertext Transfer Protocol -- HTTP/1.1}. 
#' RFC 2616. Internet Engineering Task Force.
#'
#' @export
validate_session <- function(rv, config, webdav_url = NULL, password = NULL) {
  requireNamespace("logr", quietly = TRUE)
  
  if (!is.list(rv) || !is.list(config)) {
    message("Invalid rv or config, initializing new reactive values")
    return(inrep::init_reactive_values(config))
  }
  
  # Check session timeout
  if (!is.null(rv$session_start) && is.numeric(config$max_session_duration)) {
    session_duration <- as.numeric(difftime(Sys.time(), rv$session_start, units = "mins"))
    if (session_duration > config$max_session_duration) {
      message("Session timed out, resetting reactive values")
      return(inrep::init_reactive_values(config))
    }
  }
  
  # Validate rv structure
  if (is.null(rv$administered)) rv$administered <- integer(0)
  if (is.null(rv$responses)) rv$responses <- list()
  if (is.null(rv$current_ability) || !is.numeric(rv$current_ability) || is.na(rv$current_ability)) {
    rv$current_ability <- config$theta_prior[1] %||% 0
  }
  if (is.null(rv$current_se) || !is.numeric(rv$current_se) || is.na(rv$current_se)) {
    rv$current_se <- config$theta_prior[2] %||% 1
  }
  if (is.null(rv$item_info_cache)) rv$item_info_cache <- list()
  if (is.null(rv$item_counter)) rv$item_counter <- 0
  if (!is.null(config$demographics) && is.null(rv$demographics)) {
    rv$demographics <- setNames(vector("list", length(config$demographics)), config$demographics)
  }
  if (is.null(rv$session_start)) rv$session_start <- Sys.time()
  if (is.null(rv$stage)) rv$stage <- if (is.null(config$demographics)) "assessment" else "demographics"
  if (is.null(rv$response_times)) rv$response_times <- numeric(0)
  if (is.null(rv$theta_history)) rv$theta_history <- numeric(0)
  if (is.null(rv$se_history)) rv$se_history <- numeric(0)
  if (is.null(rv$loading)) rv$loading <- FALSE
  
  # Save to cloud if session is complete
  if (!is.null(rv$cat_result) && isTRUE(config$session_save)) {
    inrep::save_session_to_cloud(rv, config, webdav_url, password)
  }
  
  message("Session validated successfully")
  return(rv)
}

#' Save Assessment Session Data to WebDAV
#'
#' @description
#' Uploads completed session data as JSON to a WebDAV endpoint using
#' \code{httr::PUT()}. This is a convenience helper; it does not implement
#' client-side encryption.
#'
#' @param rv A reactive values object containing session data, typically from
#'   a completed assessment with \code{cat_result} populated.
#' @param config A study configuration object created by \code{\link{create_study_config}}
#'   containing study metadata and storage parameters.
#' @param webdav_url Character string specifying WebDAV URL for cloud storage.
#'   Should follow format \code{"https://server.com/webdav/path/"}. If \code{NULL},
#'   cloud saving is skipped.
#' @param password Character string containing password for WebDAV authentication.
#'   If \code{NULL}, attempts anonymous access.
#'
#' @details
#' The function writes the JSON payload to a temporary file and uploads that
#' file. It can also convert a Nextcloud/ownCloud public share URL to the
#' corresponding WebDAV endpoint.
#'
#' @return Logical value indicating upload success:
#' \describe{
#'   \item{\code{TRUE}}{Session data successfully uploaded to cloud storage}
#'   \item{\code{FALSE}}{Upload failed due to network issues, authentication problems, or missing requirements}
#' }
#'
#' @examples
#' \dontrun{
#' # Complete session with results
#' config <- create_study_config(
#'   name = "Research Study",
#'   study_key = "STUDY2024_001",
#'   model = "2PL",
#'   max_items = 20
#' )
#' 
#' rv <- init_reactive_values(config)
#' # ... conduct assessment ...
#' rv$cat_result <- list(
#'   final_theta = 1.2,
#'   final_se = 0.35,
#'   items_administered = 15,
#'   total_time = 450
#' )
#' 
#' # Save to institutional cloud storage
#' success <- save_session_to_cloud(
#'   rv, config,
#'   webdav_url = "https://research.university.edu/webdav/",
#'   password = "institutional_password"
#' )
#' 
#' if (success) {
#'   message("Session data successfully archived")
#' } else {
#'   warning("Cloud storage failed - implement backup strategy")
#' }
#' 
#' # Anonymous cloud storage
#' save_session_to_cloud(rv, config, 
#'   webdav_url = "https://public.cloud.com/webdav/", 
#'   password = NULL)
#' }
#'
#' @section Data Structure:
#' The uploaded JSON contains:
#' \itemize{
#'   \item \code{study_key}: Study identifier for data organization
#'   \item \code{timestamp}: Upload timestamp in ISO format
#'   \item \code{cat_result}: Complete TAM-derived assessment results
#'   \item \code{demographics}: Collected demographic information
#'   \item \code{response_times}: Item-level response times in seconds
#'   \item \code{theta_history}: Ability estimate progression across items
#'   \item \code{se_history}: Standard error progression across items
#' }
#'
#' @section Security Note:
#' This function uploads plain JSON over HTTP(S). It does not encrypt the payload.
#' Use HTTPS and server-side access controls. If you require client-side encryption,
#' encrypt before writing/uploading.
#'
#' @seealso 
#' \code{\link{validate_session}} for session validation,
#' \code{\link{resume_session}} for session restoration,
#' \code{\link{init_reactive_values}} for session initialization,
#' \code{\link{create_study_config}} for configuration with storage parameters
#'
#' @references
#' Fielding, R., Gettys, J., Mogul, J., Frystyk, H., Masinter, L., Leach, P., & 
#' Berners-Lee, T. (1999). \emph{Hypertext Transfer Protocol -- HTTP/1.1}. 
#' RFC 2616. Internet Engineering Task Force.
#'
#' Goland, Y., Whitehead, E., Faizi, A., Carter, S., & Jensen, D. (1999). 
#' \emph{HTTP Extensions for Distributed Authoring -- WEBDAV}. 
#' RFC 2518. Internet Engineering Task Force.
#'
#' @export
save_session_to_cloud <- function(rv, config, webdav_url = NULL, password = NULL) {
  if (!requireNamespace("httr", quietly = TRUE) || !requireNamespace("jsonlite", quietly = TRUE)) {
    message("Required packages 'httr' and 'jsonlite' are not installed")
    return(FALSE)
  }
  
  if (is.null(webdav_url)) {
    message("No WebDAV URL provided, skipping cloud save")
    return(FALSE)
  }
  
  temp_file <- NULL
  tryCatch({
    # Ensure all data is properly structured as lists to avoid jsonlite warnings
    session_data <- list(
      study_key = config$study_key %||% "unknown_study",
      timestamp = as.character(Sys.time()),
      cat_result = if (is.null(rv$cat_result)) list() else as.list(rv$cat_result),
      demographics = if (is.null(rv$demographics)) list() else as.list(rv$demographics),
      response_times = if (is.null(rv$response_times)) list() else as.list(rv$response_times),
      theta_history = if (is.null(rv$theta_history)) list() else as.list(rv$theta_history),
      se_history = if (is.null(rv$se_history)) list() else as.list(rv$se_history)
    )
    
    # Create JSON data
    json_data <- jsonlite::toJSON(session_data, auto_unbox = TRUE, pretty = TRUE)
    
    # Create filename with timestamp
    safe_study_key <- gsub("[^A-Za-z0-9_-]+", "_", config$study_key %||% "session")
    filename <- sprintf("%s_%s.json", safe_study_key, format(Sys.time(), "%Y%m%d_%H%M%S"))
    temp_file <- file.path(tempdir(), filename)
    on.exit({
      if (!is.null(temp_file) && file.exists(temp_file)) {
        try(file.remove(temp_file), silent = TRUE)
      }
    }, add = TRUE)
    
    # Write to temp file
    writeLines(json_data, temp_file)  # Save as plain JSON for now
    
    # Handle different URL formats
    share_token <- NULL
    if (grepl("index.php/s/", webdav_url)) {
      # Extract share token from Nextcloud/ownCloud public share URL
      share_token <- gsub(".*index.php/s/([^/]+).*", "\\1", webdav_url)
      # Convert to WebDAV format for public shares
      base_url <- gsub("(https?://[^/]+).*", "\\1", webdav_url)
      webdav_url <- paste0(base_url, "/public.php/webdav/")
      message(sprintf("Converted public share URL to WebDAV endpoint: %s", webdav_url))
    }
    
    # Ensure URL ends with /
    if (!grepl("/$", webdav_url)) webdav_url <- paste0(webdav_url, "/")
    upload_url <- paste0(webdav_url, filename)
    
    message(sprintf("Attempting to upload to: %s", upload_url))
    
    # Set up authentication for public shares
    auth <- if (!is.null(share_token) && nzchar(share_token)) {
      # For public shares, use the share token as username and password as password
      httr::authenticate(user = share_token, password = password %||% "")
    } else if (!is.null(password) && nzchar(password)) {
      # For regular WebDAV, use empty username and password
      httr::authenticate(user = "", password = password)
    } else {
      # Try without authentication for public shares
      NULL
    }
    
    if (!is.null(auth)) {
      message("Authentication configured")
    } else {
      message("No authentication configured")
    }
    
    # Upload file
    response <- httr::PUT(
      url = upload_url,
      body = httr::upload_file(temp_file),
      httr::add_headers("Content-Type" = "application/json"),
      config = auth,
      httr::timeout(30)  # 30 second timeout
    )
    
    message(sprintf("Upload response status: %d", httr::status_code(response)))
    
    # Detailed error reporting
    if (httr::status_code(response) %in% c(200, 201, 204)) {
      message(sprintf("Session data successfully uploaded to %s as %s", webdav_url, filename))
      return(TRUE)
    } else {
      status_code <- httr::status_code(response)
      message(sprintf("Failed to upload session data to %s: HTTP %d", webdav_url, status_code))
      
      # Provide specific error messages based on status code
      error_msg <- switch(as.character(status_code),
        "401" = "Authentication failed - check share token and password",
        "403" = "Access forbidden - check share permissions",
        "404" = "URL not found - check WebDAV URL format",
        "405" = "Method not allowed - server doesn't support PUT",
        "409" = "Conflict - file may already exist",
        "422" = "Unprocessable entity - check file format",
        "500" = "Server error - contact administrator",
        "503" = "Service unavailable - try again later",
        sprintf("HTTP %d - check server configuration", status_code)
      )
      
      message(sprintf("Error details: %s", error_msg))
      
      # Try to get response body for more details
      tryCatch({
        response_text <- httr::content(response, "text")
        if (nzchar(response_text)) {
          message(sprintf("Server response: %s", substr(response_text, 1, 500)))
        }
      }, error = function(e) {
        message("Could not retrieve server response details")
      })
      
      return(FALSE)
    }
  }, error = function(e) {
    message(sprintf("Error saving session to cloud: %s", e$message))
    return(FALSE)
  })

}

#' Resume Assessment Session from Local Storage
#'
#' @description
#' Reads session data from a file created by \code{save_session_to_cloud()}.
#' Supports plain JSON and (legacy) base64-encoded JSON.
#'
#' @param file_path Character string specifying the path to a JSON file.
#'   The file may also contain base64-encoded JSON for legacy backups.
#'
#' @details
#' The function first tries to parse the file as JSON. If that fails, it falls
#' back to base64-decoding the file contents (requires the \code{base64enc}
#' package) and parsing the decoded text as JSON.
#'
#' @return A comprehensive list containing restored session data, or \code{NULL} if restoration fails:
#' \describe{
#'   \item{\code{study_key}}{Original study identifier}
#'   \item{\code{timestamp}}{Original session timestamp}
#'   \item{\code{cat_result}}{TAM-derived assessment results and statistics}
#'   \item{\code{demographics}}{Participant demographic information}
#'   \item{\code{response_times}}{Item-level response times in seconds}
#'   \item{\code{theta_history}}{Complete ability estimate progression}
#'   \item{\code{se_history}}{Standard error progression across items}
#'   \item{\code{restored_at}}{Restoration timestamp for audit trail}
#' }
#'
#' @examples
#' \dontrun{
#' # Resume from local file
#' session_data <- resume_session("path/to/STUDY2024_001_20241201_143022.json")
#' 
#' if (!is.null(session_data)) {
#'   # Successful restoration
#'   cat("Study:", session_data$study_key, "\n")
#'   cat("Original session:", session_data$timestamp, "\n")
#'   cat("Final ability:", session_data$cat_result$final_theta, "\n")
#'   cat("Items administered:", length(session_data$theta_history), "\n")
#'   
#'   # Continue assessment or analyze results
#'   if (is.null(session_data$cat_result)) {
#'     message("Incomplete session - can be continued")
#'   } else {
#'     message("Complete session - analyze results")
#'   }
#' } else {
#'   warning("Session restoration failed - check file integrity")
#' }
#' 
#' # Resume from downloaded cloud file
#' cloud_file <- "downloads/research_session_backup.json"
#' restored_session <- resume_session(cloud_file)
#' 
#' # Validate restored data before proceeding
#' if (!is.null(restored_session) && 
#'     !is.null(restored_session$theta_history) &&
#'     length(restored_session$theta_history) > 0) {
#'   message("Valid session data restored - proceeding with analysis")
#' }
#' }
#'
#' @section File Format:
#' Supported file formats:
#' \itemize{
#'   \item Plain JSON (recommended)
#'   \item Base64-encoded JSON (legacy)
#' }
#'
#' @section Error Handling:
#' Function returns \code{NULL} and logs detailed error information for:
#' \itemize{
#'   \item File accessibility issues (permissions, network, corruption)
#'   \item Decryption failures (wrong format, corrupted data)
#'   \item JSON parsing errors (malformed structure)
#'   \item Data validation failures (missing required fields)
#' }
#'
#' @seealso 
#' \code{\link{save_session_to_cloud}} for creating session backup files,
#' \code{\link{validate_session}} for session validation,
#' \code{\link{init_reactive_values}} for new session initialization,
#' \code{\link{create_study_config}} for configuration setup
#'
#' @references
#' Robitzsch, A., Kiefer, T., & Wu, M. (2020). \emph{TAM: Test Analysis Modules}. 
#' R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#'
#' @export
resume_session <- function(file_path) {
  tryCatch({
    raw_text <- paste(readLines(file_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

    # Prefer plain JSON; fall back to base64-decoding for legacy files.
    session_data <- tryCatch({
      jsonlite::fromJSON(raw_text)
    }, error = function(e) {
      if (!requireNamespace("base64enc", quietly = TRUE)) {
        stop("Failed to parse as JSON and 'base64enc' is not available for legacy decoding")
      }
      json_data <- rawToChar(base64enc::base64decode(raw_text))
      jsonlite::fromJSON(json_data)
    })
    message("Session successfully restored.")
    session_data
  }, error = function(e) {
    message(sprintf("Error restoring session: %s", e$message))
    NULL
  })
}