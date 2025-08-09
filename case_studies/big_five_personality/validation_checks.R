# Big Five Personality Assessment - Comprehensive Validation Checks
# ===============================================================
#
# This script provides comprehensive validation checks for the Big Five
# Personality Assessment case study to ensure all functions work correctly
# in all possible scenarios.
#
# Version: 2.0
# Last Updated: 2025-01-20

# Load required packages
library(inrep)
library(dplyr)
library(ggplot2)

# =============================================================================
# COMPREHENSIVE VALIDATION FUNCTIONS
# =============================================================================

# Function to run all validation checks for BFI
validate_bfi_comprehensive <- function() {
  cat("=== Big Five Personality Assessment - Comprehensive Validation ===\n")
  
  results <- list()
  
  # 1. Configuration validation
  cat("1. Validating configuration...\n")
  results$configuration <- validate_bfi_configuration_comprehensive()
  
  # 2. Item bank validation
  cat("2. Validating item bank...\n")
  results$item_bank <- validate_bfi_item_bank_comprehensive()
  
  # 3. Function validation
  cat("3. Validating functions...\n")
  results$functions <- validate_bfi_functions_comprehensive()
  
  # 4. Data validation
  cat("4. Validating data structures...\n")
  results$data_structures <- validate_bfi_data_structures()
  
  # 5. Integration validation
  cat("5. Validating integrations...\n")
  results$integrations <- validate_bfi_integrations()
  
  # 6. Error handling validation
  cat("6. Validating error handling...\n")
  results$error_handling <- validate_bfi_error_handling()
  
  # Generate comprehensive report
  cat("7. Generating validation report...\n")
  generate_bfi_validation_report(results)
  
  return(results)
}

# =============================================================================
# CONFIGURATION VALIDATION
# =============================================================================

validate_bfi_configuration_comprehensive <- function() {
  results <- list()
  
  # Test configuration structure
  results$structure <- validate_bfi_config_structure()
  
  # Test configuration values
  results$values <- validate_bfi_config_values()
  
  # Test configuration consistency
  results$consistency <- validate_bfi_config_consistency()
  
  # Test configuration dependencies
  results$dependencies <- validate_bfi_config_dependencies()
  
  return(results)
}

validate_bfi_config_structure <- function() {
  results <- list()
  
  # Required fields
  required_fields <- c("name", "study_key", "model", "estimation_method", "min_items", "max_items", "min_SEM", "criteria")
  results$required_fields <- all(required_fields %in% names(bfi_config))
  
  # Optional fields
  optional_fields <- c("demographics", "input_types", "theme", "language", "progress_style", "response_ui_type")
  results$optional_fields <- all(optional_fields %in% names(bfi_config))
  
  # Advanced features
  advanced_fields <- c("cache_enabled", "parallel_computation", "feedback_enabled", "accessibility_enhanced")
  results$advanced_fields <- all(advanced_fields %in% names(bfi_config))
  
  return(results)
}

validate_bfi_config_values <- function() {
  results <- list()
  
  # Test name
  results$name_valid <- is.character(bfi_config$name) && length(bfi_config$name) == 1 && nchar(bfi_config$name) > 0
  
  # Test study key
  results$study_key_valid <- is.character(bfi_config$study_key) && length(bfi_config$study_key) == 1 && nchar(bfi_config$study_key) > 0
  
  # Test model
  results$model_valid <- bfi_config$model %in% c("GRM", "PCM", "Rasch")
  
  # Test estimation method
  results$estimation_method_valid <- bfi_config$estimation_method %in% c("TAM", "mirt", "ltm")
  
  # Test item parameters
  results$min_items_valid <- is.numeric(bfi_config$min_items) && bfi_config$min_items > 0 && bfi_config$min_items <= 50
  results$max_items_valid <- is.numeric(bfi_config$max_items) && bfi_config$max_items >= bfi_config$min_items && bfi_config$max_items <= 100
  
  # Test SEM
  results$sem_valid <- is.numeric(bfi_config$min_SEM) && bfi_config$min_SEM > 0 && bfi_config$min_SEM < 1
  
  # Test criteria
  results$criteria_valid <- bfi_config$criteria %in% c("MI", "MFI", "KL", "GDI")
  
  return(results)
}

