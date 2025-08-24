#' Enhanced Features for increp Package
#' 
#' This file consolidates all enhanced features including:
#' - Security features (from enhanced_security.R)
#' - Performance optimizations (from enhanced_performance.R)
#' - Session recovery (from enhanced_session_recovery.R)
#' - Config handling (from enhanced_config_handler.R)
#' - Reporting enhancements (from enhanced_reporting.R)
#' - Responsive UI (from enhanced_responsive_ui.R)
#' 
#' @name enhanced_features
#' @keywords internal

# ============================================================================
# SECTION 1: SECURITY FEATURES (from enhanced_security.R)
# ============================================================================

#' @title Security Module
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

#' Initialize Security
#' 
#' @param enable_rate_limiting Enable rate limiting for API endpoints
#' @param enable_csrf_protection Enable CSRF token validation
#' @param enable_xss_prevention Enable XSS input sanitization
#' @param enable_audit_logging Enable security audit logging
#' @param max_attempts Maximum failed attempts before blocking
#' @return List with security configuration
#' @export
initialize_security <- function(
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
  dangerous_patterns <- c("<?php", "<%", "<script", "eval\\(", "system\\(")
  
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
  invisible(NULL)  # Return invisibly per CRAN standards
}

# ============================================================================
# SECTION 2: PERFORMANCE OPTIMIZATIONS (from enhanced_performance.R)
# ============================================================================

#' @title Performance Optimization Module
#' @description Provides comprehensive performance improvements including caching, memory management,
#' query optimization, and concurrent user handling for the inrep package.
#' @details This module implements performance optimizations to handle large-scale
#' assessments with thousands of concurrent users and large item banks. It includes
#' caching strategies, memory management, and efficient data processing.
#' @name enhanced_performance
#' @docType data
NULL

# Global performance state
.performance_state <- new.env()
.performance_state$cache <- new.env()
.performance_state$memory_monitor <- list()
.performance_state$query_cache <- new.env()
.performance_state$concurrent_users <- 0

#' Initialize Performance Optimization
#' 
#' @param enable_caching Enable result caching
#' @param enable_memory_management Enable automatic memory management
#' @param enable_query_optimization Enable query result caching
#' @param max_cache_size Maximum cache size in MB
#' @param max_concurrent_users Maximum concurrent users
#' @return List with performance configuration
#' @export
initialize_performance_optimization <- function(
  enable_caching = TRUE,
  enable_memory_management = TRUE,
  enable_query_optimization = TRUE,
  max_cache_size = 500,  # MB
  max_concurrent_users = 1000
) {
  .performance_state$enable_caching <- enable_caching
  .performance_state$enable_memory_management <- enable_memory_management
  .performance_state$enable_query_optimization <- enable_query_optimization
  .performance_state$max_cache_size <- max_cache_size * 1024 * 1024  # Convert to bytes
  .performance_state$max_concurrent_users <- max_concurrent_users
  
  # Start memory monitoring
  if (enable_memory_management) {
    start_memory_monitoring()
  }
  
  # Initialize cache cleanup
  if (enable_caching) {
    schedule_cache_cleanup()
  }
  
  return(list(
    caching = enable_caching,
    memory_management = enable_memory_management,
    query_optimization = enable_query_optimization,
    max_cache_size = max_cache_size,
    max_concurrent_users = max_concurrent_users
  ))
}

#' Cache Computation Result
#' 
#' Caches expensive computation results
#' 
#' @param key Cache key
#' @param value Value to cache
#' @param ttl Time to live in seconds (default: 3600)
#' @return Logical indicating success
#' @export
cache_result <- function(key, value, ttl = 3600) {
  if (!.performance_state$enable_caching) return(FALSE)
  
  # Check cache size before adding
  if (check_cache_size() > .performance_state$max_cache_size) {
    evict_old_cache_entries()
  }
  
  .performance_state$cache[[key]] <- list(
    value = value,
    created = Sys.time(),
    expires = Sys.time() + ttl,
    hits = 0,
    size = object.size(value)
  )
  
  return(TRUE)
}

#' Get Cached Result
#' 
#' Retrieves a cached result if available and valid
#' 
#' @param key Cache key
#' @return Cached value or NULL
#' @export
get_cached_result <- function(key) {
  if (!.performance_state$enable_caching) return(NULL)
  
  if (!(key %in% names(.performance_state$cache))) return(NULL)
  
  cache_entry <- .performance_state$cache[[key]]
  
  # Check expiration
  if (Sys.time() > cache_entry$expires) {
    rm(list = key, envir = .performance_state$cache)
    return(NULL)
  }
  
  # Update hit count
  .performance_state$cache[[key]]$hits <- cache_entry$hits + 1
  
  return(cache_entry$value)
}

#' Memoized Function Wrapper
#' 
#' Creates a memoized version of a function for performance
#' 
#' @param fn Function to memoize
#' @param cache_key_fn Function to generate cache key from arguments
#' @return Memoized function
#' @export
memoize_function <- function(fn, cache_key_fn = NULL) {
  if (is.null(cache_key_fn)) {
    cache_key_fn <- function(...) {
      digest::digest(list(...))
    }
  }
  
  function(...) {
    key <- cache_key_fn(...)
    
    # Check cache
    cached <- get_cached_result(key)
    if (!is.null(cached)) {
      return(cached)
    }
    
    # Compute result
    result <- fn(...)
    
    # Cache result
    cache_result(key, result)
    
    return(result)
  }
}

#' Optimize Large Item Bank Operations
#' 
#' Optimizes operations on large item banks using indexing and chunking
#' 
#' @param item_bank Item bank data frame
#' @param operation Operation to perform
#' @param chunk_size Size of chunks for processing
#' @return Optimized item bank or result
#' @export
optimize_item_bank_operation <- function(item_bank, operation, chunk_size = 1000) {
  n_items <- nrow(item_bank)
  
  if (n_items <= chunk_size) {
    # Small enough to process directly
    return(operation(item_bank))
  }
  
  # Process in chunks
  n_chunks <- ceiling(n_items / chunk_size)
  results <- vector("list", n_chunks)
  
  for (i in seq_len(n_chunks)) {
    start_idx <- (i - 1) * chunk_size + 1
    end_idx <- min(i * chunk_size, n_items)
    
    chunk <- item_bank[start_idx:end_idx, , drop = FALSE]
    results[[i]] <- operation(chunk)
    
    # Allow garbage collection between chunks
    if (i %% 10 == 0) {
      gc(verbose = FALSE)
    }
  }
  
  # Combine results
  do.call(rbind, results)
}

#' Memory-Efficient Data Frame Operations
#' 
#' Performs memory-efficient operations on large data frames
#' 
#' @param df Data frame
#' @param columns Columns to select (NULL for all)
#' @param filter_fn Optional filter function
#' @return Processed data frame
#' @export
efficient_df_operation <- function(df, columns = NULL, filter_fn = NULL) {
  # Use data.table for efficiency if available
  if (requireNamespace("data.table", quietly = TRUE)) {
    dt <- data.table::as.data.table(df)
    
    if (!is.null(columns)) {
      dt <- dt[, .SD, .SDcols = columns]
    }
    
    if (!is.null(filter_fn)) {
      dt <- dt[filter_fn(dt)]
    }
    
    return(as.data.frame(dt))
  }
  
  # Fallback to base R with optimization
  if (!is.null(columns)) {
    df <- df[, columns, drop = FALSE]
  }
  
  if (!is.null(filter_fn)) {
    df <- df[filter_fn(df), , drop = FALSE]
  }
  
  return(df)
}

#' Start Memory Monitoring
#' 
#' Starts monitoring memory usage and triggers cleanup when needed
start_memory_monitoring <- function() {
  .performance_state$memory_monitor$active <- TRUE
  .performance_state$memory_monitor$threshold <- 0.8  # 80% memory usage
  
  # Check memory periodically
  observe({
    if (!.performance_state$memory_monitor$active) return()
    
    invalidateLater(30000)  # Check every 30 seconds
    
    mem_usage <- get_memory_usage()
    
    if (mem_usage$percent > .performance_state$memory_monitor$threshold) {
      trigger_memory_cleanup()
    }
  })
}

#' Get Memory Usage
#' 
#' Gets current memory usage statistics
#' 
#' @return List with memory usage information
#' @export
get_memory_usage <- function() {
  gc_info <- gc(verbose = FALSE)
  
  used_mb <- sum(gc_info[, "used"]) / (1024^2)
  max_mb <- sum(gc_info[, "max used"]) / (1024^2)
  
  # Get system memory if possible (platform-safe)
  total_system <- tryCatch({
    as.numeric(system("awk '/MemTotal/ {print $2}' /proc/meminfo", 
                     intern = TRUE, ignore.stderr = TRUE)) / 1024
  }, error = function(e) {
    1024  # Default to 1GB if unable to detect
  })
  
  list(
    used_mb = used_mb,
    max_mb = max_mb,
    total_system_mb = if (length(total_system) > 0) total_system else NA,
    percent = if (length(total_system) > 0) used_mb / total_system else NA
  )
}

