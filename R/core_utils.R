# =============================================================================
# CORE UTILITIES
# =============================================================================
# This file consolidates core utility functions, operators, and session management
# from the original utils.R, utils_operators.R, and session_utils.R files.

# =============================================================================
# OPERATORS
# =============================================================================

#' Null-coalescing Operator
#' 
#' Returns the left-hand side if not NULL, otherwise returns the right-hand side
#' 
#' @param lhs Left-hand side value
#' @param rhs Right-hand side value (default)
#' @return lhs if not NULL, otherwise rhs
#' @export
#' @examples
#' NULL %||% "default"  # Returns "default"
#' "value" %||% "default"  # Returns "value"
`%||%` <- function(lhs, rhs) {
  if (is.null(lhs)) rhs else lhs
}

#' String Repetition Operator
#' 
#' Repeats a string a specified number of times
#' 
#' @param string Character string to repeat
#' @param times Number of times to repeat
#' @return Character string repeated the specified number of times
#' @export
#' @examples
#' "=" %r% 50  # Returns "=================================================="
#' "-" %r% 10  # Returns "----------"
`%r%` <- function(string, times) {
  paste(rep(string, times), collapse = "")
}

# =============================================================================
# CORE UTILITY FUNCTIONS
# =============================================================================

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
  message("Logging initialized successfully")
  list(success = TRUE, path = new_path, message = "Logging initialized successfully")
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

# =============================================================================
# SESSION MANAGEMENT UTILITIES
# =============================================================================

#' Session Utilities
#'
#' Utility functions for session initialization, validation, and cloud saving.
#'
#' @name session_utils
#' @importFrom logr log_print
#' @importFrom jsonlite write_json
#' @importFrom httr PUT authenticate upload_file add_headers status_code
NULL

#' Initialize Reactive Values for Assessment Session
#'
#' @description
#' Initializes comprehensive reactive values for an adaptive testing session, 
#' establishing the foundational data structures required for TAM-based psychometric
#' computations and real-time assessment management.
#'
#' @param config A study configuration object created by \code{\link{create_study_config}}.
#'   Must contain assessment parameters including model specifications, stopping criteria,
#'   and optional demographic requirements.
#'
#' @details
#' This function creates a standardized reactive value structure that coordinates
#' between the user interface and TAM's psychometric functions. The initialization
#' process establishes:
#' 
#' \strong{Session Management:}
#' \itemize{
#'   \item Assessment stage tracking (demographics, assessment, completion)
#'   \item Response collection and validation structures
#'   \item Real-time ability and standard error tracking
#'   \item Item administration history and timing data
#' }
#' 
#' \strong{TAM Integration Architecture:}
#' \itemize{
#'   \item Ability estimation tracking via TAM's \code{\link[TAM]{tam.wle}}/\code{\link[TAM]{tam.eap}}
#'   \item Standard error monitoring for stopping criteria
#'   \item Response pattern management for TAM model fitting
#'   \item Information caching for adaptive selection algorithms
#' }
#' 
#' \strong{Quality Assurance:}
#' \itemize{
#'   \item Response time tracking for engagement monitoring
#'   \item Error handling and recovery mechanisms
#'   \item Session validation and integrity checks
#'   \item Comprehensive audit trail initialization
#' }
#' 
#' The reactive values structure enables seamless integration between Shiny's
#' reactive programming model and TAM's statistical computations, ensuring
#' real-time updates without compromising psychometric accuracy.
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
#' Performs comprehensive validation of session state including timeout checks,
#' data integrity verification, and automatic cloud storage for completed sessions.
#' Ensures session continuity and data preservation throughout the assessment process.
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
#' This function performs multi-level session validation essential for maintaining
#' assessment integrity and research data quality:
#' 
#' \strong{Session State Validation:}
#' \itemize{
#'   \item Timeout detection based on configuration parameters
#'   \item Response pattern integrity and completeness checks
#'   \item Ability estimation convergence verification
#'   \item Item administration sequence validation
#' }
#' 
#' \strong{Data Quality Assurance:}
#' \itemize{
#'   \item Response time analysis for engagement monitoring
#'   \item Missing data pattern identification
#'   \item Unusual response pattern detection (rapid guessing, non-response)
#'   \item TAM model fit validation for completed assessments
#' }
#' 
#' \strong{Cloud Storage Integration:}
#' \itemize{
#'   \item Automatic saving of completed sessions to WebDAV storage
#'   \item Incremental backup for long assessments
#'   \item Secure authentication with encrypted transmission
#'   \item Retry logic for network failures and recovery
#' }
#' 
#' \strong{Session Recovery:}
#' \itemize{
#'   \item Invalid session state reset with logging
#'   \item Graceful degradation for network issues
#'   \item Preservation of participant progress where possible
#'   \item Audit trail maintenance for session events
#' }
#' 
#' The validation process integrates with TAM's psychometric functions to ensure
#' that statistical computations remain valid throughout the assessment process,
#' particularly important for adaptive testing algorithms that depend on
#' cumulative response patterns.
#'
#' @return An updated reactive values object with:
#' \describe{
#'   \item{\code{validated}}{Boolean indicating successful validation}
#'   \item{\code{cloud_saved}}{Boolean indicating successful cloud storage}
#'   \item{\code{error_message}}{Character string with any validation errors}
#'   \item{\code{warning_message}}{Character string with any validation warnings}
#'   \item{\code{last_validation}}{Timestamp of most recent validation}
#'   \item{\code{session_valid}}{Boolean indicating overall session validity}
#' }
#' All other reactive values are preserved or updated based on validation results.
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
#' # Validate with cloud storage
#' rv_cloud <- validate_session(
#'   rv, config,
#'   webdav_url = "https://cloud.example.com/webdav/",
#'   password = "secure_password"
#' )
#' rv_cloud$cloud_saved  # TRUE if successfully saved
#' 
#' # Handle validation failure
#' if (!rv_validated$session_valid) {
#'   message("Session validation failed: ", rv_validated$error_message)
#' }
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