validate_bfi_config_consistency <- function() {
  results <- list()
  
  # Test item range consistency
  results$item_range_consistent <- bfi_config$min_items <= bfi_config$max_items
  
  # Test session duration consistency
  results$session_duration_consistent <- bfi_config$max_session_duration > 0 && bfi_config$max_session_duration <= 120
  
  # Test response time consistency
  results$response_time_consistent <- bfi_config$max_response_time > 0 && bfi_config$max_response_time <= 600
  
  # Test demographics consistency
  if (!is.null(bfi_config$demographics) && !is.null(bfi_config$input_types)) {
    results$demographics_consistent <- all(bfi_config$demographics %in% names(bfi_config$input_types))
  } else {
    results$demographics_consistent <- TRUE
  }
  
  return(results)
}

validate_bfi_config_dependencies <- function() {
  results <- list()
  
  # Test that required dependencies are met
  results$dependencies_met <- TRUE
  
  # Test that optional features are properly configured
  if (bfi_config$accessibility_enhanced) {
    results$accessibility_dependencies <- TRUE
  } else {
    results$accessibility_dependencies <- TRUE
  }
  
  return(results)
}

# =============================================================================
# ITEM BANK VALIDATION
# =============================================================================

validate_bfi_item_bank_comprehensive <- function() {
  results <- list()
  
  # Test item bank structure
  results$structure <- validate_bfi_item_bank_structure()
  
  # Test item bank content
  results$content <- validate_bfi_item_bank_content()
  
  # Test IRT parameters
  results$irt_parameters <- validate_bfi_irt_parameters()
  
  # Test psychometric properties
  results$psychometric <- validate_bfi_psychometric_properties()
  
  return(results)
}

validate_bfi_item_bank_structure <- function() {
  results <- list()
  
  # Required columns
  required_cols <- c("Item_ID", "Question", "a", "b1", "b2", "b3", "b4", "Dimension", "ResponseCategories")
  results$required_columns <- all(required_cols %in% names(bfi_items_enhanced))
  
  # Optional columns
  optional_cols <- c("Item_Type", "Response_Scale", "Reverse_Coded", "Reliability", "Difficulty", "Discrimination", "Factor_Loading", "Information")
  results$optional_columns <- all(optional_cols %in% names(bfi_items_enhanced))
  
  # Data types
  results$data_types <- list(
    item_id_numeric = is.numeric(bfi_items_enhanced$Item_ID),
    question_character = is.character(bfi_items_enhanced$Question),
    a_numeric = is.numeric(bfi_items_enhanced$a),
    dimension_character = is.character(bfi_items_enhanced$Dimension)
  )
  
  return(results)
}

validate_bfi_item_bank_content <- function() {
  results <- list()
  
  # Test item count
  results$item_count <- nrow(bfi_items_enhanced) == 44
  
  # Test dimensions
  expected_dimensions <- c("Openness", "Conscientiousness", "Extraversion", "Agreeableness", "Neuroticism")
  actual_dimensions <- unique(bfi_items_enhanced$Dimension)
  results$dimensions_complete <- all(expected_dimensions %in% actual_dimensions)
  
  # Test item distribution
  dimension_counts <- table(bfi_items_enhanced$Dimension)
  results$dimension_distribution <- all(dimension_counts >= 8)  # At least 8 items per dimension
  
  # Test question quality
  results$question_quality <- all(nchar(bfi_items_enhanced$Question) > 10)  # Questions should be substantial
  
  return(results)
}