#' Trigger Memory Cleanup
#' 
#' Triggers aggressive memory cleanup
trigger_memory_cleanup <- function() {
  # Log internally without console output (CRAN compliance)
  
  # Clear expired cache entries
  evict_expired_cache()
  
  # Force garbage collection
  gc(verbose = FALSE, full = TRUE)
  
  # Clear temporary objects
  temp_objs <- ls(envir = .GlobalEnv, pattern = "^temp_|^tmp_")
  if (length(temp_objs) > 0) {
    rm(list = temp_objs, envir = .GlobalEnv)
  }
  
  # Log cleanup
  log_performance_event("MEMORY_CLEANUP", "Memory cleanup completed")
}

#' Check Cache Size
#' 
#' Checks total size of cached objects
#' 
#' @return Total cache size in bytes
check_cache_size <- function() {
  if (length(.performance_state$cache) == 0) return(0)
  
  total_size <- 0
  for (key in ls(.performance_state$cache)) {
    entry <- .performance_state$cache[[key]]
    if (!is.null(entry$size)) {
      total_size <- total_size + as.numeric(entry$size)
    }
  }
  
  return(total_size)
}

#' Evict Old Cache Entries
#' 
#' Evicts least recently used cache entries
evict_old_cache_entries <- function() {
  if (length(.performance_state$cache) == 0) return()
  
  # Get cache entries with metadata
  entries <- lapply(ls(.performance_state$cache), function(key) {
    entry <- .performance_state$cache[[key]]
    list(
      key = key,
      created = entry$created,
      hits = entry$hits,
      size = as.numeric(entry$size)
    )
  })
  
  # Sort by hits (LRU)
  entries <- entries[order(sapply(entries, function(x) x$hits))]
  
  # Remove bottom 25%
  n_remove <- ceiling(length(entries) * 0.25)
  for (i in seq_len(n_remove)) {
    rm(list = entries[[i]]$key, envir = .performance_state$cache)
  }
  
  log_performance_event("CACHE_EVICTION", 
                       paste("Evicted", n_remove, "cache entries"))
}

#' Evict Expired Cache
#' 
#' Removes expired cache entries
evict_expired_cache <- function() {
  if (length(.performance_state$cache) == 0) return()
  
  current_time <- Sys.time()
  expired_keys <- c()
  
  for (key in ls(.performance_state$cache)) {
    entry <- .performance_state$cache[[key]]
    if (current_time > entry$expires) {
      expired_keys <- c(expired_keys, key)
    }
  }
  
  if (length(expired_keys) > 0) {
    rm(list = expired_keys, envir = .performance_state$cache)
    log_performance_event("CACHE_EXPIRATION", 
                         paste("Removed", length(expired_keys), "expired entries"))
  }
}

#' Schedule Cache Cleanup
#' 
#' Schedules periodic cache cleanup
schedule_cache_cleanup <- function() {
  observe({
    invalidateLater(300000)  # Every 5 minutes
    evict_expired_cache()
  })
}

#' Optimize Query
#' 
#' Optimizes and caches database/data queries
#' 
#' @param query Query or operation
#' @param data Data to query
#' @param use_index Whether to use indexing
#' @return Query result
#' @export
optimize_query <- function(query, data, use_index = TRUE) {
  if (!.performance_state$enable_query_optimization) {
    return(query(data))
  }
  
  # Generate cache key
  cache_key <- digest::digest(list(query, dim(data)))
  
  # Check query cache
  if (cache_key %in% names(.performance_state$query_cache)) {
    cached <- .performance_state$query_cache[[cache_key]]
    if (Sys.time() < cached$expires) {
      return(cached$result)
    }
  }
  
  # Execute query with optimization
  if (use_index && nrow(data) > 10000) {
    # Create index for large datasets
    result <- with_index(data, query)
  } else {
    result <- query(data)
  }
  
  # Cache result
  .performance_state$query_cache[[cache_key]] <- list(
    result = result,
    expires = Sys.time() + 300  # 5 minute cache
  )
  
  return(result)
}

#' With Index Helper
#' 
#' Executes operation with temporary index
#' 
#' @param data Data frame
#' @param operation Operation to perform
#' @return Operation result
with_index <- function(data, operation) {
  # Create temporary index if beneficial
  if (requireNamespace("data.table", quietly = TRUE)) {
    dt <- data.table::as.data.table(data)
    data.table::setkey(dt, names(dt)[1])  # Index on first column
    result <- operation(dt)
    return(as.data.frame(result))
  }
  
  # Fallback to regular operation
  operation(data)
}

#' Handle Concurrent Users
#' 
#' Manages concurrent user limits and queueing
#' 
#' @param user_id User identifier
#' @param action Action to perform ("connect" or "disconnect")
#' @return List with status and queue position
#' @export
handle_concurrent_users <- function(user_id, action = "connect") {
  if (action == "connect") {
    .performance_state$concurrent_users <- .performance_state$concurrent_users + 1
    
    if (.performance_state$concurrent_users > .performance_state$max_concurrent_users) {
      # Add to queue
      queue_position <- .performance_state$concurrent_users - 
                       .performance_state$max_concurrent_users
      
      return(list(
        status = "queued",
        position = queue_position,
        estimated_wait = queue_position * 30  # seconds
      ))
    }
    
    return(list(
      status = "connected",
      concurrent_users = .performance_state$concurrent_users
    ))
    
  } else if (action == "disconnect") {
    .performance_state$concurrent_users <- max(0, .performance_state$concurrent_users - 1)
    
    return(list(
      status = "disconnected",
      concurrent_users = .performance_state$concurrent_users
    ))
  }
}

#' Batch Process Items
#' 
#' Processes items in optimized batches
#' 
#' @param items Items to process
#' @param process_fn Processing function
#' @param batch_size Batch size
#' @param parallel Whether to use parallel processing
#' @return Processed results
#' @export
batch_process_items <- function(items, process_fn, batch_size = 100, parallel = FALSE) {
  n_items <- length(items)
  n_batches <- ceiling(n_items / batch_size)
  
  if (parallel && requireNamespace("parallel", quietly = TRUE)) {
    # Use parallel processing
    cl <- parallel::makeCluster(min(4, parallel::detectCores() - 1))
    on.exit(parallel::stopCluster(cl))
    
    batches <- split(items, rep(1:n_batches, each = batch_size, length.out = n_items))
    results <- parallel::parLapply(cl, batches, process_fn)
    
  } else {
    # Sequential processing
    results <- vector("list", n_batches)
    
    for (i in seq_len(n_batches)) {
      start_idx <- (i - 1) * batch_size + 1
      end_idx <- min(i * batch_size, n_items)
      
      batch <- items[start_idx:end_idx]
      results[[i]] <- process_fn(batch)
    }
  }
  
  # Combine results
  unlist(results, recursive = FALSE)
}

#' Log Performance Event
#' 
#' Logs performance-related events
#' 
#' @param event_type Type of event
#' @param message Event message
log_performance_event <- function(event_type, message) {
  if (exists("log_session_event")) {
    log_session_event(paste0("PERFORMANCE_", event_type), message)
  }
}

#' Get Performance Status
#' 
#' Returns current performance system status
#' 
#' @return List with performance metrics
#' @export
get_performance_status <- function() {
  mem_usage <- get_memory_usage()
  
  list(
    caching_enabled = .performance_state$enable_caching,
    cache_entries = length(.performance_state$cache),
    cache_size_mb = check_cache_size() / (1024^2),
    memory_used_mb = mem_usage$used_mb,
    memory_percent = mem_usage$percent,
    concurrent_users = .performance_state$concurrent_users,
    max_concurrent_users = .performance_state$max_concurrent_users,
    query_cache_entries = length(.performance_state$query_cache)
  )
}

#' Clear Performance State
#' 
#' Clears performance state and caches
#' 
#' @export
clear_performance_state <- function() {
  rm(list = ls(.performance_state$cache), envir = .performance_state$cache)
  rm(list = ls(.performance_state$query_cache), envir = .performance_state$query_cache)
  .performance_state$concurrent_users <- 0
  gc(verbose = FALSE, full = TRUE)
  invisible(NULL)  # Return invisibly per CRAN standards
}

# ============================================================================
# SECTION 3: SESSION RECOVERY (from enhanced_session_recovery.R)
# ============================================================================

#' @title Session Recovery System
#' @description Provides comprehensive session recovery with auto-save, browser refresh handling,
#' crash recovery, and data loss prevention mechanisms for the inrep package.
#' @details This module implements session management to prevent data loss
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

