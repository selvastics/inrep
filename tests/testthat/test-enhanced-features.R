# Test Suite for Enhanced Features
# Tests for session recovery, security, and performance enhancements

library(testthat)
library(inrep)

# Source enhanced modules
source("../../R/enhanced_session_recovery.R")
source("../../R/enhanced_security.R")
source("../../R/enhanced_performance.R")

# Test Session Recovery Features
context("Enhanced Session Recovery")

test_that("Auto-save functionality works correctly", {
  # Initialize recovery system
  recovery_config <- initialize_enhanced_recovery(
    auto_save_interval = 1,
    enable_browser_storage = FALSE
  )
  
  # Create test session data
  test_data <- list(
    session_id = "TEST_001",
    participant_id = "P001",
    progress = 50,
    responses = c(1, 2, 3, 4, 5),
    theta_history = c(0.1, 0.2, 0.3),
    se_history = c(0.5, 0.4, 0.3),
    items_administered = c(1, 2, 3),
    demographics = list(age = 25, gender = "M"),
    config = list(model = "2PL")
  )
  
  # Test auto-save
  result <- auto_save_session(NULL, test_data, force = TRUE)
  expect_true(result)
  
  # Verify recovery file exists
  recovery_files <- list.files(recovery_config$recovery_dir, 
                               pattern = "^recovery_TEST_001")
  expect_true(length(recovery_files) > 0)
})

test_that("Session recovery from file works", {
  # Initialize recovery
  initialize_enhanced_recovery()
  
  # Create and save test session
  test_data <- list(
    session_id = "RECOVER_001",
    participant_id = "P002",
    progress = 75,
    timestamp = Sys.time()
  )
  
  auto_save_session(NULL, test_data, force = TRUE)
  
  # Recover session
  recovered <- recover_session(session_id = "RECOVER_001")
  
  expect_not_null(recovered)
  expect_equal(recovered$session_id, "RECOVER_001")
  expect_equal(recovered$progress, 75)
})

test_that("Recovery data validation works", {
  # Test valid data
  valid_data <- list(
    session_id = "VALID_001",
    timestamp = Sys.time(),
    progress = 50
  )
  expect_true(validate_recovery_data(valid_data))
  
  # Test expired data
  expired_data <- list(
    session_id = "EXPIRED_001",
    timestamp = Sys.time() - 25 * 3600,  # 25 hours old
    progress = 50
  )
  expect_false(validate_recovery_data(expired_data))
  
  # Test missing fields
  invalid_data <- list(
    session_id = "INVALID_001"
  )
  expect_false(validate_recovery_data(invalid_data))
})

test_that("Browser refresh handler JavaScript is generated", {
  js_code <- get_browser_refresh_handler()
  
  expect_type(js_code, "character")
  expect_true(grepl("beforeunload", js_code))
  expect_true(grepl("localStorage", js_code))
  expect_true(grepl("Shiny", js_code))
})

# Test Security Features
context("Enhanced Security")

test_that("Password hashing and verification works", {
  # Initialize security
  initialize_enhanced_security()
  
  # Test password hashing
  password <- "TestPassword123!"
  secured <- secure_password(password)
  
  expect_not_null(secured$hash)
  expect_not_null(secured$salt)
  expect_not_equal(secured$hash, password)
  
  # Test verification
  expect_true(verify_password(password, secured$hash, secured$salt))
  expect_false(verify_password("WrongPassword", secured$hash, secured$salt))
})

test_that("Rate limiting works correctly", {
  initialize_enhanced_security()
  
  identifier <- "test_user"
  endpoint <- "/api/test"
  
  # First 60 requests should pass
  for (i in 1:60) {
    expect_true(check_rate_limit(identifier, endpoint))
  }
  
  # 61st request should fail
  expect_false(check_rate_limit(identifier, endpoint))
  
  # Clear state for next test
  clear_security_state()
})

test_that("CSRF token generation and validation works", {
  initialize_enhanced_security()
  
  session_id <- "SESSION_001"
  
  # Generate token
  token <- generate_csrf_token(session_id)
  expect_type(token, "character")
  expect_true(nchar(token) > 0)
  
  # Validate correct token
  expect_true(validate_csrf_token(session_id, token))
  
  # Validate incorrect token
  expect_false(validate_csrf_token(session_id, "wrong_token"))
  
  # Validate non-existent session
  expect_false(validate_csrf_token("WRONG_SESSION", token))
})

test_that("XSS input sanitization works", {
  initialize_enhanced_security()
  
  # Test script tag removal
  malicious_input <- "<script>alert('XSS')</script>Hello"
  sanitized <- sanitize_input(malicious_input)
  expect_false(grepl("<script>", sanitized))
  expect_true(grepl("Hello", sanitized))
  
  # Test event handler removal
  malicious_input2 <- "<div onclick='alert(1)'>Click me</div>"
  sanitized2 <- sanitize_input(malicious_input2)
  expect_false(grepl("onclick", sanitized2))
  
  # Test HTML escaping
  html_input <- "<b>Bold</b>"
  escaped <- sanitize_input(html_input, allow_html = FALSE)
  expect_true(grepl("&lt;b&gt;", escaped))
})

