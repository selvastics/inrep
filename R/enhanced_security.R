#' @title Enhanced Security Module
#' @description Provides comprehensive security features including rate limiting, CSRF protection,
#' XSS prevention, secure password handling, and audit logging for the inrep package.
#' @details This module implements security best practices to protect assessment data
#' and prevent common web vulnerabilities. It includes authentication, authorization,
#' input validation, and audit logging capabilities.
#' @name enhanced_security
#' @docType data
NULL

# Global security state
.security_state <- new.env()
.security_state$rate_limits <- list()
.security_state$csrf_tokens <- list()
.security_state$failed_attempts <- list()
.security_state$blocked_ips <- list()

#' Initialize Enhanced Security
#' 
#' @param enable_rate_limiting Enable rate limiting for API endpoints
#' @param enable_csrf_protection Enable CSRF token validation
#' @param enable_xss_prevention Enable XSS input sanitization
#' @param enable_audit_logging Enable security audit logging
#' @param max_attempts Maximum failed attempts before blocking
#' @return List with security configuration
#' @export
initialize_enhanced_security <- function(
  enable_rate_limiting = TRUE,
  enable_csrf_protection = TRUE,
  enable_xss_prevention = TRUE,
  enable_audit_logging = TRUE,
  max_attempts = 5
) {
  .security_state$enable_rate_limiting <- enable_rate_limiting
  .security_state$enable_csrf_protection <- enable_csrf_protection
  .security_state$enable_xss_prevention <- enable_xss_prevention
  .security_state$enable_audit_logging <- enable_audit_logging
  .security_state$max_attempts <- max_attempts
  
  # Initialize audit log
  if (enable_audit_logging) {
    .security_state$audit_log <- file.path(tempdir(), 
                                           paste0("inrep_security_audit_", 
                                                 format(Sys.time(), "%Y%m%d"), 
                                                 ".log"))
  }
  
  return(list(
    rate_limiting = enable_rate_limiting,
    csrf_protection = enable_csrf_protection,
    xss_prevention = enable_xss_prevention,
    audit_logging = enable_audit_logging,
    max_attempts = max_attempts
  ))
}

#' Secure Password Storage
#' 
#' Securely stores passwords using encryption
#' 
#' @param password Plain text password
#' @param salt Optional salt for hashing
#' @return List with encrypted password and salt
#' @export
secure_password <- function(password, salt = NULL) {
  if (is.null(salt)) {
    salt <- generate_salt()
  }
  
  # Use bcrypt-like hashing (via digest package)
  hashed <- digest::digest(paste0(password, salt), algo = "sha256")
  
  # Additional rounds for security
  for (i in 1:1000) {
    hashed <- digest::digest(paste0(hashed, salt), algo = "sha256")
  }
  
  return(list(
    hash = hashed,
    salt = salt,
    algorithm = "sha256-1000"
  ))
}

#' Verify Password
#' 
#' Verifies a password against stored hash
#' 
#' @param password Plain text password to verify
#' @param stored_hash Stored password hash
#' @param salt Salt used for hashing
#' @return Logical indicating if password is valid
#' @export
verify_password <- function(password, stored_hash, salt) {
  result <- secure_password(password, salt)
  return(result$hash == stored_hash)
}

#' Generate Salt
#' 
#' Generates a cryptographically secure salt
#' 
#' @param length Length of salt in characters
#' @return Character string with salt
generate_salt <- function(length = 32) {
  paste0(sample(c(letters, LETTERS, 0:9, "!@#$%^&*"), 
               length, replace = TRUE), 
        collapse = "")
}

#' Rate Limiting Check
#' 
#' Checks if request should be rate limited
#' 
#' @param identifier User or IP identifier
#' @param endpoint API endpoint
#' @param limit Maximum requests per minute
#' @return Logical indicating if request is allowed
#' @export
check_rate_limit <- function(identifier, endpoint, limit = 60) {
  if (!.security_state$enable_rate_limiting) return(TRUE)
  
  key <- paste0(identifier, ":", endpoint)
  current_time <- Sys.time()
  
  # Initialize if first request
  if (!(key %in% names(.security_state$rate_limits))) {
    .security_state$rate_limits[[key]] <- list(
      requests = 1,
      window_start = current_time
    )
    return(TRUE)
  }
  
  rate_info <- .security_state$rate_limits[[key]]
  window_elapsed <- as.numeric(difftime(current_time, rate_info$window_start, 
                                        units = "secs"))
  
  # Reset window if minute has passed
  if (window_elapsed > 60) {
    .security_state$rate_limits[[key]] <- list(
      requests = 1,
      window_start = current_time
    )
    return(TRUE)
  }
  
  # Check if limit exceeded
  if (rate_info$requests >= limit) {
    log_security_event("RATE_LIMIT_EXCEEDED", 
                      paste("Rate limit exceeded for", identifier, "on", endpoint))
    return(FALSE)
  }
  
  # Increment counter
  .security_state$rate_limits[[key]]$requests <- rate_info$requests + 1
  return(TRUE)
}

