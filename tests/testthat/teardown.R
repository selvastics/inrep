# Test teardown and cleanup
# This file runs after all tests

# Clean up test files
cleanup_test_files <- function() {
  test_files <- list.files(pattern = "test_.*\\.(csv|json|rds)$", 
                          full.names = TRUE)
  if (length(test_files) > 0) {
    file.remove(test_files)
  }
  
  # Clean up test data directory
  if (dir.exists("test_data")) {
    unlink("test_data", recursive = TRUE)
  }
}

# Run cleanup
cleanup_test_files()

# Reset options
options(inrep.test_mode = NULL)

# Reset parallel plan
if (requireNamespace("future", quietly = TRUE)) {
  future::plan(future::sequential)
}