# Test helper functions and setup
# Provides common utilities for testing inrep package

# Set up test environment
library(inrep)
library(testthat)

# Set seed for reproducible tests
set.seed(123)

# Create test item banks for different models
create_test_2pl_bank <- function(n_items = 10) {
  data.frame(
    item_id = 1:n_items,
    a = runif(n_items, 0.5, 2.0),
    b = runif(n_items, -2, 2),
    stringsAsFactors = FALSE
  )
}

create_test_1pl_bank <- function(n_items = 10) {
  data.frame(
    item_id = 1:n_items,
    b = runif(n_items, -2, 2),
    stringsAsFactors = FALSE
  )
}

create_test_3pl_bank <- function(n_items = 10) {
  data.frame(
    item_id = 1:n_items,
    a = runif(n_items, 0.5, 2.0),
    b = runif(n_items, -2, 2),
    c = runif(n_items, 0, 0.3),
    stringsAsFactors = FALSE
  )
}

create_test_grm_bank <- function(n_items = 10) {
  data.frame(
    item_id = 1:n_items,
    a = runif(n_items, 0.5, 2.0),
    b1 = runif(n_items, -2, -0.5),
    b2 = runif(n_items, -0.5, 0.5),
    b3 = runif(n_items, 0.5, 2),
    stringsAsFactors = FALSE
  )
}

# Create test configurations
create_test_config <- function(model = "2PL", ...) {
  create_study_config(
    name = paste("Test", model),
    model = model,
    max_items = 10,
    min_items = 5,
    min_SEM = 0.3,
    ...
  )
}

# Mock response generation
generate_test_responses <- function(n_items, model = "2PL", ability = 0) {
  if (model == "GRM") {
    # Polytomous responses (1-4 scale)
    return(sample(1:4, n_items, replace = TRUE))
  } else {
    # Dichotomous responses (0-1)
    return(sample(c(0, 1), n_items, replace = TRUE))
  }
}

# Test data validation
validate_test_result <- function(result, expected_fields) {
  expect_is(result, "list")
  for (field in expected_fields) {
    expect_true(field %in% names(result), 
                info = paste("Expected field", field, "not found in result"))
  }
}

# Performance testing utilities
measure_performance <- function(expr) {
  start_time <- Sys.time()
  result <- eval(expr)
  end_time <- Sys.time()
  
  list(
    result = result,
    duration = as.numeric(difftime(end_time, start_time, units = "secs"))
  )
}

# Memory usage testing
measure_memory <- function(expr) {
  initial_memory <- gc()
  result <- eval(expr)
  final_memory <- gc()
  
  list(
    result = result,
    memory_used = sum(final_memory[, "used"]) - sum(initial_memory[, "used"])
  )
}

# Error testing utilities
expect_validation_error <- function(expr, expected_message) {
  expect_error(expr, expected_message, fixed = TRUE)
}

expect_graceful_handling <- function(expr) {
  # Should not throw an error, but may return NULL or default values
  result <- tryCatch(
    eval(expr),
    error = function(e) {
      expect_true(FALSE, info = paste("Unexpected error:", e$message))
    }
  )
  return(result)
}

# Parallel processing test utilities
test_parallel_capability <- function() {
  # Check if parallel processing is available
  requireNamespace("future", quietly = TRUE) && 
  requireNamespace("future.apply", quietly = TRUE) &&
  parallel::detectCores() > 1
}

# Test data cleanup
cleanup_test_data <- function() {
  # Remove any test files or temporary data
  test_files <- list.files(pattern = "test_.*\\.(csv|json|rds)$", 
                          full.names = TRUE)
  if (length(test_files) > 0) {
    file.remove(test_files)
  }
}

# Setup and teardown
setup_test_environment <- function() {
  # Set up test environment
  options(inrep.test_mode = TRUE)
  cleanup_test_data()
}

teardown_test_environment <- function() {
  # Clean up after tests
  cleanup_test_data()
  options(inrep.test_mode = NULL)
}