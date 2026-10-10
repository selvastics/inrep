#' Core utilities
#'
#' Identifiers, logging, the session state list, and saving and reading
#' session files.
#'
#' @name core_utils
#' @keywords internal

NULL

# Utilities ----

#' Generate UUID
#'
#' Returns a random identifier in UUID version 4 format, drawn with
#' \code{sample()}. It therefore uses and advances R's random number
#' generator: after the same \code{set.seed()} the same identifiers are
#' produced. It is not suitable as a secret.
#'
#' @return Character string in UUID format.
#' @export
generate_uuid <- function() {
  hex <- c(0:9, "a", "b", "c", "d", "e", "f")
  paste0(
    paste0(sample(hex, 8, replace = TRUE), collapse = ""), "-",
    paste0(sample(hex, 4, replace = TRUE), collapse = ""), "-",
    "4", paste0(sample(hex, 3, replace = TRUE), collapse = ""), "-",
    sample(c("8", "9", "a", "b"), 1), paste0(sample(hex, 3, replace = TRUE), collapse = ""), "-",
    paste0(sample(hex, 12, replace = TRUE), collapse = "")
  )
}

#' Initialize Logging System
#'
#' Checks that the log file can be written and sets \code{log_print()} to
#' append lines to it.
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


# Operators ----

# Null-coalescing operator. Base R has %||% only from R 4.4.0, so the
# package defines its own.
#' @keywords internal
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