test_that("Email validation works", {
  initialize_enhanced_security()
  
  # Valid emails
  expect_equal(validate_email("test@example.com"), "test@example.com")
  expect_equal(validate_email("User.Name+tag@example.co.uk"), 
               "user.name+tag@example.co.uk")
  
  # Invalid emails
  expect_null(validate_email("not_an_email"))
  expect_null(validate_email("@example.com"))
  expect_null(validate_email("test@"))
  expect_null(validate_email("test..double@example.com"))
  
  # Too long email
  long_email <- paste0(paste(rep("a", 250), collapse = ""), "@example.com")
  expect_null(validate_email(long_email))
})

test_that("Failed attempt tracking and blocking works", {
  initialize_enhanced_security(max_attempts = 3)
  
  identifier <- "attacker_ip"
  
  # First 2 attempts should not block
  expect_false(track_failed_attempt(identifier))
  expect_false(track_failed_attempt(identifier))
  
  # Third attempt should trigger block
  expect_true(track_failed_attempt(identifier))
  
  # Check if blocked
  expect_true(is_blocked(identifier))
  
  clear_security_state()
})

test_that("File upload validation works", {
  initialize_enhanced_security()
  
  # Create temporary test files
  safe_file <- tempfile(fileext = ".csv")
  writeLines("name,age\nJohn,30", safe_file)
  
  malicious_file <- tempfile(fileext = ".txt")
  writeLines("<?php system('rm -rf /'); ?>", malicious_file)
  
  # Test safe file
  expect_true(validate_file_upload(safe_file))
  
  # Test malicious file
  expect_false(validate_file_upload(malicious_file))
  
  # Clean up
  unlink(c(safe_file, malicious_file))
})

# Test Performance Features
context("Enhanced Performance")

test_that("Caching functionality works", {
  initialize_performance_optimization()
  
  # Cache a result
  key <- "test_computation"
  value <- list(result = 42, data = rnorm(100))
  
  expect_true(cache_result(key, value, ttl = 60))
  
  # Retrieve cached result
  cached <- get_cached_result(key)
  expect_equal(cached$result, 42)
  expect_equal(length(cached$data), 100)
  
  # Test non-existent key
  expect_null(get_cached_result("non_existent_key"))
  
  clear_performance_state()
})

test_that("Memoization works correctly", {
  initialize_performance_optimization()
  
  # Create expensive function
  call_count <- 0
  expensive_fn <- function(x) {
    call_count <<- call_count + 1
    Sys.sleep(0.1)  # Simulate expensive computation
    return(x^2)
  }
  
  # Memoize it
  memoized_fn <- memoize_function(expensive_fn)
  
  # First call should compute
  result1 <- memoized_fn(5)
  expect_equal(result1, 25)
  expect_equal(call_count, 1)
  
  # Second call should use cache
  result2 <- memoized_fn(5)
  expect_equal(result2, 25)
  expect_equal(call_count, 1)  # Should not increase
  
  # Different argument should compute
  result3 <- memoized_fn(3)
  expect_equal(result3, 9)
  expect_equal(call_count, 2)
  
  clear_performance_state()
})

test_that("Large item bank optimization works", {
  # Create large item bank
  large_item_bank <- data.frame(
    item_id = 1:5000,
    difficulty = rnorm(5000),
    discrimination = runif(5000, 0.5, 2)
  )
  
  # Define operation
  operation <- function(chunk) {
    chunk$score <- chunk$difficulty * chunk$discrimination
    return(chunk)
  }
  
  # Test optimization
  result <- optimize_item_bank_operation(large_item_bank, operation, 
                                        chunk_size = 1000)
  
  expect_equal(nrow(result), 5000)
  expect_true("score" %in% names(result))
})

test_that("Memory usage monitoring works", {
  initialize_performance_optimization()
  
  mem_usage <- get_memory_usage()
  
  expect_type(mem_usage, "list")
  expect_true("used_mb" %in% names(mem_usage))
  expect_true("max_mb" %in% names(mem_usage))
  expect_true(mem_usage$used_mb > 0)
})

test_that("Concurrent user handling works", {
  initialize_performance_optimization(max_concurrent_users = 3)
  
  # Connect users
  result1 <- handle_concurrent_users("user1", "connect")
  expect_equal(result1$status, "connected")
  
  result2 <- handle_concurrent_users("user2", "connect")
  expect_equal(result2$status, "connected")
  
  result3 <- handle_concurrent_users("user3", "connect")
  expect_equal(result3$status, "connected")
  
  # Fourth user should be queued
  result4 <- handle_concurrent_users("user4", "connect")
  expect_equal(result4$status, "queued")
  expect_equal(result4$position, 1)
  
  # Disconnect a user
  disconnect_result <- handle_concurrent_users("user1", "disconnect")
  expect_equal(disconnect_result$status, "disconnected")
  
  clear_performance_state()
})