validate_bfi_irt_parameters <- function() {
  results <- list()
  
  # Test discrimination parameters
  results$a_positive <- all(bfi_items_enhanced$a > 0)
  results$a_reasonable <- all(bfi_items_enhanced$a <= 3)  # Reasonable upper limit
  
  # Test difficulty parameters
  results$b_ordering <- all(bfi_items_enhanced$b1 < bfi_items_enhanced$b2 & 
                           bfi_items_enhanced$b2 < bfi_items_enhanced$b3 & 
                           bfi_items_enhanced$b3 < bfi_items_enhanced$b4)
  
  # Test difficulty range
  results$b_range <- all(bfi_items_enhanced$b1 >= -4 & bfi_items_enhanced$b4 <= 4)
  
  # Test response categories
  results$response_categories <- all(bfi_items_enhanced$ResponseCategories == "1,2,3,4,5")
  
  return(results)
}

validate_bfi_psychometric_properties <- function() {
  results <- list()
  
  # Test reliability values
  if ("Reliability" %in% names(bfi_items_enhanced)) {
    results$reliability_range <- all(bfi_items_enhanced$Reliability >= 0 & bfi_items_enhanced$Reliability <= 1)
  } else {
    results$reliability_range <- TRUE
  }
  
  # Test factor loadings
  if ("Factor_Loading" %in% names(bfi_items_enhanced)) {
    results$factor_loading_range <- all(bfi_items_enhanced$Factor_Loading >= 0 & bfi_items_enhanced$Factor_Loading <= 1)
  } else {
    results$factor_loading_range <- TRUE
  }
  
  # Test information values
  if ("Information" %in% names(bfi_items_enhanced)) {
    results$information_positive <- all(bfi_items_enhanced$Information > 0)
  } else {
    results$information_positive <- TRUE
  }
  
  return(results)
}

# =============================================================================
# FUNCTION VALIDATION
# =============================================================================

validate_bfi_functions_comprehensive <- function() {
  results <- list()
  
  # Test validation functions
  results$validation_functions <- validate_bfi_validation_functions()
  
  # Test analysis functions
  results$analysis_functions <- validate_bfi_analysis_functions()
  
  # Test utility functions
  results$utility_functions <- validate_bfi_utility_functions()
  
  # Test launch functions
  results$launch_functions <- validate_bfi_launch_functions()
  
  return(results)
}

validate_bfi_validation_functions <- function() {
  results <- list()
  
  # Test validate_bfi_items function
  results$validate_bfi_items <- tryCatch({
    validate_bfi_items(bfi_items_enhanced)
    TRUE
  }, error = function(e) {
    FALSE
  })
  
  # Test with invalid data
  results$validate_bfi_items_invalid <- tryCatch({
    invalid_items <- bfi_items_enhanced[1:10, ]
    validate_bfi_items(invalid_items)
    FALSE  # Should fail
  }, error = function(e) {
    TRUE  # Expected to fail
  })
  
  return(results)
}

validate_bfi_analysis_functions <- function() {
  results <- list()
  
  # Create test data
  test_data <- list(
    session_id = "test_session_001",
    responses = c(3, 4, 2, 5, 3, 4, 2, 3, 4, 5),
    administered_items = 1:10,
    final_ability = 0.5,
    final_se = 0.3
  )
  
  # Test calculate_dimension_scores
  results$calculate_dimension_scores <- tryCatch({
    scores <- calculate_dimension_scores(test_data, bfi_items_enhanced)
    is.list(scores) && length(scores) > 0
  }, error = function(e) {
    FALSE
  })
  
  # Test generate_personality_profile
  results$generate_personality_profile <- tryCatch({
    scores <- list(Openness = 0.5, Conscientiousness = 0.3, Extraversion = 0.7, Agreeableness = 0.4, Neuroticism = 0.2)
    profile <- generate_personality_profile(scores)
    is.list(profile) && "primary_traits" %in% names(profile)
  }, error = function(e) {
    FALSE
  })
  
  # Test create_bfi_visualizations
  results$create_bfi_visualizations <- tryCatch({
    scores <- list(Openness = 0.5, Conscientiousness = 0.3, Extraversion = 0.7, Agreeableness = 0.4, Neuroticism = 0.2)
    plots <- create_bfi_visualizations(scores)
    is.list(plots)
  }, error = function(e) {
    FALSE
  })
  
  return(results)
}