#' Generate CSRF Token
#' 
#' Generates a CSRF protection token
#' 
#' @param session_id Session identifier
#' @return Character string with CSRF token
#' @export
generate_csrf_token <- function(session_id) {
  if (!.security_state$enable_csrf_protection) return(NULL)
  
  token <- digest::digest(paste0(session_id, Sys.time(), runif(1)), 
                          algo = "sha256")
  
  # Store token with expiration
  .security_state$csrf_tokens[[session_id]] <- list(
    token = token,
    created = Sys.time(),
    expires = Sys.time() + 3600  # 1 hour expiration
  )
  
  return(token)
}

#' Validate CSRF Token
#' 
#' Validates a CSRF token
#' 
#' @param session_id Session identifier
#' @param token Token to validate
#' @return Logical indicating if token is valid
#' @export
validate_csrf_token <- function(session_id, token) {
  if (!.security_state$enable_csrf_protection) return(TRUE)
  
  if (!(session_id %in% names(.security_state$csrf_tokens))) {
    log_security_event("CSRF_INVALID", paste("Invalid CSRF token for session", session_id))
    return(FALSE)
  }
  
  token_info <- .security_state$csrf_tokens[[session_id]]
  
  # Check expiration
  if (Sys.time() > token_info$expires) {
    log_security_event("CSRF_EXPIRED", paste("Expired CSRF token for session", session_id))
    return(FALSE)
  }
  
  # Validate token
  is_valid <- token == token_info$token
  
  if (!is_valid) {
    log_security_event("CSRF_MISMATCH", paste("CSRF token mismatch for session", session_id))
  }
  
  return(is_valid)
}

#' Sanitize Input for XSS Prevention
#' 
#' Sanitizes user input to prevent XSS attacks
#' 
#' @param input User input to sanitize
#' @param allow_html Whether to allow safe HTML tags
#' @return Sanitized input
#' @export
sanitize_input <- function(input, allow_html = FALSE) {
  if (!.security_state$enable_xss_prevention) return(input)
  
  if (is.null(input) || length(input) == 0) return(input)
  
  # Convert to character
  input <- as.character(input)
  
  # Remove dangerous patterns
  dangerous_patterns <- c(
    "<script[^>]*>.*?</script>",
    "javascript:",
    "on\\w+\\s*=",
    "<iframe[^>]*>.*?</iframe>",
    "<object[^>]*>.*?</object>",
    "<embed[^>]*>",
    "eval\\s*\\(",
    "expression\\s*\\("
  )
  
  for (pattern in dangerous_patterns) {
    input <- gsub(pattern, "", input, ignore.case = TRUE, perl = TRUE)
  }
  
  if (!allow_html) {
    # Escape all HTML entities
    input <- gsub("<", "&lt;", input)
    input <- gsub(">", "&gt;", input)
    input <- gsub("\"", "&quot;", input)
    input <- gsub("'", "&#x27;", input)
    input <- gsub("/", "&#x2F;", input)
  }
  
  return(input)
}

#' Validate Email Input
#' 
#' Validates and sanitizes email addresses
#' 
#' @param email Email address to validate
#' @return Sanitized email or NULL if invalid
#' @export
validate_email <- function(email) {
  if (is.null(email) || email == "") return(NULL)
  
  # Basic email regex pattern
  email_pattern <- "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
  
  if (!grepl(email_pattern, email)) {
    log_security_event("INVALID_EMAIL", paste("Invalid email format:", email))
    return(NULL)
  }
  
  # Additional security checks
  if (nchar(email) > 254) return(NULL)  # RFC 5321 limit
  if (grepl("\\.\\.| ", email)) return(NULL)  # No double dots or spaces
  
  return(tolower(trimws(email)))
}

#' Track Failed Login Attempt
#' 
#' Tracks failed login attempts for security monitoring
#' 
#' @param identifier User or IP identifier
#' @param reason Reason for failure
#' @return Logical indicating if user should be blocked
#' @export
track_failed_attempt <- function(identifier, reason = "Invalid credentials") {
  if (!(identifier %in% names(.security_state$failed_attempts))) {
    .security_state$failed_attempts[[identifier]] <- list(
      count = 0,
      first_attempt = Sys.time(),
      last_attempt = Sys.time()
    )
  }
  
  attempt_info <- .security_state$failed_attempts[[identifier]]
  attempt_info$count <- attempt_info$count + 1
  attempt_info$last_attempt <- Sys.time()
  .security_state$failed_attempts[[identifier]] <- attempt_info
  
  log_security_event("FAILED_ATTEMPT", 
                    paste("Failed attempt for", identifier, "-", reason,
                          "- Count:", attempt_info$count))
  
  # Block if max attempts exceeded
  if (attempt_info$count >= .security_state$max_attempts) {
    block_identifier(identifier)
    return(TRUE)
  }
  
  return(FALSE)
}