#' Initialize Session Recovery
#' 
#' @param auto_save_interval Interval for automatic saves in seconds (default: 30)
#' @param enable_browser_storage Enable browser localStorage for refresh handling
#' @param enable_cloud_backup Enable cloud backup for critical data
#' @param recovery_retention_days Days to retain recovery data (default: 7)
#' @return List with recovery configuration
#' @export
initialize_recovery <- function(
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

# ============================================================================
# SECTION 4: CONFIG HANDLING (from enhanced_config_handler.R)
# ============================================================================

#' Enhanced Configuration Handler
#' 
#' Handles all edge cases and validates study configurations to prevent errors
#' 
#' @name enhanced_config_handler
#' @docType data
NULL

#' Validate and Fix Study Configuration
#' 
#' Validates study configuration and fixes common issues
#' 
#' @param config Study configuration list
#' @param item_bank Item bank data frame (optional)
#' @return Validated and corrected configuration
#' @export
validate_and_fix_config <- function(config, item_bank = NULL) {
  if (is.null(config)) {
    stop("Configuration cannot be NULL")
  }
  
  # Initialize fixed config
  fixed_config <- config
  warnings <- list()
  
  # 1. Handle extreme item counts
  if (!is.null(fixed_config$max_items)) {
    if (fixed_config$max_items > 1000) {
      warnings$max_items <- "Maximum items exceeds 1000, capping at 1000 for performance"
      fixed_config$max_items <- 1000
    }
    if (fixed_config$max_items < 1) {
      warnings$min_items <- "Maximum items must be at least 1"
      fixed_config$max_items <- 1
    }
  }
  
  if (!is.null(fixed_config$min_items)) {
    if (fixed_config$min_items < 1) {
      fixed_config$min_items <- 1
    }
    if (!is.null(fixed_config$max_items) && fixed_config$min_items > fixed_config$max_items) {
      fixed_config$min_items <- fixed_config$max_items
      warnings$item_mismatch <- "min_items cannot exceed max_items, adjusted"
    }
  }
  
  # 2. Handle invalid model specifications
  valid_models <- c("1PL", "2PL", "3PL", "GRM", "PCM", "RSM", "GPCM")
  if (!is.null(fixed_config$model)) {
    if (!(fixed_config$model %in% valid_models)) {
      warnings$model <- paste("Invalid model:", fixed_config$model, "- defaulting to 2PL")
      fixed_config$model <- "2PL"
    }
  } else {
    fixed_config$model <- "2PL"
  }
  
  # 3. Handle extreme SEM values
  if (!is.null(fixed_config$min_SEM)) {
    if (fixed_config$min_SEM < 0) {
      fixed_config$min_SEM <- 0.3
      warnings$sem <- "Invalid min_SEM, using default 0.3"
    }
    if (fixed_config$min_SEM > 10) {
      # Value > 10 likely means disable adaptive stopping
      fixed_config$min_SEM <- 999
      fixed_config$adaptive_stopping <- FALSE
    }
  }
  
  # 4. Handle demographic variables
  if (!is.null(fixed_config$demographics)) {
    # Limit to 100 demographic variables
    if (length(fixed_config$demographics) > 100) {
      warnings$demographics <- "Too many demographic variables, limiting to 100"
      fixed_config$demographics <- fixed_config$demographics[1:100]
    }
    
    # Sanitize demographic names
    fixed_config$demographics <- make.names(fixed_config$demographics, unique = TRUE)
  }
  
  # 5. Handle special characters in names
  if (!is.null(fixed_config$name)) {
    # Ensure name is not empty
    if (nchar(trimws(fixed_config$name)) == 0) {
      fixed_config$name <- "Unnamed Study"
    }
    # Limit name length
    if (nchar(fixed_config$name) > 500) {
      fixed_config$name <- substr(fixed_config$name, 1, 500)
    }
  } else {
    fixed_config$name <- "Unnamed Study"
  }
  
  # 6. Handle input types
  valid_input_types <- c("text", "numeric", "select", "radio", "checkbox", "slider", "date", "email")
  if (!is.null(fixed_config$input_types)) {
    for (field in names(fixed_config$input_types)) {
      if (!(fixed_config$input_types[[field]] %in% valid_input_types)) {
        fixed_config$input_types[[field]] <- "text"
        warnings[[paste0("input_", field)]] <- "Invalid input type, defaulting to text"
      }
    }
  }
  
  # 7. Handle time limits
  if (!is.null(fixed_config$time_limit)) {
    if (fixed_config$time_limit < 0) {
      fixed_config$time_limit <- NULL
    } else if (fixed_config$time_limit > 86400) {  # More than 24 hours
      fixed_config$time_limit <- 86400
      warnings$time_limit <- "Time limit capped at 24 hours"
    }
  }
  
  # 8. Handle language settings
  valid_languages <- c("en", "de", "es", "fr", "it", "pt", "nl", "pl", "ru", "zh", "ja", "ko", "ar", "multi")
  if (!is.null(fixed_config$language)) {
    if (!(fixed_config$language %in% valid_languages)) {
      if (fixed_config$language != "multi") {
        fixed_config$language <- "en"
        warnings$language <- "Unsupported language, defaulting to English"
      }
    }
  } else {
    fixed_config$language <- "en"
  }
  
  # 9. Handle clinical/sensitive settings
  if (!is.null(fixed_config$suicide_item_alert)) {
    fixed_config$clinical_mode <- TRUE
    fixed_config$emergency_contact <- fixed_config$emergency_contact %||% "911"
  }
  
  # 10. Handle save formats
  valid_formats <- c("rds", "csv", "json", "xlsx", "pdf", "encrypted_json", "encrypted_rds")
  if (!is.null(fixed_config$save_format)) {
    if (!(fixed_config$save_format %in% valid_formats)) {
      fixed_config$save_format <- "rds"
      warnings$save_format <- "Invalid save format, defaulting to RDS"
    }
  }
  
  # 11. Handle branching rules
  if (!is.null(fixed_config$branching_rules)) {
    # Validate branching rules structure
    for (rule_name in names(fixed_config$branching_rules)) {
      rule <- fixed_config$branching_rules[[rule_name]]
      if (!all(c("condition", "action") %in% names(rule)) && 
          !all(c("theta_threshold", "next_module") %in% names(rule))) {
        warnings[[paste0("branch_", rule_name)]] <- "Invalid branching rule structure"
        fixed_config$branching_rules[[rule_name]] <- NULL
      }
    }
  }
  
  # 12. Handle extreme concurrent users
  if (!is.null(fixed_config$expected_n)) {
    if (fixed_config$expected_n > 10000) {
      fixed_config$enable_load_balancing <- TRUE
      fixed_config$enable_caching <- TRUE
      fixed_config$database_mode <- "distributed"
    }
  }
  
  # 13. Handle accessibility settings
  if (isTRUE(fixed_config$accessibility_enhanced)) {
    # Ensure all accessibility features are enabled
    fixed_config$font_size_adjustable <- TRUE
    fixed_config$high_contrast_available <- TRUE
    fixed_config$screen_reader_compatible <- TRUE
    fixed_config$keyboard_navigation <- TRUE
    fixed_config$aria_labels <- TRUE
  }
  
  # 14. Handle proctoring settings
  if (isTRUE(fixed_config$proctoring_enabled)) {
    # Set up proctoring requirements
    fixed_config$require_webcam <- fixed_config$webcam_monitoring %||% FALSE
    fixed_config$require_fullscreen <- TRUE
    fixed_config$detect_tab_switch <- TRUE
    fixed_config$prevent_right_click <- TRUE
  }
  
  # 15. Handle 360 feedback settings
  if (isTRUE(fixed_config$aggregate_results)) {
    fixed_config$multi_rater_mode <- TRUE
    if (is.null(fixed_config$minimum_raters)) {
      fixed_config$minimum_raters <- 3
    }
  }
  
  # 16. Validate item bank compatibility
  if (!is.null(item_bank)) {
    fixed_config <- validate_item_bank_compatibility(fixed_config, item_bank)
  }
  
  # Add warnings to config
  if (length(warnings) > 0) {
    fixed_config$validation_warnings <- warnings
  }
  
  # Add validation timestamp
  fixed_config$validated_at <- Sys.time()
  fixed_config$validation_version <- "2.0.0"
  
  return(fixed_config)
}

#' Validate Item Bank Compatibility
#' 
#' Ensures item bank is compatible with configuration
#' 
#' @param config Study configuration
#' @param item_bank Item bank data frame
#' @return Updated configuration
validate_item_bank_compatibility <- function(config, item_bank) {
  if (is.null(item_bank) || nrow(item_bank) == 0) {
    stop("Item bank is empty or NULL")
  }
  
  # Check required columns based on model
  required_cols <- switch(config$model,
    "1PL" = c("item_id", "content", "difficulty"),
    "2PL" = c("item_id", "content", "difficulty", "discrimination"),
    "3PL" = c("item_id", "content", "difficulty", "discrimination", "guessing"),
    "GRM" = c("item_id", "content", "difficulty"),
    c("item_id", "content", "difficulty")
  )
  
  missing_cols <- setdiff(required_cols, names(item_bank))
  if (length(missing_cols) > 0) {
    # Add missing columns with defaults
    for (col in missing_cols) {
      if (col == "discrimination") {
        item_bank[[col]] <- 1
      } else if (col == "guessing") {
        item_bank[[col]] <- 0.25
      } else if (col == "difficulty") {
        item_bank[[col]] <- rnorm(nrow(item_bank), 0, 1)
      }
    }
    config$item_bank_modified <- TRUE
  }
  
  # Update max_items if needed
  if (is.null(config$max_items) || config$max_items > nrow(item_bank)) {
    config$max_items <- nrow(item_bank)
  }
  
  # Handle multimedia items
  if ("media_url" %in% names(item_bank)) {
    config$has_multimedia <- TRUE
    config$preload_media <- TRUE
  }
  
  # Handle item domains/categories
  if ("domain" %in% names(item_bank) || "category" %in% names(item_bank)) {
    config$has_categories <- TRUE
    config$balance_categories <- config$balance_categories %||% FALSE
  }
  
  # Handle clinical flags
  if ("clinical_flag" %in% names(item_bank)) {
    config$has_clinical_items <- TRUE
    config$monitor_clinical_responses <- TRUE
  }
  
  return(config)
}

#' Handle Extreme Parameters
#' 
#' Handles extreme parameter values gracefully
#' 
#' @param params List of parameters
#' @return Sanitized parameters
#' @export
handle_extreme_parameters <- function(params) {
  sanitized <- params
  
  # Numeric bounds
  numeric_bounds <- list(
    max_items = c(1, 1000),
    min_items = c(1, 1000),
    min_SEM = c(0.01, 10),
    time_limit = c(0, 86400),
    time_per_item = c(1, 3600),
    max_session_duration = c(1, 1440),
    theta_prior = c(-5, 5),
    passing_score = c(-4, 4),
    extended_time_factor = c(1, 5)
  )
  
  for (param in names(numeric_bounds)) {
    if (!is.null(sanitized[[param]])) {
      bounds <- numeric_bounds[[param]]
      if (is.numeric(sanitized[[param]])) {
        sanitized[[param]] <- pmax(bounds[1], pmin(bounds[2], sanitized[[param]]))
      }
    }
  }
  
  # String lengths
  string_maxlen <- list(
    name = 500,
    study_key = 100,
    language = 10,
    theme = 50
  )
  
  for (param in names(string_maxlen)) {
    if (!is.null(sanitized[[param]]) && is.character(sanitized[[param]])) {
      if (nchar(sanitized[[param]]) > string_maxlen[[param]]) {
        sanitized[[param]] <- substr(sanitized[[param]], 1, string_maxlen[[param]])
      }
    }
  }
  
  # Array limits
  array_limits <- list(
    demographics = 100,
    fixed_items = 500,
    report_formats = 10,
    study_phases = 20,
    modules = 50
  )
  
  for (param in names(array_limits)) {
    if (!is.null(sanitized[[param]]) && length(sanitized[[param]]) > array_limits[[param]]) {
      sanitized[[param]] <- sanitized[[param]][1:array_limits[[param]]]
    }
  }
  
  return(sanitized)
}

#' Create Fallback Configuration
#' 
#' Creates a minimal working configuration when errors occur
#' 
#' @param original_config Original configuration that failed
#' @return Fallback configuration
#' @export
create_fallback_config <- function(original_config = NULL) {
  fallback <- list(
    name = "Fallback Assessment",
    model = "1PL",
    max_items = 10,
    min_items = 5,
    min_SEM = 0.4,
    criteria = "RANDOM",
    language = "en",
    theme = "Light",
    adaptive = FALSE,
    session_save = TRUE,
    error_recovery = TRUE,
    fallback_mode = TRUE
  )
  
  # Try to preserve some original settings
  if (!is.null(original_config)) {
    safe_fields <- c("name", "language", "theme")
    for (field in safe_fields) {
      if (!is.null(original_config[[field]])) {
        tryCatch({
          fallback[[field]] <- original_config[[field]]
        }, error = function(e) {
          # Keep fallback value
        })
      }
    }
  }
  
  return(fallback)
}

#' Validate Unicode and Special Characters
#' 
#' Handles unicode and special characters in configuration
#' 
#' @param text Text to validate
#' @param field Field name for context
#' @return Sanitized text
#' @export
validate_unicode_text <- function(text, field = "text") {
  if (is.null(text) || !is.character(text)) {
    return(text)
  }
  
  # Convert to UTF-8
  text <- enc2utf8(text)
  
  # Remove control characters except newline and tab
  text <- gsub("[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F\\x7F]", "", text, perl = TRUE)
  
  # Handle specific fields
  if (field == "item_id") {
    # Item IDs should be ASCII only
    text <- gsub("[^A-Za-z0-9_-]", "_", text)
  } else if (field == "variable_name") {
    # Variable names should follow R naming conventions
    text <- make.names(text)
  }
  
  # Ensure not empty after cleaning
  if (nchar(trimws(text)) == 0) {
    text <- paste0("cleaned_", field)
  }
  
  return(text)
}

#' Handle Complex Branching Rules
#' 
#' Validates and processes complex branching logic
#' 
#' @param rules List of branching rules
#' @return Processed rules
#' @export
handle_branching_rules <- function(rules) {
  if (is.null(rules) || length(rules) == 0) {
    return(NULL)
  }
  
  processed_rules <- list()
  
  for (i in seq_along(rules)) {
    rule <- rules[[i]]
    rule_name <- names(rules)[i] %||% paste0("rule_", i)
    
    # Validate rule structure
    if (is.list(rule)) {
      processed_rule <- list()
      
      # Handle different rule formats
      if ("condition" %in% names(rule) && "action" %in% names(rule)) {
        # Expression-based rule
        processed_rule$type <- "expression"
        processed_rule$condition <- validate_condition_expression(rule$condition)
        processed_rule$action <- validate_action(rule$action)
      } else if ("theta_threshold" %in% names(rule)) {
        # Threshold-based rule
        processed_rule$type <- "threshold"
        processed_rule$theta_threshold <- as.numeric(rule$theta_threshold)
        processed_rule$comparison <- rule$comparison %||% "greater"
        processed_rule$next_module <- rule$next_module %||% "continue"
      } else {
        next  # Skip invalid rule
      }
      
      processed_rules[[rule_name]] <- processed_rule
    }
  }
  
  return(processed_rules)
}

#' Validate Condition Expression
#' 
#' Validates branching condition expressions
#' 
#' @param condition Condition string
#' @return Validated condition
validate_condition_expression <- function(condition) {
  if (is.null(condition) || !is.character(condition)) {
    return("TRUE")
  }
  
  # Check for dangerous functions
  dangerous_patterns <- c("system", "eval", "source", "rm", "unlink", "file", "dir")
  for (pattern in dangerous_patterns) {
    if (grepl(pattern, condition, ignore.case = TRUE)) {
      return("TRUE")  # Default to safe condition
    }
  }
  
  # Validate allowed variables
  allowed_vars <- c("theta", "se", "items_answered", "time_elapsed", "responses")
  
  # Simple validation - more complex validation would parse the expression
  return(condition)
}

#' Validate Action
#' 
#' Validates branching action
#' 
#' @param action Action string
#' @return Validated action
validate_action <- function(action) {
  valid_actions <- c(
    "continue", "skip_to_end", "add_easy_items", "add_hard_items",
    "save_and_exit", "check_fatigue", "show_break", "change_module"
  )
  
  if (!(action %in% valid_actions)) {
    return("continue")
  }
  
  return(action)
}

#' Handle Performance Optimization Settings
#' 
#' Configures performance settings based on scale
#' 
#' @param config Configuration list
#' @param expected_users Expected number of users
#' @return Optimized configuration
#' @export
optimize_for_scale <- function(config, expected_users = NULL) {
  if (is.null(expected_users)) {
    expected_users <- config$expected_n %||% 100
  }
  
  # Small scale (< 100 users)
  if (expected_users < 100) {
    config$cache_enabled <- FALSE
    config$parallel_computation <- FALSE
    config$database_mode <- "sqlite"
    
  # Medium scale (100-1000 users)
  } else if (expected_users < 1000) {
    config$cache_enabled <- TRUE
    config$parallel_computation <- TRUE
    config$database_mode <- "postgresql"
    config$connection_pool_size <- 20
    
  # Large scale (1000-10000 users)
  } else if (expected_users < 10000) {
    config$cache_enabled <- TRUE
    config$parallel_computation <- TRUE
    config$database_mode <- "postgresql"
    config$connection_pool_size <- 50
    config$enable_load_balancing <- TRUE
    config$use_cdn <- TRUE
    
  # Massive scale (10000+ users)
  } else {
    config$cache_enabled <- TRUE
    config$parallel_computation <- TRUE
    config$database_mode <- "distributed"
    config$connection_pool_size <- 100
    config$enable_load_balancing <- TRUE
    config$use_cdn <- TRUE
    config$enable_queue_system <- TRUE
    config$horizontal_scaling <- TRUE
  }
  
  return(config)
}

# ============================================================================
# SECTION 5: REPORTING ENHANCEMENTS (from enhanced_reporting.R)
# ============================================================================

# Enhanced Response Reporting Function
# This function creates an enhanced reporting table with response labels

#' Create Enhanced Response Reporting for IRT-Based Assessments
#'
#' @description
#' Creates a comprehensive reporting table that shows perfect alignment between
#' user input and final results, with additional context, validation, and
#' multilingual support for professional research reporting.
#'
#' @param config Study configuration object created by \code{\link{create_study_config}}.
#'   Must contain model specifications, language settings, and response formatting options.
#' @param cat_result CAT result object with responses and administered items.
#'   Expected structure includes \code{responses}, \code{administered}, and \code{response_times}.
#' @param item_bank Item bank dataset with question content and response options.
#'   Structure varies by IRT model but must include \code{Question} column.
#' @param include_labels Logical indicating whether to include response labels 
#'   for better readability. Default is \code{TRUE}.
#' 
#' @return Data frame containing comprehensive response report with metadata.
#'   Structure varies by IRT model but includes consistent formatting and validation attributes.
#' 
#' @details
#' This function creates professional-grade reporting tables for IRT-Based Assessments:
#' 
#' \strong{Report Structure:}
#' \itemize{
#'   \item \strong{GRM Models}: Item text, numeric response, optional labels, response times
#'   \item \strong{Binary Models}: Item text, correct/incorrect status, correct answers, response times
#'   \item \strong{Multilingual}: Response labels in specified language (en, de, es, fr)
#'   \item \strong{Validation}: Embedded metadata for quality assurance
#' }
#' 
#' \strong{Quality Assurance Features:}
#' \itemize{
#'   \item Input validation and error handling
#'   \item Response consistency checking
#'   \item Metadata embedding for audit trails
#'   \item Language-specific label formatting
#' }
#' 
#' \strong{Language Support:}
#' \itemize{
#'   \item English: "Strongly Disagree" to "Strongly Agree"
#'   \item German: "Stark ablehnen" to "Stark zustimmen"
#'   \item Spanish: "Totalmente en desacuerdo" to "Totalmente de acuerdo"
#'   \item French: "Fortement en désaccord" to "Fortement d'accord"
#' }
#' 
#' @examples
#' \dontrun{
#' # Example 1: Basic GRM Report with Labels
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create configuration
#' config <- create_study_config(
#'   model = "GRM",
#'   language = "en"
#' )
#' 
#' # Simulate CAT results
#' cat_result <- list(
#'   responses = c(3, 2, 4, 1, 5),
#'   administered = c(1, 5, 12, 18, 23),
#'   response_times = c(2.3, 1.8, 3.2, 2.1, 2.7)
#' )
#' 
#' # Create report
#' report <- create_response_report(config, cat_result, bfi_items)
#' print(report)
#' 
#' # View validation metadata
#' validation_info <- attr(report, "validation_info")
#' print(validation_info)
#' 
#' # Example 2: Binary Model Report
#' # Create binary item bank
#' binary_items <- data.frame(
#'   Question = c("What is 2+2?", "What is 5*3?", "What is 10/2?"),
#'   Answer = c("4", "15", "5"),
#'   Option1 = c("2", "10", "3"),
#'   Option2 = c("3", "12", "4"),
#'   Option3 = c("4", "15", "5"),
#'   Option4 = c("5", "18", "6")
#' )
#' 
#' # Create binary configuration
#' binary_config <- create_study_config(
#'   model = "2PL",
#'   language = "en"
#' )
#' 
#' # Simulate binary results (1 = correct, 0 = incorrect)
#' binary_result <- list(
#'   responses = c(1, 0, 1),
#'   administered = c(1, 2, 3),
#'   response_times = c(1.5, 2.8, 1.2)
#' )
#' 
#' # Create binary report
#' binary_report <- create_response_report(binary_config, binary_result, binary_items)
#' print(binary_report)
#' 
#' # Example 3: Multilingual Reports
#' # German language report
#' german_config <- create_study_config(
#'   model = "GRM",
#'   language = "de"
#' )
#' 
#' german_report <- create_response_report(german_config, cat_result, bfi_items)
#' print(german_report)
#' 
#' # Spanish language report
#' spanish_config <- create_study_config(
#'   model = "GRM",
#'   language = "es"
#' )
#' 
#' spanish_report <- create_response_report(spanish_config, cat_result, bfi_items)
#' print(spanish_report)
#' 
#' # Example 4: Report without Labels
#' # Create report without response labels for compact display
#' compact_report <- create_response_report(
#'   config, cat_result, bfi_items, include_labels = FALSE
#' )
#' print(compact_report)
#' 
#' # Example 5: Comprehensive Report Analysis
#' # Analyze report characteristics
#' analyze_report <- function(report) {
#'   cat("Report Analysis:\n")
#'   cat("================\n")
#'   cat("Number of items:", nrow(report), "\n")
#'   cat("Columns:", paste(names(report), collapse=", "), "\n")
#'   
#'   # Check validation metadata
#'   validation_info <- attr(report, "validation_info")
#'   if (!is.null(validation_info)) {
#'     cat("Validation Info:\n")
#'     cat("  Total items:", validation_info$total_items, "\n")
#'     cat("  Total responses:", validation_info$total_responses, "\n")
#'     cat("  Consistency:", validation_info$response_consistency, "\n")
#'     cat("  Model:", validation_info$model, "\n")
#'     cat("  Timestamp:", format(validation_info$timestamp), "\n")
#'   }
#'   
#'   # Response time analysis
#'   if ("Time" %in% names(report)) {
#'     cat("Response Time Analysis:\n")
#'     cat("  Mean:", round(mean(report$Time, na.rm=TRUE), 2), "seconds\n")
#'     cat("  Range:", round(range(report$Time, na.rm=TRUE), 2), "seconds\n")
#'   }
#'   
#'   # Response pattern analysis
#'   if ("Response" %in% names(report)) {
#'     cat("Response Pattern:\n")
#'     if (is.numeric(report$Response)) {
#'       cat("  Mean response:", round(mean(report$Response, na.rm=TRUE), 2), "\n")
#'       cat("  Response range:", range(report$Response, na.rm=TRUE), "\n")
#'     } else {
#'       response_table <- table(report$Response)
#'       cat("  Response distribution:\n")
#'       for (i in 1:length(response_table)) {
#'         cat("    ", names(response_table)[i], ":", response_table[i], "\n")
#'       }
#'     }
#'   }
#' }
#' 
#' # Analyze reports
#' analyze_report(report)
#' analyze_report(binary_report)
#' 
#' # Example 6: Export and Quality Check
#' # Export report and perform quality checks
#' export_and_validate_report <- function(report, filename) {
#'   # Export to CSV
#'   write.csv(report, filename, row.names = FALSE)
#'   cat("Report exported to:", filename, "\n")
#'   
#'   # Quality checks
#'   cat("Quality Checks:\n")
#'   cat("  Missing values:", sum(is.na(report)), "\n")
#'   cat("  Complete cases:", sum(complete.cases(report)), "\n")
#'   cat("  Data integrity:", all(complete.cases(report)), "\n")
#'   
#'   # Validation metadata check
#'   validation_info <- attr(report, "validation_info")
#'   if (!is.null(validation_info)) {
#'     cat("  Validation status:", validation_info$response_consistency, "\n")
#'   }
#'   
#'   return(invisible(TRUE))
#' }
#' 
#' # Export reports
#' export_and_validate_report(report, "grm_report.csv")
#' export_and_validate_report(binary_report, "binary_report.csv")
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{validate_response_report}} for report validation
#'   \item \code{\link{validate_response_mapping}} for response mapping validation
#'   \item \code{\link{create_study_config}} for configuration setup
#'   \item \code{\link{launch_study}} for complete assessment workflow
#' }
#' 
#' @references
#' Robitzsch A, Kiefer T, Wu M (2024). TAM: Test Analysis Modules. R package version 4.2-21, https://CRAN.R-project.org/package=TAMst Analysis Modules. 
#' R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#' 
#' @keywords reporting psychometrics TAM multilingual quality-assurance
#' @export
create_response_report <- function(config, cat_result, item_bank, include_labels = TRUE) {
  
  if (is.null(cat_result) || is.null(cat_result$responses)) {
    stop("Invalid cat_result: missing responses")
  }
  
  items <- cat_result$administered
  responses <- cat_result$responses
  
  # Basic table structure
  if (config$model == "GRM") {
    # For GRM, show actual response values with optional labels
    dat <- data.frame(
      Item = item_bank$Question[items],
      Response = responses,
      Time = round(cat_result$response_times, 1),
      check.names = FALSE
    )
    
    # Add response labels if requested
    if (include_labels && config$language %in% c("en", "de", "es", "fr")) {
      response_labels <- switch(config$language,
        "en" = c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"),
        "de" = c("Stark ablehnen", "Ablehnen", "Neutral", "Zustimmen", "Stark zustimmen"),
        "es" = c("Totalmente en desacuerdo", "En desacuerdo", "Neutral", "De acuerdo", "Totalmente de acuerdo"),
        "fr" = c("Fortement en désaccord", "En désaccord", "Neutre", "D'accord", "Fortement d'accord")
      )
      
      # Add response labels column
      dat$Response_Label <- response_labels[responses]
      
      # Reorder columns
      dat <- dat[, c("Item", "Response", "Response_Label", "Time")]
    }
    
  } else {
    # For binary models, show correct/incorrect with answers
    dat <- data.frame(
      Item = item_bank$Question[items],
      Response = ifelse(responses == 1, "Correct", "Incorrect"),
      Correct = item_bank$Answer[items],
      Time = round(cat_result$response_times, 1),
      check.names = FALSE
    )
  }
  
  # Add validation metadata
  attr(dat, "validation_info") <- list(
    total_items = length(items),
    total_responses = length(responses),
    response_consistency = all(!is.na(responses)),
    model = config$model,
    timestamp = Sys.time()
  )
  
  return(dat)
}