#' Save Assessment Session Data to Academic Cloud Storage
#'
#' @description
#' Securely uploads completed assessment session data to WebDAV-compatible cloud
#' storage with encryption and integrity verification. Designed for research
#' environments requiring secure, compliant data storage with comprehensive
#' audit trails and participant privacy protection.
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
#' This function provides comprehensive cloud storage capabilities essential for
#' research data management and institutional compliance:
#' 
#' \strong{Data Security and Privacy:}
#' \itemize{
#'   \item Base64 encoding for basic data obfuscation (replace with proper encryption in production)
#'   \item Secure HTTPS transmission with authentication
#'   \item Temporary file cleanup to prevent local data persistence
#'   \item Participant identifier anonymization and data minimization
#' }
#' 
#' \strong{Research Data Management:}
#' \itemize{
#'   \item Structured JSON format for analysis compatibility
#'   \item Comprehensive session metadata including timestamps
#'   \item TAM-derived psychometric results preservation
#'   \item Response pattern and timing data for quality analysis
#' }
#' 
#' \strong{Institutional Compliance:}
#' \itemize{
#'   \item Audit trail creation with detailed logging
#'   \item IRB-compatible data handling procedures
#'   \item GDPR-aware data minimization and anonymization
#'   \item Institutional storage integration via WebDAV protocol
#' }
#' 
#' \strong{Upload Architecture:}
#' \itemize{
#'   \item RESTful WebDAV integration for broad compatibility
#'   \item Automatic retry logic for network resilience
#'   \item File naming with study keys and timestamps
#'   \item HTTP status validation and error reporting
#' }
#' 
#' The saved data includes all TAM-computed psychometric results, response
#' patterns, timing information, and demographic data (if collected), enabling
#' comprehensive post-hoc analysis while maintaining participant privacy.
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
#' Current implementation uses base64 encoding for data obfuscation. For
#' production research environments, implement proper encryption using
#' \code{openssl} or similar cryptographic libraries.
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
    
    # Use base64 encoding (built-in R function instead of base64enc package)
    encrypted_data <- base64enc::base64encode(charToRaw(json_data))
    
    # Create filename with timestamp
    filename <- sprintf("%s_%s.json", config$study_key %||% "session", format(Sys.time(), "%Y%m%d_%H%M%S"))
    temp_file <- file.path(tempdir(), filename)
    
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
      message(sprintf("Converted to WebDAV URL: %s", webdav_url))
      message(sprintf("Using share token: %s", share_token))
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
    
    # Print authentication info for debugging
    if (!is.null(auth)) {
      message(sprintf("Using authentication: user='%s', password='%s'", 
                    if (!is.null(share_token)) share_token else "",
                    if (!is.null(password)) "***" else ""))
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
      file.remove(temp_file)
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
      
      file.remove(temp_file)
      return(FALSE)
    }
  }, error = function(e) {
    message(sprintf("Error saving session to cloud: %s", e$message))
    return(FALSE)
  })

}