test_that("Batch processing works", {
  items <- 1:100
  
  process_fn <- function(batch) {
    lapply(batch, function(x) x * 2)
  }
  
  # Test sequential processing
  result_seq <- batch_process_items(items, process_fn, batch_size = 25, 
                                    parallel = FALSE)
  expect_equal(length(result_seq), 100)
  expect_equal(result_seq[[50]], 100)
  
  # Test parallel processing (if available)
  if (requireNamespace("parallel", quietly = TRUE)) {
    result_par <- batch_process_items(items, process_fn, batch_size = 25, 
                                      parallel = TRUE)
    expect_equal(length(result_par), 100)
    expect_equal(result_par[[50]], 100)
  }
})

test_that("Cache eviction works", {
  initialize_performance_optimization(max_cache_size = 0.001)  # Very small cache
  
  # Add multiple items to trigger eviction
  for (i in 1:10) {
    cache_result(paste0("key_", i), rnorm(1000), ttl = 3600)
  }
  
  # Check that cache size is limited
  status <- get_performance_status()
  expect_true(status$cache_entries < 10)
  
  clear_performance_state()
})

# Integration Tests
context("Integration Tests")

test_that("All enhanced systems work together", {
  # Initialize all systems
  recovery_config <- initialize_enhanced_recovery()
  security_config <- initialize_enhanced_security()
  performance_config <- initialize_performance_optimization()
  
  # Create a simulated session
  session_data <- list(
    session_id = generate_secure_session_id(),
    participant_id = "INT_TEST_001",
    progress = 0,
    responses = list()
  )
  
  # Test security: sanitize input
  user_input <- "<script>alert('test')</script>Name"
  session_data$name <- sanitize_input(user_input)
  expect_false(grepl("<script>", session_data$name))
  
  # Test performance: cache computation
  compute_theta <- memoize_function(function(responses) {
    mean(unlist(responses))
  })
  
  session_data$responses <- list(1, 2, 3, 4, 5)
  session_data$theta <- compute_theta(session_data$responses)
  expect_equal(session_data$theta, 3)
  
  # Test recovery: auto-save
  save_result <- auto_save_session(NULL, session_data, force = TRUE)
  expect_true(save_result)
  
  # Simulate crash and recovery
  recovered_data <- recover_session(session_id = session_data$session_id)
  expect_not_null(recovered_data)
  expect_equal(recovered_data$participant_id, "INT_TEST_001")
  
  # Clean up
  clear_security_state()
  clear_performance_state()
})

# Edge Case Tests
context("Edge Cases and Stress Tests")

test_that("System handles extreme inputs gracefully", {
  # Test with empty data
  expect_false(validate_recovery_data(NULL))
  expect_null(get_cached_result(NULL))
  expect_null(validate_email(""))
  
  # Test with very large data
  large_data <- list(
    session_id = "LARGE_001",
    data = matrix(rnorm(10000), nrow = 1000),
    timestamp = Sys.time(),
    progress = 50
  )
  
  # Should handle large data without crashing
  expect_true(validate_recovery_data(large_data))
  
  # Test with special characters
  special_chars <- "!@#$%^&*()_+-=[]{}|;':\",./<>?"
  sanitized <- sanitize_input(special_chars)
  expect_type(sanitized, "character")
})

test_that("System recovers from errors gracefully", {
  # Test recovery with corrupted data
  expect_null(recover_session(session_id = "NON_EXISTENT"))
  
  # Test security with invalid inputs
  expect_false(validate_csrf_token(NULL, NULL))
  expect_false(check_rate_limit(NULL, NULL, limit = -1))
  
  # Test performance with invalid cache
  expect_null(get_cached_result(list()))  # Invalid key type
})

# Performance Benchmark Tests
context("Performance Benchmarks")

test_that("Operations complete within acceptable time", {
  skip_on_cran()  # Skip on CRAN to avoid timeout
  
  # Test cache operation speed
  start_time <- Sys.time()
  for (i in 1:100) {
    cache_result(paste0("bench_", i), i, ttl = 60)
    get_cached_result(paste0("bench_", i))
  }
  elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  expect_lt(elapsed, 1)  # Should complete in less than 1 second
  
  # Test security operations speed
  start_time <- Sys.time()
  for (i in 1:100) {
    sanitize_input(paste0("test_input_", i))
  }
  elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  expect_lt(elapsed, 0.5)  # Should complete in less than 0.5 seconds
  
  clear_performance_state()
})