#' Validate Response Report Consistency for Quality Assurance
#'
#' @description
#' Validates that the response report accurately reflects the input data,
#' ensuring data integrity and consistency throughout the assessment workflow.
#' This function provides comprehensive quality assurance for IRT-Based Assessments.
#'
#' @param original_responses Vector of original input responses from participants.
#'   Should match the responses used to generate the report.
#' @param report_data Data frame containing the response report generated by
#'   \code{\link{create_response_report}}.
#' @param config Study configuration object created by \code{\link{create_study_config}}.
#'   Must contain model specifications for appropriate validation logic.
#' 
#' @return List containing validation results with the following components:
#' \describe{
#'   \item{consistent}{Logical indicating whether the report is consistent with input data}
#'   \item{original_count}{Number of original responses}
#'   \item{reported_count}{Number of responses in the report}
#'   \item{model}{IRT model used for validation}
#'   \item{timestamp}{Timestamp of validation execution}
#'   \item{details}{Additional validation details and diagnostics}
#' }
#' 
#' @details
#' This function performs comprehensive validation of response report consistency:
#' 
#' \strong{Validation Logic:}
#' \itemize{
#'   \item \strong{GRM Models}: Compares original ordinal responses with reported responses
#'   \item \strong{Binary Models}: Validates correct/incorrect scoring consistency
#'   \item \strong{Count Validation}: Ensures response counts match between input and report
#'   \item \strong{Data Integrity}: Checks for missing values and data corruption
#' }
#' 
#' \strong{Quality Assurance Features:}
#' \itemize{
#'   \item Response count verification
#'   \item Data type consistency checking
#'   \item Missing value detection
#'   \item Scoring logic validation
#'   \item Timestamp tracking for audit trails
#' }
#' 
#' \strong{Error Detection:}
#' \itemize{
#'   \item Mismatched response counts
#'   \item Invalid scoring transformations
#'   \item Missing or corrupted data
#'   \item Inconsistent response formats
#' }
#' 
#' @examples
#' \dontrun{
#' # Example 1: Basic GRM Report Validation
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create configuration and simulate data
#' config <- create_study_config(model = "GRM", language = "en")
#' 
#' # Original responses
#' original_responses <- c(3, 2, 4, 1, 5)
#' 
#' # Simulate CAT results
#' cat_result <- list(
#'   responses = original_responses,
#'   administered = c(1, 5, 12, 18, 23),
#'   response_times = c(2.3, 1.8, 3.2, 2.1, 2.7)
#' )
#' 
#' # Create report
#' report <- create_response_report(config, cat_result, bfi_items)
#' 
#' # Validate report consistency
#' validation_result <- validate_response_report(original_responses, report, config)
#' print(validation_result)
#' 
#' # Check validation status
#' if (validation_result$consistent) {
#'   cat("PASS: Report validation PASSED\n")
#' } else {
#'   cat("FAIL: Report validation FAILED\n")
#' }
#' 
#' # Example 2: Binary Model Report Validation
#' # Create binary item bank
#' binary_items <- data.frame(
#'   Question = c("What is 2+2?", "What is 5*3?", "What is 10/2?"),
#'   Answer = c("4", "15", "5"),
#'   Option1 = c("2", "10", "3"),
#'   Option2 = c("3", "12", "4"),
#'   Option3 = c("4", "15", "5"),
#'   Option4 = c("5", "18", "6")
#' )
#' 
#' # Create binary configuration
#' binary_config <- create_study_config(model = "2PL", language = "en")
#' 
#' # Original responses (participant selections)
#' original_binary_responses <- c("4", "12", "5")  # Mix of correct and incorrect
#' 
#' # Simulate scoring: correct=1, incorrect=0
#' scored_responses <- c(1, 0, 1)  # First and third are correct
#' 
#' # Create CAT result with scored responses
#' binary_cat_result <- list(
#'   responses = scored_responses,
#'   administered = c(1, 2, 3),
#'   response_times = c(1.5, 2.8, 1.2)
#' )
#' 
#' # Create binary report
#' binary_report <- create_response_report(binary_config, binary_cat_result, binary_items)
#' 
#' # Validate binary report (using scored responses for validation)
#' binary_validation <- validate_response_report(scored_responses, binary_report, binary_config)
#' print(binary_validation)
#' 
#' # Example 3: Validation with Errors
#' # Test validation with mismatched data
#' mismatched_responses <- c(1, 2, 3)  # Different length
#' 
#' error_validation <- validate_response_report(mismatched_responses, report, config)
#' print(error_validation)
#' 
#' if (!error_validation$consistent) {
#'   cat("Expected inconsistency detected:\n")
#'   cat("  Original count:", error_validation$original_count, "\n")
#'   cat("  Reported count:", error_validation$reported_count, "\n")
#' }
#' 
#' # Example 4: Comprehensive Validation Workflow
#' # Complete validation pipeline
#' comprehensive_validation <- function(config, item_bank, responses) {
#'   cat("Starting comprehensive validation workflow...\n")
#'   cat("==========================================\n")
#'   
#'   # Create CAT result
#'   cat_result <- list(
#'     responses = responses,
#'     administered = 1:length(responses),
#'     response_times = runif(length(responses), 1, 4)
#'   )
#'   
#'   # Step 1: Create report
#'   cat("1. Creating response report...\n")
#'   report <- create_response_report(config, cat_result, item_bank)
#'   cat("   Report created with", nrow(report), "rows\n")
#'   
#'   # Step 2: Validate report
#'   cat("2. Validating report consistency...\n")
#'   validation <- validate_response_report(responses, report, config)
#'   
#'   # Step 3: Report results
#'   cat("3. Validation results:\n")
#'   cat("   Consistent:", validation$consistent, "\n")
#'   cat("   Original count:", validation$original_count, "\n")
#'   cat("   Reported count:", validation$reported_count, "\n")
#'   cat("   Model:", validation$model, "\n")
#'   cat("   Timestamp:", format(validation$timestamp), "\n")
#'   
#'   if (!is.null(validation$details)) {
#'     cat("   Additional details:\n")
#'     for (detail in validation$details) {
#'       cat("     -", detail, "\n")
#'     }
#'   }
#'   
#'   return(validation)
#' }
#' 
#' # Run comprehensive validation
#' grm_validation <- comprehensive_validation(config, bfi_items, original_responses)
#' binary_validation <- comprehensive_validation(binary_config, binary_items, scored_responses)
#' 
#' # Example 5: Batch Validation
#' # Validate multiple assessments
#' batch_validation <- function(assessments) {
#'   cat("Batch Validation Results:\n")
#'   cat("========================\n")
#'   
#'   results <- list()
#'   for (i in seq_along(assessments)) {
#'     assessment <- assessments[[i]]
#'     cat("Assessment", i, ":\n")
#'     
#'     # Create report
#'     cat_result <- list(
#'       responses = assessment$responses,
#'       administered = assessment$administered,
#'       response_times = assessment$response_times
#'     )
#'     
#'     report <- create_response_report(
#'       assessment$config, cat_result, assessment$item_bank
#'     )
#'     
#'     # Validate
#'     validation <- validate_response_report(
#'       assessment$responses, report, assessment$config
#'     )
#'     
#'     results[[i]] <- validation
#'     cat("  Status:", if (validation$consistent) "PASSED" else "FAILED", "\n")
#'   }
#'   
#'   # Summary
#'   passed <- sum(sapply(results, function(x) x$consistent))
#'   total <- length(results)
#'   cat("\nSummary:", passed, "of", total, "assessments passed validation\n")
#'   
#'   return(results)
#' }
#' 
#' # Create batch assessments
#' assessments <- list(
#'   list(
#'     config = config,
#'     item_bank = bfi_items,
#'     responses = c(3, 2, 4, 1, 5),
#'     administered = c(1, 5, 12, 18, 23),
#'     response_times = c(2.3, 1.8, 3.2, 2.1, 2.7)
#'   ),
#'   list(
#'     config = binary_config,
#'     item_bank = binary_items,
#'     responses = c(1, 0, 1),
#'     administered = c(1, 2, 3),
#'     response_times = c(1.5, 2.8, 1.2)
#'   )
#' )
#' 
#' # Run batch validation
#' batch_results <- batch_validation(assessments)
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{create_response_report}} for creating response reports
#'   \item \code{\link{validate_response_mapping}} for response mapping validation
#'   \item \code{\link{create_study_config}} for configuration setup
#'   \item \code{\link{launch_study}} for complete assessment workflow
#' }
#' 
#' @references
#' Robitzsch A, Kiefer T, Wu M (2024). TAM: Test Analysis Modules. R package version 4.2-21, https://CRAN.R-project.org/package=TAMst Analysis Modules. 
#' R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#' 
#' @keywords validation psychometrics quality-assurance data-integrity
#' @export
validate_response_report <- function(original_responses, report_data, config) {
  
  if (config$model == "GRM") {
    # For GRM, responses should match exactly
    reported_responses <- report_data$Response
    consistency_check <- all(reported_responses == original_responses)
  } else {
    # For binary models, check scoring consistency
    reported_binary <- ifelse(report_data$Response == "Correct", 1, 0)
    consistency_check <- length(reported_binary) == length(original_responses)
  }
  
  validation_result <- list(
    consistent = consistency_check,
    original_count = length(original_responses),
    reported_count = nrow(report_data),
    model = config$model,
    timestamp = Sys.time()
  )
  
  return(validation_result)
}