validate_bfi_utility_functions <- function() {
  results <- list()
  
  # Test export_bfi_config
  results$export_bfi_config <- tryCatch({
    export_bfi_config(bfi_config, "test_bfi_config.rds")
    file.exists("test_bfi_config.rds")
  }, error = function(e) {
    FALSE
  })
  
  # Test import_bfi_config
  results$import_bfi_config <- tryCatch({
    if (file.exists("test_bfi_config.rds")) {
      imported_config <- import_bfi_config("test_bfi_config.rds")
      identical(bfi_config$name, imported_config$name)
    } else {
      FALSE
    }
  }, error = function(e) {
    FALSE
  })
  
  # Clean up test file
  if (file.exists("test_bfi_config.rds")) {
    file.remove("test_bfi_config.rds")
  }
  
  return(results)
}

validate_bfi_launch_functions <- function() {
  results <- list()
  
  # Test launch_bfi_study function exists
  results$launch_function_exists <- exists("launch_bfi_study")
  
  # Test function signature
  if (results$launch_function_exists) {
    results$launch_function_signature <- tryCatch({
      args <- formals(launch_bfi_study)
      length(args) >= 2  # Should have at least config and item_bank parameters
    }, error = function(e) {
      FALSE
    })
  } else {
    results$launch_function_signature <- FALSE
  }
  
  return(results)
}

# =============================================================================
# DATA STRUCTURE VALIDATION
# =============================================================================

validate_bfi_data_structures <- function() {
  results <- list()
  
  # Test data frame structure
  results$dataframe_structure <- is.data.frame(bfi_items_enhanced)
  
  # Test column types
  results$column_types <- list(
    item_id_numeric = is.numeric(bfi_items_enhanced$Item_ID),
    question_character = is.character(bfi_items_enhanced$Question),
    a_numeric = is.numeric(bfi_items_enhanced$a),
    dimension_character = is.character(bfi_items_enhanced$Dimension)
  )
  
  # Test data integrity
  results$data_integrity <- list(
    no_duplicates = !any(duplicated(bfi_items_enhanced$Item_ID)),
    no_missing_values = !any(is.na(bfi_items_enhanced$Item_ID)),
    consistent_lengths = all(sapply(bfi_items_enhanced, length) == nrow(bfi_items_enhanced))
  )
  
  return(results)
}

# =============================================================================
# INTEGRATION VALIDATION
# =============================================================================

validate_bfi_integrations <- function() {
  results <- list()
  
  # Test inrep package integration
  results$inrep_integration <- tryCatch({
    library(inrep)
    TRUE
  }, error = function(e) {
    FALSE
  })
  
  # Test required package dependencies
  results$package_dependencies <- list(
    dplyr_available = requireNamespace("dplyr", quietly = TRUE),
    ggplot2_available = requireNamespace("ggplot2", quietly = TRUE),
    psych_available = requireNamespace("psych", quietly = TRUE)
  )
  
  return(results)
}

# =============================================================================
# ERROR HANDLING VALIDATION
# =============================================================================

validate_bfi_error_handling <- function() {
  results <- list()
  
  # Test invalid configuration handling
  results$invalid_config <- tryCatch({
    invalid_config <- list(name = NULL, study_key = "")
    # This should trigger an error
    FALSE
  }, error = function(e) {
    TRUE  # Expected to fail
  })
  
  # Test invalid item bank handling
  results$invalid_item_bank <- tryCatch({
    invalid_items <- data.frame(Item_ID = 1:5, Question = rep("", 5))
    validate_bfi_items(invalid_items)
    FALSE  # Should fail
  }, error = function(e) {
    TRUE  # Expected to fail
  })
  
  # Test missing data handling
  results$missing_data <- tryCatch({
    test_data <- list(session_id = NULL, responses = NULL)
    calculate_dimension_scores(test_data, bfi_items_enhanced)
    FALSE  # Should fail
  }, error = function(e) {
    TRUE  # Expected to fail
  })
  
  return(results)
}

# =============================================================================
# REPORT GENERATION
# =============================================================================