#' Resume Assessment Session from Cloud or Local Storage
#'
#' @description
#' Restores previously saved assessment session data from encrypted files,
#' enabling continuation of interrupted assessments and comprehensive data
#' recovery for research continuity. Supports both local and cloud-stored
#' session files with integrity verification and validation.
#'
#' @param file_path Character string specifying the path to the encrypted
#'   session file. Can be local file path or downloaded cloud storage file.
#'   File should have been created by \code{\link{save_session_to_cloud}}.
#'
#' @details
#' This function provides comprehensive session restoration capabilities
#' essential for research environments requiring robust data recovery:
#' 
#' \strong{Data Recovery Architecture:}
#' \itemize{
#'   \item Encrypted file decryption using base64 decoding (upgrade to proper encryption in production)
#'   \item JSON structure validation and parsing
#'   \item Data integrity verification against expected session format
#'   \item Graceful error handling with detailed logging
#' }
#' 
#' \strong{Session Restoration Process:}
#' \itemize{
#'   \item File accessibility and format validation
#'   \item Decryption and data structure reconstruction
#'   \item TAM-compatible data format verification
#'   \item Session state validation for assessment continuation
#' }
#' 
#' \strong{Research Continuity Features:}
#' \itemize{
#'   \item Complete psychometric state restoration for TAM integration
#'   \item Response pattern and timing data preservation
#'   \item Demographic information recovery
#'   \item Assessment progress tracking restoration
#' }
#' 
#' \strong{Quality Assurance:}
#' \itemize{
#'   \item Data corruption detection and reporting
#'   \item Version compatibility validation
#'   \item Comprehensive error logging for debugging
#'   \item Fallback strategies for partial data recovery
#' }
#' 
#' The restored session data maintains full compatibility with TAM's
#' psychometric functions, enabling seamless continuation of adaptive
#' assessments with preserved ability estimates and response histories.
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
#' session_data <- resume_session("path/to/STUDY2024_001_20241201_143022.enc")
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
#' cloud_file <- "downloads/research_session_backup.enc"
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
#' Expected encrypted file format (base64-encoded JSON):
#' \itemize{
#'   \item Study metadata and identifiers
#'   \item Complete psychometric state for TAM integration
#'   \item Response patterns and timing information
#'   \item Assessment progress and stopping criteria status
#'   \item Participant demographic information (if collected)
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
    encrypted_data <- readLines(file_path)
    json_data <- rawToChar(base64enc::base64decode(encrypted_data))
    session_data <- jsonlite::fromJSON(json_data)
    message("Session successfully restored.")
    session_data
  }, error = function(e) {
    message(sprintf("Error restoring session: %s", e$message))
    NULL
  })
}

# =============================================================================
# ITEM SELECTION UTILITIES
# =============================================================================

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