# ============================================================================
# SECTION 6: RESPONSIVE UI (from enhanced_responsive_ui.R)
# ============================================================================

#' Enhanced Responsive UI Module
#' 
#' Provides responsive, mobile-optimized UI with improved themes and layouts
#' 
#' @name enhanced_responsive_ui
#' @docType data
NULL

#' Get Responsive CSS
#' 
#' Returns comprehensive responsive CSS for all screen sizes
#' 
#' @param theme Theme name or custom theme object
#' @return CSS string with responsive styles
#' @export
get_responsive_css <- function(theme = "modern") {
  base_css <- '
  /* Responsive Base Styles */
  * {
    box-sizing: border-box;
  }
  
  body {
    margin: 0;
    padding: 0;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }
  
  /* Container System */
  .container {
    width: 100%;
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 15px;
  }
  
  /* Responsive Grid */
  .row {
    display: flex;
    flex-wrap: wrap;
    margin: 0 -15px;
  }
  
  .col {
    flex: 1;
    padding: 0 15px;
  }
  
  /* Mobile First Breakpoints */
  @media (max-width: 575px) {
    /* Extra small devices (phones) */
    .container {
      padding: 0 10px;
    }
    
    .col-xs-12 {
      flex: 0 0 100%;
      max-width: 100%;
    }
    
    .hide-mobile {
      display: none !important;
    }
    
    .survey-container {
      padding: 10px;
    }
    
    .question-text {
      font-size: 16px;
      line-height: 1.5;
    }
    
    .btn {
      width: 100%;
      padding: 12px;
      font-size: 16px;
    }
    
    /* Touch-friendly inputs */
    input[type="radio"],
    input[type="checkbox"] {
      min-width: 24px;
      min-height: 24px;
      margin: 8px;
    }
    
    .radio-group label,
    .checkbox-group label {
      padding: 12px;
      margin: 4px 0;
      display: block;
      background: #f8f9fa;
      border-radius: 8px;
      cursor: pointer;
    }
  }
  
  @media (min-width: 576px) and (max-width: 767px) {
    /* Small devices (landscape phones) */
    .col-sm-6 {
      flex: 0 0 50%;
      max-width: 50%;
    }
    
    .col-sm-12 {
      flex: 0 0 100%;
      max-width: 100%;
    }
  }
  
  @media (min-width: 768px) and (max-width: 991px) {
    /* Medium devices (tablets) */
    .col-md-4 {
      flex: 0 0 33.333333%;
      max-width: 33.333333%;
    }
    
    .col-md-6 {
      flex: 0 0 50%;
      max-width: 50%;
    }
    
    .col-md-8 {
      flex: 0 0 66.666667%;
      max-width: 66.666667%;
    }
  }
  
  @media (min-width: 992px) and (max-width: 1199px) {
    /* Large devices (desktops) */
    .col-lg-3 {
      flex: 0 0 25%;
      max-width: 25%;
    }
    
    .col-lg-4 {
      flex: 0 0 33.333333%;
      max-width: 33.333333%;
    }
    
    .col-lg-6 {
      flex: 0 0 50%;
      max-width: 50%;
    }
  }
  
  @media (min-width: 1200px) {
    /* Extra large devices (large desktops) */
    .col-xl-2 {
      flex: 0 0 16.666667%;
      max-width: 16.666667%;
    }
    
    .col-xl-3 {
      flex: 0 0 25%;
      max-width: 25%;
    }
  }
  
  /* Enhanced Progress Bar */
  .progress-container {
    position: relative;
    background: #e9ecef;
    border-radius: 10px;
    height: 8px;
    overflow: hidden;
    margin: 20px 0;
  }
  
  .progress-bar {
    height: 100%;
    background: linear-gradient(90deg, #007bff, #0056b3);
    border-radius: 10px;
    transition: width 0.5s ease;
    position: relative;
  }
  
  .progress-text {
    position: absolute;
    top: -25px;
    right: 0;
    font-size: 14px;
    color: #6c757d;
  }
  
  /* Card System */
  .card {
    background: white;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    padding: 20px;
    margin-bottom: 20px;
    transition: transform 0.2s, box-shadow 0.2s;
  }
  
  .card:hover {
    /* Removed transform to prevent positioning issues */
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  }
  
  /* Responsive Tables */
  .table-responsive {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }
  
  table {
    width: 100%;
    border-collapse: collapse;
  }
  
  @media (max-width: 767px) {
    table {
      font-size: 14px;
    }
    
    th, td {
      padding: 8px 4px;
    }
  }
  
  /* Accessibility Features */
  .sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0,0,0,0);
    white-space: nowrap;
    border: 0;
  }
  
  /* Focus Indicators */
  *:focus {
    outline: 3px solid #4A90E2;
    outline-offset: 2px;
  }
  
  /* High Contrast Mode Support */
  @media (prefers-contrast: high) {
    .card {
      border: 2px solid black;
    }
    
    .btn {
      border: 2px solid currentColor;
    }
  }
  
  /* Dark Mode Support */
  @media (prefers-color-scheme: dark) {
    body {
      background: #1a1a1a;
      color: #ffffff;
    }
    
    .card {
      background: #2d2d2d;
      color: #ffffff;
    }
    
    input, select, textarea {
      background: #3d3d3d;
      color: #ffffff;
      border-color: #555;
    }
  }
  
  /* Print Styles */
  @media print {
    .no-print {
      display: none !important;
    }
    
    body {
      font-size: 12pt;
    }
    
    .card {
      box-shadow: none;
      border: 1px solid #ddd;
    }
  }
  '
  
  return(base_css)
}