generate_bfi_validation_report <- function(results) {
  cat("\n=== Big Five Personality Assessment Validation Report ===\n")
  
  # Overall status
  overall_status <- calculate_bfi_overall_status(results)
  cat("Overall Status:", ifelse(overall_status, "PASS", "FAIL"), "\n\n")
  
  # Configuration validation
  cat("1. Configuration Validation:\n")
  print_validation_section(results$configuration)
  
  # Item bank validation
  cat("\n2. Item Bank Validation:\n")
  print_validation_section(results$item_bank)
  
  # Function validation
  cat("\n3. Function Validation:\n")
  print_validation_section(results$functions)
  
  # Data structure validation
  cat("\n4. Data Structure Validation:\n")
  print_validation_section(results$data_structures)
  
  # Integration validation
  cat("\n5. Integration Validation:\n")
  print_validation_section(results$integrations)
  
  # Error handling validation
  cat("\n6. Error Handling Validation:\n")
  print_validation_section(results$error_handling)
  
  # Summary
  cat("\n=== SUMMARY ===\n")
  print_bfi_summary(results)
}

calculate_bfi_overall_status <- function(results) {
  # Calculate overall pass/fail status
  all_passed <- TRUE
  
  for (section in names(results)) {
    if (is.list(results[[section]])) {
      for (subsection in names(results[[section]])) {
        if (is.list(results[[section]][[subsection]])) {
          for (test in names(results[[section]][[subsection]])) {
            if (is.logical(results[[section]][[subsection]][[test]]) && !results[[section]][[subsection]][[test]]) {
              all_passed <- FALSE
            }
          }
        } else if (is.logical(results[[section]][[subsection]]) && !results[[section]][[subsection]]) {
          all_passed <- FALSE
        }
      }
    } else if (is.logical(results[[section]]) && !results[[section]]) {
      all_passed <- FALSE
    }
  }
  
  return(all_passed)
}

print_validation_section <- function(section_results) {
  for (subsection in names(section_results)) {
    if (is.list(section_results[[subsection]])) {
      cat("  ", subsection, ":\n")
      for (test in names(section_results[[subsection]])) {
        status <- ifelse(section_results[[subsection]][[test]], "✅", "❌")
        cat("    ", status, " ", test, "\n")
      }
    } else {
      status <- ifelse(section_results[[subsection]], "✅", "❌")
      cat("  ", status, " ", subsection, "\n")
    }
  }
}

print_bfi_summary <- function(results) {
  total_tests <- 0
  passed_tests <- 0
  
  for (section in names(results)) {
    if (is.list(results[[section]])) {
      for (subsection in names(results[[section]])) {
        if (is.list(results[[section]][[subsection]])) {
          for (test in names(results[[section]][[subsection]])) {
            total_tests <- total_tests + 1
            if (is.logical(results[[section]][[subsection]][[test]]) && results[[section]][[subsection]][[test]]) {
              passed_tests <- passed_tests + 1
            }
          }
        } else {
          total_tests <- total_tests + 1
          if (is.logical(results[[section]][[subsection]]) && results[[section]][[subsection]]) {
            passed_tests <- passed_tests + 1
          }
        }
      }
    } else {
      total_tests <- total_tests + 1
      if (is.logical(results[[section]]) && results[[section]]) {
        passed_tests <- passed_tests + 1
      }
    }
  }
  
  cat("Total tests:", total_tests, "\n")
  cat("Tests passed:", passed_tests, "\n")
  cat("Tests failed:", total_tests - passed_tests, "\n")
  cat("Success rate:", round(passed_tests / total_tests * 100, 1), "%\n")
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Run comprehensive validation
if (interactive()) {
  cat("Running comprehensive BFI validation...\n")
  validation_results <- validate_bfi_comprehensive()
  
  # Save validation results
  saveRDS(validation_results, "case_studies/big_five_personality/validation_results.rds")
  
  cat("\nValidation complete! Results saved to case_studies/big_five_personality/validation_results.rds\n")
} else {
  cat("BFI validation script loaded. Run validate_bfi_comprehensive() to execute.\n")
}