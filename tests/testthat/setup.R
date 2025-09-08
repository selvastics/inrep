# Test setup and configuration
# This file runs before all tests

# Load required packages
library(testthat)
library(inrep)

# Set test environment
options(inrep.test_mode = TRUE)

# Set seed for reproducible tests
set.seed(123)

# Create test data directory if it doesn't exist
if (!dir.exists("test_data")) {
  dir.create("test_data", showWarnings = FALSE)
}

# Clean up any existing test files
cleanup_test_files <- function() {
  test_files <- list.files(pattern = "test_.*\\.(csv|json|rds)$", 
                          full.names = TRUE)
  if (length(test_files) > 0) {
    file.remove(test_files)
  }
}

# Run cleanup
cleanup_test_files()

# Set up parallel processing for tests
if (requireNamespace("future", quietly = TRUE) && 
    requireNamespace("future.apply", quietly = TRUE)) {
  future::plan(future::sequential)  # Use sequential for tests
}

# Test configuration
test_config <- list(
  timeout = 30,  # 30 second timeout for individual tests
  memory_limit = 1000,  # 1GB memory limit
  parallel_workers = 1  # Single worker for tests
)