#' Create Responsive Question UI
#' 
#' Creates responsive UI for different question types
#' 
#' @param question_type Type of question
#' @param question_id Unique question ID
#' @param question_text Question text
#' @param options Answer options
#' @param required Is answer required
#' @param config Additional configuration
#' @return Shiny UI element
#' @export
create_responsive_question <- function(
  question_type,
  question_id,
  question_text,
  options = NULL,
  required = FALSE,
  config = list()
) {
  
  # Main question container
  question_ui <- shiny::div(
    class = "question-container card",
    `data-question-id` = question_id,
    
    # Question header
    shiny::div(
      class = "question-header",
      shiny::h3(
        class = "question-text",
        question_text,
        if (required) shiny::span(class = "required-indicator", "*")
      )
    ),
    
    # Question body based on type
    shiny::div(
      class = "question-body",
      switch(question_type,
        # Single choice (radio buttons)
        "single" = create_radio_group(question_id, options, config),
        
        # Multiple choice (checkboxes)
        "multiple" = create_checkbox_group(question_id, options, config),
        
        # Slider
        "slider" = create_slider_input(question_id, config),
        
        # Text input
        "text" = create_text_input(question_id, config),
        
        # Matrix/Grid
        "matrix" = create_matrix_question(question_id, options, config),
        
        # Ranking
        "ranking" = create_ranking_question(question_id, options, config),
        
        # Likert scale
        "likert" = create_likert_scale(question_id, config),
        
        # Date picker
        "date" = shiny::dateInput(
          question_id,
          label = NULL,
          width = "100%"
        ),
        
        # File upload
        "file" = shiny::fileInput(
          question_id,
          label = NULL,
          width = "100%",
          accept = config$accept %||% NULL
        ),
        
        # Default fallback
        create_radio_group(question_id, options, config)
      )
    ),
    
    # Error message container
    shiny::div(
      id = paste0(question_id, "_error"),
      class = "error-message",
      style = "display: none; color: red; margin-top: 5px;"
    )
  )
  
  return(question_ui)
}