# Session utilities ----

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
#' @return A list containing initialized reactive values:
#' \describe{
#'   \item{\code{stage}}{Current assessment stage ("demographics", "assessment", "complete")}
#'   \item{\code{demographics}}{Named list for demographic data collection (if specified)}
#'   \item{\code{administered}}{Integer vector of administered item indices}
#'   \item{\code{responses}}{List of participant responses with timestamps}
#'   \item{\code{current_ability}}{Current ability estimate (theta); starts at the prior mean}
#'   \item{\code{current_se}}{Current standard error of ability estimate}
#'   \item{\code{theta_history}}{Vector of ability estimates across items}
#'   \item{\code{se_history}}{Vector of standard errors across items}
#'   \item{\code{current_item}}{Currently displayed item information}
#'   \item{\code{item_info_cache}}{Cache for item information values}
#'   \item{\code{item_counter}}{Number of items administered}
#'   \item{\code{response_times}}{Vector of response times in seconds}
#'   \item{\code{start_time}}{Session start timestamp}
#'   \item{\code{session_start}}{Assessment start timestamp}
#'   \item{\code{error_message}}{Current error message (if any)}
#'   \item{\code{feedback_message}}{Current feedback message}
#'   \item{\code{cat_result}}{Final results (NULL until the assessment ends)}
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
#' @export
init_reactive_values <- function(config) {
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
#' @param webdav_url WebDAV address(es) for cloud storage, or \code{NULL} to
#'   disable cloud saving. Any form accepted by \code{\link{webdav_upload}}.
#' @param password Character string containing password for WebDAV authentication,
#'   or \code{NULL} if authentication is not required.
#' @param share_token Token of a public Nextcloud/ownCloud share. Only needed
#'   when \code{webdav_url} is a bare \code{.../public.php/webdav/} address;
#'   share links contain the token already. See \code{\link{webdav_upload}}.
#'
#' @details
#' If \code{rv} or \code{config} is invalid, a fresh object is created via
#' \code{init_reactive_values()}. If the session has lasted longer than
#' \code{config$max_session_duration} minutes, it is reset, and the responses
#' collected so far are dropped from the returned object.
#' The upload runs only when \code{rv$cat_result} is set and
#' \code{config$session_save} is \code{TRUE}.
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
#'   max_session_duration = 60  # minutes
#' )
#'
#' rv <- init_reactive_values(config)
#' rv$responses <- list(c(1, 0, 1, 1, 0))  # Add some responses
#' rv$administered <- c(1, 5, 10, 15, 20)
#'
#' # Validate without cloud storage
#' rv_validated <- validate_session(rv, config, NULL, NULL)
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
#' @export
validate_session <- function(rv, config, webdav_url = NULL, password = NULL, share_token = NULL) {
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
    inrep::save_session_to_cloud(rv, config, webdav_url, password, share_token = share_token)
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
#' @param webdav_url Where to store the file: a Nextcloud/ownCloud share link,
#'   a public share WebDAV address, or any WebDAV folder URL. Several URLs may
#'   be given and are tried in order. See \code{\link{webdav_upload}} for the
#'   accepted forms. If \code{NULL}, cloud saving is skipped.
#' @param password Share password (public shares) or account/app password
#'   (plain WebDAV). \code{NULL} or \code{""} for no password.
#' @param session Optional Shiny session object. When provided, upload success or
#'   failure will be shown to the user via \code{shiny::showNotification()}.
#' @param share_token Token of a public share. Only needed when
#'   \code{webdav_url} is a bare \code{.../public.php/webdav/} address; share
#'   links contain the token already.
#' @param user User name for a plain (non-share) WebDAV folder.
#'
#' @details
#' Writes the JSON payload to a temporary file and uploads it with
#' \code{\link{webdav_upload}}, which handles share links, upload-only
#' shares, plain WebDAV servers and fallback hosts.
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
#'   \item \code{timestamp}: Upload time (local time, \code{"YYYY-MM-DD HH:MM:SS"})
#'   \item \code{cat_result}: \code{rv$cat_result} (final estimate and SE, as stored by the study)
#'   \item \code{demographics}: \code{rv$demo_data}
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
#' @export
save_session_to_cloud <- function(rv, config, webdav_url = NULL, password = NULL, session = NULL,
                                  share_token = NULL, user = NULL) {
  # Helper to notify user in Shiny UI (if session is available)
  notify_user <- function(msg, type = "error") {
    if (!is.null(session) && inherits(session, "ShinySession")) {
      tryCatch(
        shiny::showNotification(msg, type = type, duration = if (type == "error") 10 else 5),
        error = function(e) NULL
      )
    }
  }

  if (!requireNamespace("httr", quietly = TRUE) || !requireNamespace("jsonlite", quietly = TRUE)) {
    message("Required packages 'httr' and 'jsonlite' are not installed")
    notify_user("Cloud upload failed: required packages 'httr' and 'jsonlite' are not installed.")
    return(FALSE)
  }
  
  if (is.null(webdav_url)) {
    message("No WebDAV URL provided, skipping cloud save")
    return(FALSE)
  }

  # Store filename for notification messages
  upload_filename <- NULL
  
  temp_file <- NULL
  tryCatch({
    # Ensure all data is properly structured as lists to avoid jsonlite warnings
    session_data <- list(
      study_key = config$study_key %||% "unknown_study",
      timestamp = as.character(Sys.time()),
      cat_result = if (is.null(rv$cat_result)) list() else as.list(rv$cat_result),
      demographics = if (is.null(rv$demo_data)) list() else as.list(rv$demo_data),
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
    
    # Write to temp file as UTF-8
    con <- file(temp_file, open = "w", encoding = "UTF-8")
    writeLines(json_data, con)
    close(con)
    
    # All URL handling (share links, public share endpoints, plain WebDAV
    # folders, several hosts) lives in webdav_upload().
    ok <- webdav_upload(
      content = readBin(temp_file, "raw", file.info(temp_file)$size),
      filename = filename,
      url = webdav_url,
      password = password,
      share_token = share_token,
      user = user,
      content_type = "application/json; charset=utf-8"
    )
    upload_filename <- filename

    if (isTRUE(ok)) {
      notify_user(
        paste0("Data uploaded (file: ", filename, ")"),
        type = "message"
      )
      return(TRUE)
    }
    tried <- attr(ok, "attempts")
    last_status <- if (nrow(tried)) utils::tail(stats::na.omit(tried$status), 1) else integer(0)
    notify_user(
      paste0("Cloud upload failed",
             if (length(last_status)) paste0(" (HTTP ", last_status, ")") else "",
             ". See the R console for details."),
      type = "error"
    )
    return(FALSE)
  }, error = function(e) {
    message(sprintf("Error saving session to cloud: %s", e$message))
    notify_user(
      paste0("Cloud upload failed: ", e$message),
      type = "error"
    )
    return(FALSE)
  })

}

#' Read a saved session file
#'
#' @description
#' Reads session data from a JSON file as written by
#' \code{save_session_to_cloud()}. Supports plain JSON and (legacy)
#' base64-encoded JSON. It returns the data only; it does not restart or
#' continue a Shiny session.
#'
#' @param file_path Character string specifying the path to a JSON file.
#'   The file may also contain base64-encoded JSON for legacy backups.
#'
#' @details
#' The function first tries to parse the file as JSON. If that fails, it falls
#' back to base64-decoding the file contents (requires the \code{base64enc}
#' package) and parsing the decoded text as JSON.
#'
#' @return The parsed JSON as a list, or \code{NULL} if reading or parsing
#'   fails. For files from \code{save_session_to_cloud()} it contains
#'   \code{study_key}, \code{timestamp}, \code{cat_result},
#'   \code{demographics}, \code{response_times}, \code{theta_history} and
#'   \code{se_history}. The content is not checked.
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
#' If the file cannot be read or parsed, the error message is printed with
#' \code{message()} and \code{NULL} is returned.
#'
#' @seealso
#' \code{\link{save_session_to_cloud}} for creating session backup files,
#' \code{\link{validate_session}} for session validation,
#' \code{\link{init_reactive_values}} for new session initialization,
#' \code{\link{create_study_config}} for configuration setup
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

#' End one participant's session
#'
#' Closes only the given Shiny session, so other participants on the same
#' deployed app (e.g. shinyapps.io) keep running. Set
#' \code{options(inrep.stop_app_on_finish = TRUE)} to stop the whole app
#' instead, which is only sensible for single-user local runs.
#' @noRd
.inrep_end_session <- function(session) {
  if (isTRUE(getOption("inrep.stop_app_on_finish", FALSE))) {
    try(shiny::stopApp(), silent = TRUE)
    return(invisible(NULL))
  }
  if (!is.null(session)) try(session$close(), silent = TRUE)
  invisible(NULL)
}