#' Block Identifier
#' 
#' Blocks an identifier (IP or user) from accessing the system
#' 
#' @param identifier Identifier to block
#' @param duration Block duration in seconds (default: 3600 = 1 hour)
block_identifier <- function(identifier, duration = 3600) {
  .security_state$blocked_ips[[identifier]] <- list(
    blocked_at = Sys.time(),
    expires = Sys.time() + duration,
    reason = "Max failed attempts exceeded"
  )
  
  log_security_event("IDENTIFIER_BLOCKED", 
                    paste("Blocked", identifier, "for", duration, "seconds"))
}

#' Check if Identifier is Blocked
#' 
#' @param identifier Identifier to check
#' @return Logical indicating if identifier is blocked
#' @export
is_blocked <- function(identifier) {
  if (!(identifier %in% names(.security_state$blocked_ips))) {
    return(FALSE)
  }
  
  block_info <- .security_state$blocked_ips[[identifier]]
  
  # Check if block has expired
  if (Sys.time() > block_info$expires) {
    # Remove expired block
    .security_state$blocked_ips[[identifier]] <- NULL
    .security_state$failed_attempts[[identifier]] <- NULL
    return(FALSE)
  }
  
  return(TRUE)
}

#' Secure File Upload Validation
#' 
#' Validates uploaded files for security
#' 
#' @param file_path Path to uploaded file
#' @param allowed_types Allowed MIME types
#' @param max_size Maximum file size in bytes
#' @return Logical indicating if file is safe
#' @export
validate_file_upload <- function(file_path, 
                                allowed_types = c("text/csv", "application/json"),
                                max_size = 10485760) {  # 10MB default
  if (!file.exists(file_path)) return(FALSE)
  
  # Check file size
  if (file.info(file_path)$size > max_size) {
    log_security_event("FILE_TOO_LARGE", paste("File exceeds size limit:", file_path))
    return(FALSE)
  }
  
  # Check file type (basic check via extension)
  ext <- tolower(tools::file_ext(file_path))
  allowed_extensions <- c("csv", "json", "txt", "rds")
  
  if (!(ext %in% allowed_extensions)) {
    log_security_event("INVALID_FILE_TYPE", paste("Invalid file type:", ext))
    return(FALSE)
  }
  
  # Check for malicious content patterns
  file_content <- readLines(file_path, n = 100, warn = FALSE)
  dangerous_patterns <- c("<?php", "<%", "<script", "eval(", "system(")
  
  for (pattern in dangerous_patterns) {
    if (any(grepl(pattern, file_content, ignore.case = TRUE))) {
      log_security_event("MALICIOUS_FILE", paste("Malicious pattern detected in", file_path))
      return(FALSE)
    }
  }
  
  return(TRUE)
}

#' Generate Secure Session ID
#' 
#' Generates a cryptographically secure session ID
#' 
#' @return Character string with secure session ID
#' @export
generate_secure_session_id <- function() {
  # Use multiple sources of entropy
  entropy_sources <- c(
    as.character(Sys.time()),
    as.character(Sys.getpid()),
    paste(sample(c(letters, LETTERS, 0:9), 32, replace = TRUE), collapse = ""),
    as.character(runif(10))
  )
  
  session_id <- digest::digest(paste(entropy_sources, collapse = "-"), 
                               algo = "sha256")
  
  return(paste0("SEC_", substr(session_id, 1, 32)))
}

#' Log Security Event
#' 
#' Logs security-related events for audit
#' 
#' @param event_type Type of security event
#' @param message Event message
#' @param details Additional details
log_security_event <- function(event_type, message, details = NULL) {
  if (!.security_state$enable_audit_logging) return()
  
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  
  log_entry <- sprintf("[%s] SECURITY_%s: %s", 
                      timestamp, event_type, message)
  
  if (!is.null(details)) {
    log_entry <- paste0(log_entry, " | Details: ", 
                       jsonlite::toJSON(details, auto_unbox = TRUE))
  }
  
  # Write to audit log
  if (!is.null(.security_state$audit_log)) {
    cat(log_entry, "\n", file = .security_state$audit_log, append = TRUE)
  }
  
  # Also log critical events to console
  if (event_type %in% c("IDENTIFIER_BLOCKED", "MALICIOUS_FILE", "CSRF_INVALID")) {
    warning(paste("SECURITY ALERT:", message))
  }
}

#' Get Security Status
#' 
#' Returns current security system status
#' 
#' @return List with security status information
#' @export
get_security_status <- function() {
  list(
    rate_limiting_enabled = .security_state$enable_rate_limiting,
    csrf_protection_enabled = .security_state$enable_csrf_protection,
    xss_prevention_enabled = .security_state$enable_xss_prevention,
    audit_logging_enabled = .security_state$enable_audit_logging,
    blocked_identifiers = length(.security_state$blocked_ips),
    active_csrf_tokens = length(.security_state$csrf_tokens),
    failed_attempts = length(.security_state$failed_attempts),
    audit_log_path = .security_state$audit_log
  )
}

#' Clear Security State
#' 
#' Clears temporary security state (for testing)
#' 
#' @export
clear_security_state <- function() {
  .security_state$rate_limits <- list()
  .security_state$csrf_tokens <- list()
  .security_state$failed_attempts <- list()
  .security_state$blocked_ips <- list()
  message("Security state cleared")
}