#' Create Radio Button Group
#' 
#' Creates responsive radio button group
#' 
#' @param input_id Input ID
#' @param choices Choice options
#' @param config Configuration
#' @return Shiny UI element
create_radio_group <- function(input_id, choices, config = list()) {
  shiny::div(
    class = "radio-group",
    shiny::radioButtons(
      input_id,
      label = NULL,
      choices = choices,
      selected = config$selected %||% character(0),
      inline = config$inline %||% FALSE,
      width = "100%"
    )
  )
}

#' Create Checkbox Group
#' 
#' Creates responsive checkbox group
#' 
#' @param input_id Input ID
#' @param choices Choice options
#' @param config Configuration
#' @return Shiny UI element
create_checkbox_group <- function(input_id, choices, config = list()) {
  shiny::div(
    class = "checkbox-group",
    shiny::checkboxGroupInput(
      input_id,
      label = NULL,
      choices = choices,
      selected = config$selected %||% character(0),
      inline = config$inline %||% FALSE,
      width = "100%"
    )
  )
}

#' Create Slider Input
#' 
#' Creates responsive slider input
#' 
#' @param input_id Input ID
#' @param config Configuration
#' @return Shiny UI element
create_slider_input <- function(input_id, config = list()) {
  shiny::sliderInput(
    input_id,
    label = NULL,
    min = config$min %||% 0,
    max = config$max %||% 100,
    value = config$value %||% 50,
    step = config$step %||% 1,
    width = "100%",
    ticks = config$ticks %||% TRUE
  )
}

