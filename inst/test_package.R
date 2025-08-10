# Test script to verify inrep package installation
# This script tests that all functions can be loaded without errors

# Test 1: Check if all exported functions exist
test_exports <- function() {
  exports <- c(
    # Core functions
    "launch_study",
    "create_study_config",
    
    # Quick start functions
    "quick_start",
    "simple_quiz",
    "educational_test",
    "psychological_assessment",
    "employee_screening",
    "custom_assessment",
    "test_assessment",
    "show_examples",
    "get_help",
    
    # User experience functions
    "initialize_ux_enhancements",
    "user_friendly_error",
    "show_progress_with_eta",
    "configuration_wizard",
    "check_setup",
    "fix_setup_issues",
    "install_required_packages",
    "diagnose_issue",
    
    # Enhanced functions
    "validate_and_fix_config",
    "handle_extreme_parameters",
    "create_fallback_config",
    "validate_unicode_text",
    "handle_branching_rules",
    "optimize_for_scale",
    
    # Operator
    "%||%"
  )
  
  missing <- c()
  for (fn in exports) {
    if (!exists(fn, where = asNamespace("inrep"))) {
      missing <- c(missing, fn)
    }
  }
  
  if (length(missing) > 0) {
    stop("Missing exports: ", paste(missing, collapse = ", "))
  }
  
  message("All exports found successfully!")
  return(TRUE)
}

# Test 2: Check if basic functionality works
test_basic_functionality <- function() {
  # Test the null-coalescing operator
  result1 <- NULL %||% "default"
  if (result1 != "default") stop("Operator %||% not working correctly")
  
  result2 <- "value" %||% "default"
  if (result2 != "value") stop("Operator %||% not working correctly")
  
  message("Basic functionality tests passed!")
  return(TRUE)
}

# Test 3: Try creating a simple configuration
test_config_creation <- function() {
  config <- list(
    name = "Test Study",
    model = "2PL",
    max_items = 10,
    min_items = 5,
    min_SEM = 0.3
  )
  
  # Test validation
  validated <- validate_and_fix_config(config)
  
  if (is.null(validated$name)) stop("Config validation failed")
  
  message("Configuration creation test passed!")
  return(TRUE)
}

# Run all tests
run_all_tests <- function() {
  message("Testing inrep package installation...")
  message("=====================================")
  
  tryCatch({
    test_exports()
    test_basic_functionality()
    test_config_creation()
    
    message("\n=====================================")
    message("All tests passed! Package is ready.")
    message("=====================================")
    return(TRUE)
  }, error = function(e) {
    message("\n=====================================")
    message("Test failed: ", e$message)
    message("=====================================")
    return(FALSE)
  })
}

# If running this script directly
if (interactive()) {
  library(inrep)
  run_all_tests()
}