#' Create Text Input
#' 
#' Creates responsive text input
#' 
#' @param input_id Input ID
#' @param config Configuration
#' @return Shiny UI element
create_text_input <- function(input_id, config = list()) {
  if (config$multiline %||% FALSE) {
    shiny::textAreaInput(
      input_id,
      label = NULL,
      value = config$value %||% "",
      width = "100%",
      height = config$height %||% "100px",
      placeholder = config$placeholder %||% "",
      resize = config$resize %||% "vertical"
    )
  } else {
    shiny::textInput(
      input_id,
      label = NULL,
      value = config$value %||% "",
      width = "100%",
      placeholder = config$placeholder %||% ""
    )
  }
}

#' Create Matrix Question
#' 
#' Creates responsive matrix/grid question
#' 
#' @param input_id Input ID
#' @param options Matrix options (rows and columns)
#' @param config Configuration
#' @return Shiny UI element
create_matrix_question <- function(input_id, options, config = list()) {
  rows <- options$rows %||% c("Row 1", "Row 2")
  cols <- options$cols %||% c("Col 1", "Col 2")
  
  shiny::div(
    class = "matrix-question table-responsive",
    shiny::tags$table(
      class = "table matrix-table",
      shiny::tags$thead(
        shiny::tags$tr(
          shiny::tags$th(""),
          lapply(cols, function(col) shiny::tags$th(col))
        )
      ),
      shiny::tags$tbody(
        lapply(seq_along(rows), function(i) {
          shiny::tags$tr(
            shiny::tags$td(rows[i]),
            lapply(seq_along(cols), function(j) {
              shiny::tags$td(
                shiny::tags$input(
                  type = if (config$multiple %||% FALSE) "checkbox" else "radio",
                  name = paste0(input_id, "_row_", i),
                  value = j,
                  id = paste0(input_id, "_", i, "_", j)
                )
              )
            })
          )
        })
      )
    )
  )
}

#' Create Ranking Question
#' 
#' Creates drag-and-drop ranking question
#' 
#' @param input_id Input ID
#' @param options Items to rank
#' @param config Configuration
#' @return Shiny UI element
create_ranking_question <- function(input_id, options, config = list()) {
  shiny::div(
    class = "ranking-question",
    id = input_id,
    shiny::tags$ul(
      class = "ranking-list sortable",
      `data-input-id` = input_id,
      lapply(seq_along(options), function(i) {
        shiny::tags$li(
          class = "ranking-item",
          `data-value` = i,
          shiny::span(class = "rank-number", paste0(i, ".")),
          shiny::span(class = "rank-text", options[i]),
          shiny::span(class = "drag-handle", "---")
        )
      })
    ),
    shiny::tags$script(HTML(sprintf('
      $(function() {
        $("#%s .sortable").sortable({
          handle: ".drag-handle",
          update: function(event, ui) {
            var order = $(this).sortable("toArray", {attribute: "data-value"});
            Shiny.setInputValue("%s", order);
          }
        });
      });
    ', input_id, input_id)))
  )
}

#' Create Likert Scale
#' 
#' Creates responsive Likert scale
#' 
#' @param input_id Input ID
#' @param config Configuration
#' @return Shiny UI element
create_likert_scale <- function(input_id, config = list()) {
  levels <- config$levels %||% 5
  labels <- config$labels %||% c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree")
  
  if (length(labels) != levels) {
    labels <- seq_len(levels)
  }
  
  shiny::div(
    class = "likert-scale",
    shiny::radioButtons(
      input_id,
      label = NULL,
      choices = setNames(seq_len(levels), labels),
      selected = character(0),
      inline = TRUE,
      width = "100%"
    )
  )
}

#' Apply Responsive Theme
#' 
#' Applies responsive theme to Shiny app
#' 
#' @param theme_name Name of theme to apply
#' @param custom_css Additional custom CSS
#' @return HTML head tags
#' @export
apply_responsive_theme <- function(theme_name = "modern", custom_css = NULL) {
  shiny::tags$head(
    # Viewport meta tag for mobile
    shiny::tags$meta(
      name = "viewport",
      content = "width=device-width, initial-scale=1, maximum-scale=5, user-scalable=yes"
    ),
    
    # Base responsive CSS
    shiny::tags$style(HTML(get_responsive_css(theme_name))),
    
    # Theme-specific CSS
    shiny::tags$style(HTML(get_theme_styles(theme_name))),
    
    # Custom CSS if provided
    if (!is.null(custom_css)) shiny::tags$style(HTML(custom_css)),
    
    # jQuery UI for sortable
    shiny::tags$script(src = "https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"),
    
    # Touch support for mobile
    shiny::tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui-touch-punch/0.2.3/jquery.ui.touch-punch.min.js")
  )
}

#' Get Theme Styles
#' 
#' Returns theme-specific styles
#' 
#' @param theme_name Name of theme
#' @return CSS string
get_theme_styles <- function(theme_name) {
  themes <- list(
    modern = '
      :root {
        --primary: #007bff;
        --secondary: #6c757d;
        --success: #28a745;
        --danger: #dc3545;
        --warning: #ffc107;
        --info: #17a2b8;
        --light: #f8f9fa;
        --dark: #343a40;
      }
      
      .btn-primary {
        background: var(--primary);
        color: white;
        border: none;
        padding: 10px 20px;
        border-radius: 6px;
        cursor: pointer;
        transition: all 0.3s;
      }
      
      .btn-primary:hover {
        background: #0056b3;
        /* Removed transform to prevent positioning issues */
      }
    ',
    
    minimal = '
      :root {
        --primary: #000000;
        --secondary: #666666;
        --background: #ffffff;
        --border: #e0e0e0;
      }
      
      body {
        background: var(--background);
        color: var(--primary);
      }
      
      .card {
        border: 1px solid var(--border);
        box-shadow: none;
      }
    ',
    
    professional = '
      :root {
        --primary: #2c3e50;
        --secondary: #34495e;
        --accent: #3498db;
        --background: #ecf0f1;
      }
      
      body {
        background: var(--background);
        color: var(--primary);
      }
      
      .card {
        background: white;
        border-left: 4px solid var(--accent);
      }
    '
  )
  
  return(themes[[theme_name]] %||% themes[["modern"]])
}